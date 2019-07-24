#import "JMessageHelper.h"
#import "JmessageFlutterPlugin.h"
#import <AVFoundation/AVFoundation.h>

typedef void (^JMSGConversationCallback)(JMSGConversation *conversation,NSError *error);

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

@interface JmessageFlutterPlugin ()

@property(strong,nonatomic)NSMutableDictionary<NSString *, FlutterResult> *SendMsgCallbackDic;//{@"msgid": @"", @"callbackID": @""}
@property(strong,nonatomic)NSMutableDictionary<NSString *, JMSGMessage *> *draftMessageCache;
@end

@implementation JmessageFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"jmessage_flutter" binaryMessenger:[registrar messenger]];
    JmessageFlutterPlugin* instance = [[JmessageFlutterPlugin alloc] init];
    instance.channel = channel;
    
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  self.SendMsgCallbackDic = @{}.mutableCopy;
  self.draftMessageCache = @{}.mutableCopy;
  return self;
}

- (void)getConversationWithDictionary:(NSDictionary *)param callback:(JMSGConversationCallback)callback {
  if (param[@"type"] == nil) {
    NSError *error = [NSError errorWithDomain:@"param error!" code: 1 userInfo: nil];
    callback(nil,error);
    return;
  }
  
  NSString *appKey = nil;
  
  if (param[@"appKey"] == nil ||
      [param[@"appKey"] isEqualToString:@""]) {
    appKey = self.JMessageAppKey;
  } else {
    appKey = param[@"appKey"];
  }
  
  JMSGConversationType conversationType = [self convertStringToConvsersationType:param[@"type"]];
  switch (conversationType) {
    case kJMSGConversationTypeSingle:{
      [JMSGConversation createSingleConversationWithUsername:param[@"username"]
                                                      appKey:appKey
                                           completionHandler:^(id resultObject, NSError *error) {
                                             if (error) {
                                               callback(nil, error);
                                               return;
                                             }
                                             
                                             JMSGConversation *conversation = resultObject;
                                             callback(conversation,nil);
                                           }];
      break;
    }
    case kJMSGConversationTypeGroup:{
      [JMSGConversation createGroupConversationWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
          callback(nil, error);
          return;
        }
        
        JMSGConversation *conversation = resultObject;
        callback(conversation,nil);
      }];
      break;
    }
    case kJMSGConversationTypeChatRoom:{
      [JMSGConversation createChatRoomConversationWithRoomId:param[@"roomId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
          callback(nil, error);
          return;
        }
        
        JMSGConversation *conversation = resultObject;
        callback(conversation,nil);
      }];
      break;
    }
  }
}

- (JMSGMessage *)createMessageWithDictionary:(NSDictionary *)param type:(JMSGContentType)type {
  
  if (param[@"type"] == nil) {
    return nil;
  }
  
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  JMSGOptionalContent *messageSendingOptions = nil;
  if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
    messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
  }
  
  JMSGMessage *message = nil;
  JMSGAbstractContent *content = nil;
  switch (type) {
    case kJMSGContentTypeText:{
      content = [[JMSGTextContent alloc] initWithText:param[@"text"]];
      break;
    }
    case kJMSGContentTypeImage:{
      NSString *mediaPath = param[@"path"];
      if([[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
        mediaPath = mediaPath;
      } else {
        return nil;
      }
      content = [[JMSGImageContent alloc] initWithImageData: [NSData dataWithContentsOfFile: mediaPath]];
      JMSGImageContent *imgContent = content;
      imgContent.format = [mediaPath pathExtension];
      break;
    }
    case kJMSGContentTypeVoice:{
      NSString *mediaPath = param[@"path"];
      double duration = 0;
      if([[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
        mediaPath = mediaPath;
        
        NSError *error = nil;
        AVAudioPlayer *avAudioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:mediaPath] error: &error];
        if (error) {
          return nil;
        }
        
        duration = avAudioPlayer.duration;
        avAudioPlayer = nil;
        
      } else {
        
        return nil;
      }
      content = [[JMSGVoiceContent alloc] initWithVoiceData:[NSData dataWithContentsOfFile: mediaPath] voiceDuration:@(duration)];
      break;
    }
    case kJMSGContentTypeLocation:{
      content = [[JMSGLocationContent alloc] initWithLatitude:param[@"latitude"] longitude:param[@"longitude"] scale:param[@"scale"] address: param[@"address"]];
      break;
    }
    case kJMSGContentTypeFile:{
      NSString *mediaPath = param[@"path"];
      if([[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
        mediaPath = mediaPath;
      } else {
        return nil;
      }
      
      NSString *fileName = @"";
      if (param[@"fileName"]) {
        fileName = param[@"fileName"];
      }
      
      content = [[JMSGFileContent alloc] initWithFileData:[NSData dataWithContentsOfFile: mediaPath] fileName: fileName];
      JMSGFileContent *fileContent = content;
      fileContent.format =[mediaPath pathExtension];
      break;
    }
    case kJMSGContentTypeCustom:{
      content = [[JMSGCustomContent alloc] initWithCustomDictionary: param[@"customObject"]];
      break;
    }
      
    default:
      return nil;
  }
  
  JMSGConversationType targetType = [self convertStringToConvsersationType:param[@"type"]];
  
  switch (targetType) {
    case kJMSGConversationTypeSingle:{
      message = [JMSGMessage createSingleMessageWithContent:content username:param[@"username"]];
      break;
    }
    case kJMSGConversationTypeGroup:{
      message = [JMSGMessage createGroupMessageWithContent:content groupId:param[@"groupId"]];
      break;
    }
      
    case kJMSGConversationTypeChatRoom:{
      message = [JMSGMessage createChatRoomMessageWithContent:content chatRoomId:param[@"roomId"]];
      break;
    }
  }
  
  if (message) {
    if (param[@"extras"] && [param[@"extras"] isKindOfClass: [NSDictionary class]]) {
      NSDictionary *extras = param[@"extras"];
      for (NSString *key in extras.allKeys) {
        [message.content addStringExtra:extras[key] forKey:key];
      }
    }
    return message;
  } else {
    return nil;
  }
}

- (JMSGContentType)convertStringToContentType:(NSString *)str {
  if ([str isEqualToString:@"text"]) {
    return kJMSGContentTypeText;
  }
  
  if ([str isEqualToString:@"image"]) {
    return kJMSGContentTypeImage;
  }
  
  if ([str isEqualToString:@"voice"]) {
    return kJMSGContentTypeVoice;
  }
  
  if ([str isEqualToString:@"location"]) {
    return kJMSGContentTypeLocation;
  }
  
  if ([str isEqualToString:@"file"]) {
    return kJMSGContentTypeFile;
  }
  
  if ([str isEqualToString:@"custom"]) {
    return kJMSGContentTypeCustom;
  }
  
  return kJMSGContentTypeUnknown;
}

- (JMSGConversationType)convertStringToConvsersationType:(NSString *)str {
  if ([str isEqualToString:@"group"]) {
    return kJMSGConversationTypeGroup;
  }
  
  if ([str isEqualToString:@"chatRoom"]) {
    return kJMSGConversationTypeChatRoom;
  }
  
  return kJMSGConversationTypeSingle;
}

- (JMSGGroupType)convertStringToGroupType:(NSString *)str {
  
  if (str == nil) {
    return kJMSGGroupTypePrivate;
  }
  
  if ([str isEqualToString:@"public"]) {
    return kJMSGGroupTypePublic;
  }
  
  return kJMSGGroupTypePrivate;
}

- (JMSGOptionalContent *)convertDicToJMSGOptionalContent:(NSDictionary *)dic {
  JMSGCustomNotification *customNotification = [[JMSGCustomNotification alloc] init];
  JMSGOptionalContent *optionlContent = [[JMSGOptionalContent alloc] init];
  
  if(dic[@"isShowNotification"]) {
    NSNumber *isShowNotification = dic[@"isShowNotification"];
    optionlContent.noSaveNotification = ![isShowNotification boolValue];
  }
  
  if(dic[@"isRetainOffline"]) {
    NSNumber *isRetainOffline = dic[@"isRetainOffline"];
    optionlContent.noSaveOffline = ![isRetainOffline boolValue];
  }
  
  if(dic[@"isCustomNotificationEnabled"]) {
    NSNumber *isCustomNotificationEnabled = dic[@"isCustomNotificationEnabled"];
    customNotification.enabled= [isCustomNotificationEnabled boolValue];
  }
  
  if(dic[@"notificationTitle"]) {
    customNotification.title = dic[@"notificationTitle"];
  }
  
  if(dic[@"notificationText"]) {
    customNotification.alert = dic[@"notificationText"];
  }
  
  optionlContent.customNotification = customNotification;
  
  return optionlContent;
}





- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if([@"setup" isEqualToString:call.method]) {
    [self setup:call result:result];
  } else if([@"setDebugMode" isEqualToString:call.method]) {
    [self setDebugMode:call result:result];
  } else if([@"applyPushAuthority" isEqualToString:call.method]) {
      [self applyPushAuthority:call result:result];
  } else if([@"setBadge" isEqualToString:call.method]) {
      [self setBadge:call result:result];
  } else if([@"userRegister" isEqualToString:call.method]) {
    [self userRegister:call result:result];
  } else if([@"login" isEqualToString:call.method]) {
    [self login:call result:result];
  } else if([@"logout" isEqualToString:call.method]) {
    [self logout:call result:result];
  } else if([@"getMyInfo" isEqualToString:call.method]) {
    [self getMyInfo:call result:result];
  } else if([@"getUserInfo" isEqualToString:call.method]) {
    [self getUserInfo:call result:result];
  } else if([@"updateMyPassword" isEqualToString:call.method]) {
    [self updateMyPassword:call result:result];
  } else if([@"updateMyAvatar" isEqualToString:call.method]) {
    [self updateMyAvatar:call result:result];
  } else if([@"updateMyInfo" isEqualToString:call.method]) {
    [self updateMyInfo:call result:result];
  } else if([@"updateGroupAvatar" isEqualToString:call.method]) {
    [self updateGroupAvatar:call result:result];
  } else if([@"downloadThumbGroupAvatar" isEqualToString:call.method]) {
    [self downloadThumbGroupAvatar:call result:result];
  } else if([@"downloadOriginalGroupAvatar" isEqualToString:call.method]) {
    [self downloadOriginalGroupAvatar:call result:result];
  } else if([@"setConversationExtras" isEqualToString:call.method]) {
    [self setConversationExtras:call result:result];
  } else if([@"createMessage" isEqualToString:call.method]) {
    [self createMessage:call result:result];
  } else if([@"sendDraftMessage" isEqualToString:call.method]) {
    [self sendDraftMessage:call result:result];
  } else if([@"sendTextMessage" isEqualToString:call.method]) {
    [self sendTextMessage:call result:result];
  } else if([@"sendImageMessage" isEqualToString:call.method]) {
    [self sendImageMessage:call result:result];
  } else if([@"sendVoiceMessage" isEqualToString:call.method]) {
    [self sendVoiceMessage:call result:result];
  } else if([@"sendCustomMessage" isEqualToString:call.method]) {
    [self sendCustomMessage:call result:result];
  } else if([@"sendLocationMessage" isEqualToString:call.method]) {
    [self sendLocationMessage:call result:result];
  } else if([@"sendFileMessage" isEqualToString:call.method]) {
    [self sendFileMessage:call result:result];
  } else if([@"retractMessage" isEqualToString:call.method]) {
    [self retractMessage:call result:result];
  } else if([@"getHistoryMessages" isEqualToString:call.method]) {
    [self getHistoryMessages:call result:result];
  } else if([@"getMessageById" isEqualToString:call.method]) {
    [self getMessageById:call result:result];
  } else if([@"deleteMessageById" isEqualToString:call.method]) {
    [self deleteMessageById:call result:result];
  } else if([@"sendInvitationRequest" isEqualToString:call.method]) {
    [self sendInvitationRequest:call result:result];
  } else if([@"acceptInvitation" isEqualToString:call.method]) {
    [self acceptInvitation:call result:result];
  } else if([@"declineInvitation" isEqualToString:call.method]) {
    [self declineInvitation:call result:result];
  } else if([@"removeFromFriendList" isEqualToString:call.method]) {
    [self removeFromFriendList:call result:result];
  } else if([@"updateFriendNoteName" isEqualToString:call.method]) {
    [self updateFriendNoteName:call result:result];
  } else if([@"updateFriendNoteText" isEqualToString:call.method]) {
    [self updateFriendNoteText:call result:result];
  } else if([@"getFriends" isEqualToString:call.method]) {
    [self getFriends:call result:result];
  } else if([@"createGroup" isEqualToString:call.method]) {
    [self createGroup:call result:result];
  } else if([@"getGroupIds" isEqualToString:call.method]) {
    [self getGroupIds:call result:result];
  } else if([@"getGroupInfo" isEqualToString:call.method]) {
    [self getGroupInfo:call result:result];
  } else if([@"updateGroupInfo" isEqualToString:call.method]) {
    [self updateGroupInfo:call result:result];
  } else if([@"addGroupMembers" isEqualToString:call.method]) {
    [self addGroupMembers:call result:result];
  } else if([@"removeGroupMembers" isEqualToString:call.method]) {
    [self removeGroupMembers:call result:result];
  } else if([@"exitGroup" isEqualToString:call.method]) {
    [self exitGroup:call result:result];
  } else if([@"getGroupMembers" isEqualToString:call.method]) {
    [self getGroupMembers:call result:result];
  } else if([@"addUsersToBlacklist" isEqualToString:call.method]) {
    [self addUsersToBlacklist:call result:result];
  } else if([@"removeUsersFromBlacklist" isEqualToString:call.method]) {
    [self removeUsersFromBlacklist:call result:result];
  } else if([@"getBlacklist" isEqualToString:call.method]) {
    [self getBlacklist:call result:result];
  } else if([@"setNoDisturb" isEqualToString:call.method]) {
    [self setNoDisturb:call result:result];
  } else if([@"getNoDisturbList" isEqualToString:call.method]) {
    [self getNoDisturbList:call result:result];
  } else if([@"setNoDisturbGlobal" isEqualToString:call.method]) {
    [self setNoDisturbGlobal:call result:result];
  } else if([@"isNoDisturbGlobal" isEqualToString:call.method]) {
    [self isNoDisturbGlobal:call result:result];
  } else if([@"blockGroupMessage" isEqualToString:call.method]) {
    [self blockGroupMessage:call result:result];
  } else if([@"isGroupBlocked" isEqualToString:call.method]) {
    [self isGroupBlocked:call result:result];
  } else if([@"getBlockedGroupList" isEqualToString:call.method]) {
    [self getBlockedGroupList:call result:result];
  } else if([@"downloadThumbUserAvatar" isEqualToString:call.method]) {
    [self downloadThumbUserAvatar:call result:result];
  } else if([@"downloadOriginalUserAvatar" isEqualToString:call.method]) {
    [self downloadOriginalUserAvatar:call result:result];
  } else if([@"downloadThumbImage" isEqualToString:call.method]) {
    [self downloadThumbImage:call result:result];
  } else if([@"downloadOriginalImage" isEqualToString:call.method]) {
    [self downloadOriginalImage:call result:result];
  } else if([@"downloadVoiceFile" isEqualToString:call.method]) {
    [self downloadVoiceFile:call result:result];
  } else if([@"downloadFile" isEqualToString:call.method]) {
    [self downloadFile:call result:result];
  } else if([@"createConversation" isEqualToString:call.method]) {
    [self createConversation:call result:result];
  } else if([@"deleteConversation" isEqualToString:call.method]) {
    [self deleteConversation:call result:result];
  } else if([@"enterConversation" isEqualToString:call.method]) {
    [self enterConversation:call result:result];
  } else if([@"exitConversation" isEqualToString:call.method]) {
    [self exitConversation:call result:result];
  } else if([@"getConversation" isEqualToString:call.method]) {
    [self getConversation:call result:result];
  } else if([@"getConversations" isEqualToString:call.method]) {
    [self getConversations:call result:result];
  } else if([@"resetUnreadMessageCount" isEqualToString:call.method]) {
    [self resetUnreadMessageCount:call result:result];
  } else if([@"transferGroupOwner" isEqualToString:call.method]) {
    [self transferGroupOwner:call result:result];
  } else if([@"setGroupMemberSilence" isEqualToString:call.method]) {
    [self setGroupMemberSilence:call result:result];
  } else if([@"enterConversation" isEqualToString:call.method]) {
    [self enterConversation:call result:result];
  } else if([@"exitConversation" isEqualToString:call.method]) {
    [self exitConversation:call result:result];
  } else if([@"getConversation" isEqualToString:call.method]) {
    [self getConversation:call result:result];
  } else if([@"getConversations" isEqualToString:call.method]) {
    [self getConversations:call result:result];
  } else if([@"resetUnreadMessageCount" isEqualToString:call.method]) {
    [self resetUnreadMessageCount:call result:result];
  } else if([@"transferGroupOwner" isEqualToString:call.method]) {
    [self transferGroupOwner:call result:result];
  } else if([@"setGroupMemberSilence" isEqualToString:call.method]) {
    [self setGroupMemberSilence:call result:result];
  } else if([@"isSilenceMember" isEqualToString:call.method]) {
    [self isSilenceMember:call result:result];
  } else if([@"groupSilenceMembers" isEqualToString:call.method]) {
    [self groupSilenceMembers:call result:result];
  } else if([@"setGroupNickname" isEqualToString:call.method]) {
    [self setGroupNickname:call result:result];
  } else if([@"enterChatRoom" isEqualToString:call.method]) {
    [self enterChatRoom:call result:result];
  } else if([@"exitChatRoom" isEqualToString:call.method]) {
    [self exitChatRoom:call result:result];
  } else if([@"getChatRoomConversation" isEqualToString:call.method]) {
    [self getChatRoomConversation:call result:result];
  } else if([@"getChatRoomConversationList" isEqualToString:call.method]) {
    [self getChatRoomConversationList:call result:result];
  } else if([@"getAllUnreadCount" isEqualToString:call.method]) {
    [self getAllUnreadCount:call result:result];
  } else if([@"addGroupAdmins" isEqualToString:call.method]) {
    [self addGroupAdmins:call result:result];
  } else if([@"removeGroupAdmins" isEqualToString:call.method]) {
    [self removeGroupAdmins:call result:result];
  } else if([@"changeGroupType" isEqualToString:call.method]) {
    [self changeGroupType:call result:result];
  } else if([@"getPublicGroupInfos" isEqualToString:call.method]) {
    [self getPublicGroupInfos:call result:result];
  } else if([@"applyJoinGroup" isEqualToString:call.method]) {
    [self applyJoinGroup:call result:result];
  } else if([@"processApplyJoinGroup" isEqualToString:call.method]) {
    [self processApplyJoinGroup:call result:result];
  } else if([@"dissolveGroup" isEqualToString:call.method]) {
    [self dissolveGroup:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)setup:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appkey = @"";
  NSString *channel = @"";
  BOOL isProduction = true;
  BOOL isOpenMessageRoaming = false;
  
  if (param[@"appkey"]) {
    appkey = param[@"appkey"];
    self.JMessageAppKey = appkey;
  }
  
  if (param[@"channel"]) {
    channel = param[@"channel"];
  }
  
  if (param[@"isOpenMessageRoaming"]) {
    NSNumber *isOpenMessageRoamingNum = param[@"isOpenMessageRoaming"];
    isOpenMessageRoaming = [isOpenMessageRoamingNum boolValue];
  }
  
  if (param[@"isProduction"]) {
    NSNumber *isProductionNum = param[@"isProduction"];
    isProduction = [isProductionNum boolValue];
  }
  
  [JMessage addDelegate:self withConversation:nil];
  
  [JMessage setupJMessage:self.launchOptions
                   appKey:appkey
                  channel:channel
         apsForProduction:isProduction
                 category:nil
           messageRoaming:isOpenMessageRoaming];
}

- (void)setDebugMode:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;

  if ([param[@"enable"] boolValue]) {
    [JMessage setDebugMode];
  } else {
    [JMessage setLogOFF];
  }
}

- (void)applyPushAuthority:(FlutterMethodCall*)call result:(FlutterResult)result {

    BOOL isAboveIos8 = NO;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        isAboveIos8 = YES;
    }
    NSDictionary *arguments = call.arguments;
    UIUserNotificationType types = 0;
    if ([arguments[@"sound"] boolValue]) {
        types |= isAboveIos8 ? UIUserNotificationTypeSound : UIRemoteNotificationTypeSound;
    }
    if ([arguments[@"alert"] boolValue]) {
        types |= isAboveIos8 ? UIUserNotificationTypeAlert : UIRemoteNotificationTypeAlert;
    }
    if ([arguments[@"badge"] boolValue]) {
        types |= isAboveIos8 ? UIUserNotificationTypeBadge : UIRemoteNotificationTypeBadge;
    }
    [JMessage registerForRemoteNotificationTypes:types categories:nil];
}

- (void)setBadge:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NSNumber *badge = param[@"badge"];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge.integerValue];
    [JMessage setBadge:badge.integerValue > 0 ? badge.integerValue: 0];
    result(nil);
}

- (void)clearAllNotifications:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
}

- (void)userRegister:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  
  JMSGUserInfo *info = [[JMSGUserInfo alloc] init];
  if (param[@"nickname"]) {
    info.nickname = param[@"nickname"];
  }
  
  if (param[@"birthday"]) {
    NSNumber *birthday = param[@"birthday"];
    info.birthday = @([birthday integerValue] / 1000); // Convert millisecond to second.
  }
  
  if (param[@"signature"]) {
    info.signature = param[@"signature"];
  }
  
  if (param[@"gender"]) {
    if ([param[@"gender"] isEqualToString:@"male"]) {
      info.gender = kJMSGUserGenderMale;
    } else if ([param[@"gender"] isEqualToString:@"female"]) {
      info.gender = kJMSGUserGenderFemale;
    } else if ([param[@"gender"] isEqualToString:@"unknow"]) {
      info.gender = kJMSGUserGenderUnknown;
    }
  }
  
  if (param[@"region"]) {
    info.region = param[@"region"];
  }
  
  if (param[@"address"]) {
    info.address = param[@"address"];
  }
  
  if (param[@"extras"] && [param[@"extras"] isKindOfClass: [NSDictionary class]]) {
    info.extras = param[@"extras"];
  }
  
  [JMSGUser registerWithUsername:param[@"username"]
                        password:param[@"password"]
                        userInfo:info
               completionHandler:^(id resultObject, NSError *error) {
                 if (error) {
                   result([error flutterError]);
                   return;
                 }
                 
                 result(nil);
               }];
  
}


- (void)login:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *user = call.arguments;
  
  [JMSGUser loginWithUsername:user[@"username"] password:user[@"password"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGUser *myInfo = [JMSGUser myInfo];
    // 为了和 Android 行为一致，在登录的时候自动下载缩略图。
    [myInfo thumbAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
      // 下载失败也及时返回。
      result(nil);
    }];
  }];
}


- (void)logout:(FlutterMethodCall*)call result:(FlutterResult)result {
//  NSDictionary *param = call.arguments;
  [JMSGUser logout:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result(nil);
  }];
}




- (void)getMyInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
  JMSGUser *myInfo = [JMSGUser myInfo];
  if (myInfo.username == nil) {
    result(nil);
  } else {
    result([myInfo userToDictionary]);
  }
}

- (void)getUserInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    NSArray *users = resultObject;
    JMSGUser *user = users[0];
    result([user userToDictionary]);
  }];
}

- (void)updateMyPassword:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGUser updateMyPasswordWithNewPassword:param[@"newPwd"] oldPassword:param[@"oldPwd"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result(nil);
  }];
}

- (void)updateMyAvatar:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *mediaPath = param[@"imgPath"];
  
  if(![[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
    NSError *error = [NSError errorWithDomain:@"media file not exit!" code: 1 userInfo: nil];
    result([error flutterError]);
    return;
  }
  
  mediaPath = mediaPath;
  NSData *img = [NSData dataWithContentsOfFile: mediaPath];
  
  [JMSGUser updateMyInfoWithParameter:img userFieldType:kJMSGUserFieldsAvatar completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result(nil);
  }];
}

- (void)updateMyInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  
  JMSGUserInfo *info = [[JMSGUserInfo alloc] init];
  
  if (param[@"nickname"]) {
    info.nickname = param[@"nickname"];
  }
  
  if (param[@"birthday"]) {
    NSNumber *birthday = param[@"birthday"];
    info.birthday = @([birthday integerValue] / 1000); // Millisecond to second.
  }
  
  if (param[@"signature"]) {
    info.signature = param[@"signature"];
  }
  
  if (param[@"gender"]) {
    if ([param[@"gender"] isEqualToString:@"male"]) {
      info.gender = kJMSGUserGenderMale;
    } else if ([param[@"gender"] isEqualToString:@"female"]) {
      info.gender = kJMSGUserGenderFemale;
    } else {
      info.gender = kJMSGUserGenderUnknown;
    }
  }
  
  if (param[@"region"]) {
    info.region = param[@"region"];
  }
  
  if (param[@"address"]) {
    info.address = param[@"address"];
  }
  
  if (param[@"extras"]) {
    info.extras = param[@"extras"];
  }
  
  [JMSGUser updateMyInfoWithUserInfo:info completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result(nil);
  }];
}


- (void)updateGroupAvatar:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *mediaPath = param[@"imgPath"];
  
  if(![[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
    NSError *error = [NSError errorWithDomain:@"media file not exit!" code: 1 userInfo: nil];
    result([error flutterError]);
    return;
  }
  
  mediaPath = mediaPath;
  NSData *img = [NSData dataWithContentsOfFile: mediaPath];
  
  [JMSGGroup updateGroupAvatarWithGroupId:param[@"id"] avatarData:img avatarFormat:[mediaPath pathExtension] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    } else {
      result(nil);
    }
  }];
}


- (void)downloadThumbGroupAvatar:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return ;
    }
    
    JMSGGroup *group = resultObject;
    [group thumbAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
      if (error) {
        result([error flutterError]);
        return ;
      }
      result(@{@"id": objectId, @"filePath": group.thumbAvatarLocalPath ? : @""});
    }];
  }];
}


- (void)downloadOriginalGroupAvatar:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return ;
    }
    
    JMSGGroup *group = resultObject;
    [group largeAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
      if (error) {
        result([error flutterError]);
        return ;
      }
      
      result(@{@"id": objectId, @"filePath": group.largeAvatarLocalPath ? : @""});
    }];
  }];
}


- (void)setConversationExtras:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    
      if (error) {
        result([error flutterError]);
        return ;
      }
      
      NSDictionary *extras = param[@"extras"];
      for (NSString *key in extras) {
        [conversation setExtraValue:extras[key] forKey:key];
      }
      result([conversation conversationToDictionary]);
      return;
    
  }];
}

- (void)createMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  
  JMSGOptionalContent *messageSendingOptions = nil;
  if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
    messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
  }
  
  JMSGContentType type = [self convertStringToContentType: param[@"messageType"]];
  
  JMSGMessage *message = [self createMessageWithDictionary:param type: type];
  if (!message) {
    NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code: 1 userInfo: nil];
    result([error flutterError]);
    return;
  } else {
    self.draftMessageCache[message.msgId] = message;
    result([message messageToDictionary]);
  }
}

- (void)sendDraftMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {

      result([error flutterError]);
      return;
    }
    
    JMSGMessage *message = nil;
    if (self.draftMessageCache[param[@"id"]]) {
      message = self.draftMessageCache[param[@"id"]];
      [self.draftMessageCache removeObjectForKey:param[@"id"]];
    } else {
      NSError *error = [NSError errorWithDomain:@"this message is not create frome [createMessage] api, can not be send!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
//    if (!message) {
//      NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code: 1 userInfo: nil];
//      result([error flutterError]);
//      return;
//    }
    
    if ([message.content isKindOfClass:[JMSGMediaAbstractContent class]]) {
      JMSGMediaAbstractContent *content = (JMSGMediaAbstractContent *)message.content;
      content.uploadHandler = ^(float percent, NSString *msgID) {
      };
    }
    
    JMSGOptionalContent *messageSendingOptions = nil;
    if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
      messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
    }
    
    self.SendMsgCallbackDic[message.msgId] = result;
    
    if (param[@"extras"] && [param[@"extras"] isKindOfClass: [NSDictionary class]]) {
      NSDictionary *extras = param[@"extras"];
      for (NSString *key in extras.allKeys) {
        [message.content addStringExtra:extras[key] forKey:key];
      }
    }
    
    if (messageSendingOptions) {
      [conversation sendMessage:message optionalContent:messageSendingOptions];
    } else {
      [conversation sendMessage:message];
    }
  }];
}


- (void)sendTextMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  
  JMSGOptionalContent *messageSendingOptions = nil;
  if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
    messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
  }
  
  JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeText];
  if (!message) {
    NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code: 1 userInfo: nil];
    result([error flutterError]);
    return;
  }
  
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return ;
    }
    
    self.SendMsgCallbackDic[message.msgId] = result;
    if (messageSendingOptions) {
      [conversation sendMessage:message optionalContent:messageSendingOptions];
    } else {
      [conversation sendMessage:message];
    }
  }];
}


- (void)sendImageMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  JMSGOptionalContent *messageSendingOptions = nil;
  if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
    messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
  }
  
  JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeImage];
  if (!message) {
    NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code: 1 userInfo: nil];
    result([error flutterError]);
    return;
  }
  
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    self.SendMsgCallbackDic[message.msgId] = result;
    if (messageSendingOptions) {
      [conversation sendMessage:message optionalContent:messageSendingOptions];
    } else {
      [conversation sendMessage:message];
    }
  }];
}


- (void)sendVoiceMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  JMSGOptionalContent *messageSendingOptions = nil;
  if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
    messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
  }
  
  JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeVoice];
  if (!message) {
    NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code: 1 userInfo: nil];
    result([error flutterError]);
    return;
  }
  
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    self.SendMsgCallbackDic[message.msgId] = result;
    if (messageSendingOptions) {
      [conversation sendMessage:message optionalContent:messageSendingOptions];
    } else {
      [conversation sendMessage:message];
    }
  }];
}


- (void)sendCustomMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  JMSGOptionalContent *messageSendingOptions = nil;
  if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
    messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
  }
  
  JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeCustom];
  if (!message) {
    NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code: 1 userInfo: nil];
    result([error flutterError]);
    return;
  }
  
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    self.SendMsgCallbackDic[message.msgId] = result;
    if (messageSendingOptions) {
      [conversation sendMessage:message optionalContent:messageSendingOptions];
    } else {
      [conversation sendMessage:message];
    }
  }];
}


- (void)sendLocationMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  JMSGOptionalContent *messageSendingOptions = nil;
  if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
    messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
  }
  
  JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeLocation];
  if (!message) {
    NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code: 1 userInfo: nil];
    result([error flutterError]);
    return;
  }
  
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    self.SendMsgCallbackDic[message.msgId] = result;
    if (messageSendingOptions) {
      [conversation sendMessage:message optionalContent:messageSendingOptions];
    } else {
      [conversation sendMessage:message];
    }
  }];
}


- (void)sendFileMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  JMSGOptionalContent *messageSendingOptions = nil;
  if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
    messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
  }
  
  JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeFile];
  if (!message) {
    NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code: 1 userInfo: nil];
    result([error flutterError]);
    return;
  }
  
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    self.SendMsgCallbackDic[message.msgId] = result;
    if (messageSendingOptions) {
      [conversation sendMessage:message optionalContent:messageSendingOptions];
    } else {
      [conversation sendMessage:message];
    }
  }];
}

- (void)retractMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGMessage *message = [conversation messageWithMessageId:param[@"messageId"]];
    
    if (!message) {
      NSError *error = [NSError errorWithDomain:@"message id do not exit!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    [conversation retractMessage:message completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}


- (void)getHistoryMessages:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSNumber *limit = param[@"limit"];
    if ([limit isEqualToNumber:@(-1)]) {
      limit = nil;
    }
    
    BOOL isDescend = false;
    if (param[@"isDescend"]) {
      NSNumber *number = param[@"isDescend"];
      isDescend = [number boolValue];
    }
    
    NSArray *messageList = [conversation messageArrayFromNewestWithOffset:param[@"from"] limit:limit]; // 降序
    
    NSArray *messageDicArr = [messageList mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
      JMSGMessage *message = obj;
      return [message messageToDictionary];
    }];
    
    if (!isDescend) {
      messageDicArr = [[messageDicArr reverseObjectEnumerator] allObjects];
    }
    
    result(messageDicArr);
  }];
}


- (void)getMessageById:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGMessage *msg = [conversation messageWithMessageId:param[@"messageId"]];
    if (msg) {
      result([msg messageToDictionary]);
    } else {
      NSError *error = [NSError errorWithDomain:@"message id do not exit!" code: 1 userInfo: nil];
      result([error flutterError]);
    }
  }];
}


- (void)deleteMessageById:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    BOOL res = [conversation deleteMessageWithMessageId:param[@"messageId"]];
    
    if (res) {
      result(nil);
    } else {
      NSError *error = [NSError errorWithDomain:@"delete message fail!" code: 1 userInfo: nil];
      result([error flutterError]);
    }
  }];
}

- (void)sendInvitationRequest:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGFriendManager sendInvitationRequestWithUsername:param[@"username"]
                                                appKey:appKey
                                                reason:param[@"reason"]
                                     completionHandler:^(id resultObject, NSError *error) {
                                       if (error) {
                                         result([error flutterError]);
                                         return;
                                       }
                                       result(nil);
                                     }];
}


- (void)acceptInvitation:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGFriendManager acceptInvitationWithUsername:param[@"username"]
                                           appKey:appKey
                                completionHandler:^(id resultObject, NSError *error) {
                                  if (error) {
                                    result([error flutterError]);
                                    return;
                                  }
                                  result(nil);
                                }];
}


- (void)declineInvitation:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  [JMSGFriendManager rejectInvitationWithUsername:param[@"username"]
                                           appKey:appKey
                                           reason:param[@"reason"]
                                completionHandler:^(id resultObject, NSError *error) {
                                  if (error) {
                                    result([error flutterError]);
                                    return;
                                  }
                                  result(nil);
                                }];
}


//TODO: name
- (void)removeFromFriendList:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGFriendManager removeFriendWithUsername:param[@"username"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result(nil);
  }];
}


- (void)updateFriendNoteName:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSArray *userArr = resultObject;
    if (userArr.count < 1) {
      NSError *error = [NSError errorWithDomain:@"cann't find user by username!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    JMSGUser *user = resultObject[0];
    [user updateNoteName:param[@"noteName"] completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
    
  }];
}


- (void)updateFriendNoteText:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSArray *userArr = resultObject;
    if (userArr.count < 1) {
      NSError *error = [NSError errorWithDomain:@"cann't find user by username!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }

    JMSGUser *user = resultObject[0];
    [user updateNoteText:param[@"noteText"] completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];

  }];
}


- (void)getFriends:(FlutterMethodCall*)call result:(FlutterResult)result {

  [JMSGFriendManager getFriendList:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSArray *userList = resultObject;
    NSMutableArray *userDicList = @[].mutableCopy;
    for (JMSGUser *user in userList) {
      [userDicList addObject: [user userToDictionary]];
    }
    
    result(userDicList);
  }];
}


- (void)createGroup:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  JMSGGroupInfo *groupInfo = [[JMSGGroupInfo alloc] init];
  groupInfo.name = param[@"name"];
  groupInfo.desc = param[@"desc"];
  groupInfo.groupType = [self convertStringToGroupType:param[@"groupType"]];
  
  [JMSGGroup createGroupWithGroupInfo:groupInfo memberArray:nil completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    result(group.gid);
  }];
}


- (void)getGroupIds:(FlutterMethodCall*)call result:(FlutterResult)result {
  [JMSGGroup myGroupArray:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSArray *groudIdList = resultObject;
    result(groudIdList);
  }];
}


- (void)getGroupInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    result([group groupToDictionary]);
  }];
}

- (void)updateGroupInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    NSString *newName = group.displayName;
    NSString *newDesc = group.desc;
    
    if (param[@"newName"]) {
      newName = param[@"newName"];
    }
    
    if (param[@"newDesc"]) {
      newDesc = param[@"newDesc"];
    }
    
    [JMSGGroup updateGroupInfoWithGroupId:group.gid name:newName desc:newDesc completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
    
  }];
}

- (void)addGroupMembers:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    [group addMembersWithUsernameArray:param[@"usernameArray"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}

- (void)removeGroupMembers:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    [group removeMembersWithUsernameArray:param[@"usernameArray"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}

- (void)exitGroup:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    [group exit:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}

- (void)getGroupMembers:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    
    [group memberInfoList:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      
      NSArray *memberList = resultObject;
      NSMutableArray *memberInfoList = @[].mutableCopy;
      for (JMSGGroupMemberInfo *member in memberList) {
        [memberInfoList addObject:[member memberToDictionary]];
      }
      result(memberInfoList);
    }];
  }];
}


- (void)addUsersToBlacklist:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGUser addUsersToBlacklist:param[@"usernameArray"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result(nil);
  }];
}

- (void)removeUsersFromBlacklist:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGUser delUsersFromBlacklist:param[@"usernameArray"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result(nil);
  }];
}


- (void)getBlacklist:(FlutterMethodCall*)call result:(FlutterResult)result {
  [JMessage blackList:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSArray *userList = resultObject;
    NSMutableArray *userDicList = @[].mutableCopy;
    for (JMSGUser *user in userList) {
      [userDicList addObject:[user userToDictionary]];
    }
    result(userDicList);
  }];
}


- (void)setNoDisturb:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSNumber *isNoDisturb;
  
  isNoDisturb = param[@"isNoDisturb"];
  
  if ([param[@"type"] isEqualToString:@"single"]) {
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
      appKey = param[@"appKey"];
    } else {
      appKey = self.JMessageAppKey;
    }
    
    [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      
      NSArray *userList = resultObject;
      
      if (userList.count < 1) {
        NSError *error = [NSError errorWithDomain:@"user not exit!" code: 1 userInfo: nil];
        result([error flutterError]);
        return;
      }
      
      JMSGUser *user = userList[0];
      [user setIsNoDisturb:[isNoDisturb boolValue] handler:^(id resultObject, NSError *error) {
        if (error) {
          result([error flutterError]);
          return;
        }
        result(nil);
      }];
      
    }];
    return;
  }
  
  if ([param[@"type"] isEqualToString:@"group"]) {
    [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      
      JMSGGroup *group = resultObject;
      [group setIsNoDisturb:[isNoDisturb boolValue] handler:^(id resultObject, NSError *error) {
        if (error) {
          result([error flutterError]);
          return;
        }
        
        result(nil);
      }];
    }];
    return;
  }
}


- (void)getNoDisturbList:(FlutterMethodCall*)call result:(FlutterResult)result {
  [JMessage noDisturbList:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    NSArray *disturberList = resultObject;
    NSMutableArray *userDicList = @[].mutableCopy;
    NSMutableArray *groupDicList = @[].mutableCopy;
    for (id disturber in disturberList) {
      if ([disturber isKindOfClass:[JMSGUser class]]) {
        
        [userDicList addObject:[disturber userToDictionary]];
      }
      
      if ([disturber isKindOfClass:[JMSGGroup class]]) {
        [groupDicList addObject:[disturber groupToDictionary]];
      }
    }
    result(@{@"userInfos": userDicList, @"groupInfos": groupDicList});
  }];
}


- (void)setNoDisturbGlobal:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMessage setIsGlobalNoDisturb:[param[@"isNoDisturb"] boolValue] handler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result(nil);
  }];
}


- (void)isNoDisturbGlobal:(FlutterMethodCall*)call result:(FlutterResult)result {
  
  BOOL isNodisturb = [JMessage isSetGlobalNoDisturb];
  result(@{@"isNoDisturb": @(isNodisturb)});
}


- (void)blockGroupMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSNumber *isBlock = param[@"isBlock"];
  
  [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    [group setIsShield:[isBlock boolValue] handler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}


- (void)isGroupBlocked:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    result(@{@"isBlocked": @(group.isShieldMessage)});
  }];
}

- (void)getBlockedGroupList:(FlutterMethodCall*)call result:(FlutterResult)result {
  
  [JMSGGroup shieldList:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSArray *groupArr = resultObject;
    NSMutableArray *groupList = @[].mutableCopy;
    
    for (JMSGGroup *group in groupArr) {
      [groupList addObject:group];
    }
    result(groupList);
  }];
}


- (void)downloadThumbUserAvatar:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSArray *userList = resultObject;
    if (userList.count < 1) {
      NSError *error = [NSError errorWithDomain:@"user not exit!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    JMSGUser *user = userList[0];
    [user thumbAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(@{@"username": user.username,
               @"appKey": user.appKey,
               @"filePath": [user thumbAvatarLocalPath] ? : @""});
    }];
  }];
}


- (void)downloadOriginalUserAvatar:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSArray *userList = resultObject;
    if (userList.count < 1) {
      NSError *error = [NSError errorWithDomain:@"user not exit!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    JMSGUser *user = userList[0];
    [user largeAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }

      result(@{@"username": user.username,
               @"appKey": user.appKey,
               @"filePath": [user largeAvatarLocalPath] ? : @""});
    }];
  }];
}


- (void)downloadThumbImage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGMessage *message = [conversation messageWithMessageId:param[@"messageId"]];
    if (!message) {
      NSError *error = [NSError errorWithDomain:@"cann't find this message!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    if (message.contentType != kJMSGContentTypeImage) {
      NSError *error = [NSError errorWithDomain:@"It is not image message!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    JMSGImageContent *content = (JMSGImageContent *) message.content;
    
    [content thumbImageData:^(NSData *data, NSString *objectId, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(@{@"messageId": message.msgId,
               @"filePath": content.thumbImageLocalPath ? : @""});
    }];
    
  }];
}


- (void)downloadOriginalImage:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGMessage *message = [conversation messageWithMessageId:param[@"messageId"]];
    if (!message) {
      NSError *error = [NSError errorWithDomain:@"cann't find this message!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    if (message.contentType != kJMSGContentTypeImage) {
      NSError *error = [NSError errorWithDomain:@"It is not image message!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    JMSGImageContent *content = (JMSGImageContent *) message.content;
    [content largeImageDataWithProgress:^(float percent, NSString *msgId) {
      //      TODO:
    } completionHandler:^(NSData *data, NSString *objectId, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      
      JMSGMediaAbstractContent *mediaContent = (JMSGMediaAbstractContent *) message.content;
      result(@{@"messageId": message.msgId,
               @"filePath": [mediaContent originMediaLocalPath] ? : @""});
    }];
  }];
}

- (void)downloadVoiceFile:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGMessage *message = [conversation messageWithMessageId:param[@"messageId"]];
    
    if (message == nil) {
      NSError *error = [NSError errorWithDomain:@"cann't find this message!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    if (message.contentType != kJMSGContentTypeVoice) {
      NSError *error = [NSError errorWithDomain:@"It is not image message!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    } else {
      JMSGVoiceContent *content = (JMSGVoiceContent *) message.content;
      [content voiceData:^(NSData *data, NSString *objectId, NSError *error) {
        if (error) {
          result([error flutterError]);
          return;
        }
        
        JMSGMediaAbstractContent *mediaContent = (JMSGMediaAbstractContent *) message.content;
        result(@{@"messageId": message.msgId,
                 @"filePath": [mediaContent originMediaLocalPath] ? : @""});
      }];
    }
  }];
}


- (void)downloadFile:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    JMSGMessage *message = [conversation messageWithMessageId:param[@"messageId"]];
    
    if (!message) {
      NSError *error = [NSError errorWithDomain:@"cann't find this message!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    if (message.contentType != kJMSGContentTypeFile) {
      NSError *error = [NSError errorWithDomain:@"It is not file message!" code: 1 userInfo: nil];
      result([error flutterError]);
      return;
    }
    
    JMSGFileContent *content = (JMSGFileContent *) message.content;
    [content fileData:^(NSData *data, NSString *objectId, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      JMSGFileContent *fileContent = (JMSGFileContent *) message.content;
      result(@{@"messageId": message.msgId,
               @"filePath":[fileContent originMediaLocalPath] ? : @""});
    }];
    
  }];
}


- (void)createConversation:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result([conversation conversationToDictionary]);
  }];
}


- (void)deleteConversation:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  JMSGConversationType type =  [self convertStringToConvsersationType:param[@"type"]];
  switch (type) {
    case kJMSGConversationTypeSingle: {
      [JMSGConversation deleteSingleConversationWithUsername:param[@"username"] appKey:appKey];
      break;
    }
    case kJMSGConversationTypeGroup: {
      [JMSGConversation deleteGroupConversationWithGroupId:param[@"groupId"]];
      break;
    }
    case kJMSGConversationTypeChatRoom: {
      [JMSGConversation deleteChatRoomConversationWithRoomId:param[@"roomId"]];
      break;
    }
  }
  
  result(nil);
}

// IM SDK do not surport this feature
- (void)enterConversation:(FlutterMethodCall*)call result:(FlutterResult)result {
}

// IM SDK do not surport this feature
- (void)exitConversation:(FlutterMethodCall*)call result:(FlutterResult)result {
}


- (void)getConversation:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result([conversation conversationToDictionary]);
  }];
}

- (void)getConversations:(FlutterMethodCall*)call result:(FlutterResult)result {
  [JMSGConversation allConversations:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    NSArray *conversationList = resultObject;
    NSMutableArray *conversationDicList = @[].mutableCopy;
    
    if (conversationList.count < 1) {
      result(@[]);
    } else {
      for (JMSGConversation *conversation in conversationList) {
        [conversationDicList addObject:[conversation conversationToDictionary]];
      }
      result(conversationDicList);
    }
  }];
}

- (void)resetUnreadMessageCount:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    [conversation clearUnreadCount];
    result(nil);
  }];
}

- (void)transferGroupOwner:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    [group transferGroupOwnerWithUsername:param[@"username"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}


- (void)setGroupMemberSilence:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    [group setGroupMemberSilence:[param[@"isSilence"] boolValue] username:param[@"username"] appKey:appKey handler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}


- (void)isSilenceMember:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    
    BOOL isSilence = [group isSilenceMemberWithUsername:param[@"username"] appKey:appKey];
    result(@{@"isSilence": @(isSilence)});
  }];
}


- (void)groupSilenceMembers:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    NSArray *silenceMembers = [group groupSilenceMembers];
    NSArray *silenceUserDicArr = [silenceMembers mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
      JMSGUser *user = obj;
      return [user userToDictionary];
    }];
    result(silenceUserDicArr);
  }];
}


- (void)setGroupNickname:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    
    [group setGroupNickname:param[@"nickName"] username:param[@"username"] appKey:appKey handler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}


- (void)enterChatRoom:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGChatRoom enterChatRoomWithRoomId:param[@"roomId"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGConversation *conversation = resultObject;
    result([conversation conversationToDictionary]);
  }];
}


- (void)exitChatRoom:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGChatRoom leaveChatRoomWithRoomId:param[@"roomId"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result(nil);
  }];
}


- (void)getChatRoomConversation:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  JMSGConversation *chatRoomConversation = [JMSGConversation chatRoomConversationWithRoomId:param[@"roomId"]];

  if (!chatRoomConversation) {
    NSError *error = [NSError errorWithDomain:@"cannot found chat room convsersation from this roomId" code: 1 userInfo: nil];
    result([error flutterError]);;
    return;
  }
  result([chatRoomConversation conversationToDictionary]);
}


- (void)getChatRoomConversationList:(FlutterMethodCall*)call result:(FlutterResult)result {

  [JMSGConversation allChatRoomConversation:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSArray *conversationArr = resultObject;
    NSArray *conversationDicArr = [conversationArr mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
      JMSGConversation *conversation = obj;
      return [conversation conversationToDictionary];
    }];
    result(conversationDicArr);
  }];
}


- (void)getAllUnreadCount:(FlutterMethodCall*)call result:(FlutterResult)result {
  result([JMSGConversation getAllUnreadCount]);
}


- (void)addGroupAdmins:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    [group addGroupAdminWithUsernames:param[@"usernames"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}


- (void)removeGroupAdmins:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    [group deleteGroupAdminWithUsernames:param[@"usernames"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}


- (void)changeGroupType:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    JMSGGroup *group = resultObject;
    JMSGGroupType type = [self convertStringToGroupType:param[@"type"]];
    [group changeGroupType:type handler:^(id resultObject, NSError *error) {
      if (error) {
        result([error flutterError]);
        return;
      }
      result(nil);
    }];
  }];
}


- (void)getPublicGroupInfos:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  NSString *appKey = nil;
  if (param[@"appKey"]) {
    appKey = param[@"appKey"];
  } else {
    appKey = self.JMessageAppKey;
  }
  
  [JMSGGroup getPublicGroupInfoWithAppKey:appKey start:[param[@"start"] integerValue] count:[param[@"count"] integerValue] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    NSArray *groupInfoArr = resultObject;
    NSArray *groupDicArr = [groupInfoArr mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
      JMSGGroupInfo *groupInfo = obj;
      return [groupInfo groupToDictionary];
    }];
    result(groupDicArr);
  }];
}


- (void)applyJoinGroup:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup applyJoinGroupWithGid:param[@"groupId"] reason:param[@"reason"] completionHandler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    result(nil);
  }];
}


- (void)processApplyJoinGroup:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup processApplyJoinGroupEvents:param[@"events"]
                                 isAgree:[param[@"isAgree"] boolValue]
                                  reason:param[@"reason"]
                             sendInviter:[param[@"isRespondInviter"] boolValue]
                                 handler:^(id resultObject, NSError *error) {
                                   if (error) {
                                     result([error flutterError]);
                                     return;
                                   }
                                   result(nil);
                                 }];
}


- (void)dissolveGroup:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *param = call.arguments;
  [JMSGGroup dissolveGroupWithGid:param[@"groupId"] handler:^(id resultObject, NSError *error) {
    if (error) {
      result([error flutterError]);
      return;
    }
    
    result(nil);
  }];
}


#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.launchOptions = launchOptions;
    
    return YES;
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JMessage registerDeviceToken:deviceToken];
}

#pragma mark - JMessage Event

- (void)onReceiveMessage:(JMSGMessage *)message error:(NSError *)error{
  [_channel invokeMethod:@"onReceiveMessage" arguments: [message messageToDictionary]];
}

/*!
 * @abstract 监听消息撤回事件
 *
 * @param retractEvent 下发的通知事件，事件类型请查看 JMSGMessageRetractEvent 类
 */
- (void)onReceiveMessageRetractEvent:(JMSGMessageRetractEvent *)retractEvent {
  NSDictionary *conversation = [retractEvent.conversation conversationToDictionary];
  NSDictionary *messageDic = [retractEvent.retractMessage messageToDictionary];
  [_channel invokeMethod:@"onRetractMessage" arguments: @{@"conversation":conversation,
                                                          @"retractedMessage":messageDic}];
  
}


// 登录状态变更事件
- (void)onReceiveUserLoginStatusChangeEvent:(JMSGUserLoginStatusChangeEvent *)event {
  NSDictionary *param = nil;
  switch (event.eventType) {
    case kJMSGEventNotificationLoginKicked:
      param = @{@"type":@"user_kicked"};
      break;
    case kJMSGEventNotificationServerAlterPassword:
      param = @{@"type":@"user_password_change"};
      
      break;
    case kJMSGEventNotificationUserLoginStatusUnexpected:
      param = @{@"type":@"user_login_state_unexpected"};
      break;
    default:
      break;
  }
  [_channel invokeMethod:@"onLoginStateChanged" arguments: param];
}


/*!
 * @abstract 监听消息回执状态变更事件
 *
 * @param receiptEvent 下发的通知事件，事件类型请查看 JMSGMessageReceiptStatusChangeEvent 类
 *
 * @discussion 上层可以通过 receiptEvent 获取相应信息
 *
 */
- (void)onReceiveMessageReceiptStatusChangeEvent:(JMSGMessageReceiptStatusChangeEvent *)receiptEvent {
  
}


/*!
 * @abstract 监听消息透传事件
 *
 * @param transparentEvent 下发的通知事件，事件类型请查看 JMSGMessageTransparentEvent 类
 *
 * @discussion 消息透传的类型：单聊、群聊、设备间透传消息
 *
 */
- (void)onReceiveMessageTransparentEvent:(JMSGMessageTransparentEvent *)transparentEvent {
  /// 消息透传的类型,单聊、群聊、设备间透传消息
  NSMutableDictionary *param = @{}.mutableCopy;
  switch (transparentEvent.transMessageType) {
    case kJMSGTransMessageTypeSingle:{
        JMSGUser *user = transparentEvent.target;
        param[@"receiver"] = [user userToDictionary];
        param[@"receiverType"] = @"user";
        break;
      }
    case kJMSGTransMessageTypeGroup: {
      JMSGGroup *group = transparentEvent.target;
      param[@"receiver"] = [group groupToDictionary];
      param[@"receiverType"] = @"group";
      break;
    }
    case kJMSGTransMessageTypeCrossDevice:
      // TODO:
      break;
      
    default:
      break;
  }
  param[@"sender"] = [transparentEvent.sendUser userToDictionary];
  param[@"message"] = transparentEvent.transparentText;
  [_channel invokeMethod:@"onReceiveTransCommand" arguments: param];
}

/*!
 * @abstract 监听好友相关事件
 * @discussion 可监听：加好友、删除好友、好友更新等事件
 */
- (void)onReceiveFriendNotificationEvent:(JMSGFriendNotificationEvent *)event {
  NSDictionary *param = nil;
  switch (event.eventType) {
    case kJMSGEventNotificationReceiveFriendInvitation:{
      JMSGFriendNotificationEvent *friendEvent = (JMSGFriendNotificationEvent *) event;
      JMSGUser *user = [friendEvent getFromUser];
      param = @{
                  @"type":@"invite_received",
                  @"reason":[friendEvent eventDescription] ?: @"",
                  @"fromUsername":[friendEvent getFromUser].username,
                  @"fromUserAppKey":user.appKey
                };
    }
      break;
    case kJMSGEventNotificationAcceptedFriendInvitation:{
      JMSGFriendNotificationEvent *friendEvent = (JMSGFriendNotificationEvent *) event;
      JMSGUser *user = [friendEvent getFromUser];
      param = @{
                  @"type":@"invite_accepted",
                  @"reason":[friendEvent eventDescription] ?: @"",
                  @"fromUsername":[friendEvent getFromUser].username,
                  @"fromUserAppKey":user.appKey
                };
    }
      break;
    case kJMSGEventNotificationDeclinedFriendInvitation:{
      JMSGFriendNotificationEvent *friendEvent = (JMSGFriendNotificationEvent *) event;
      JMSGUser *user = [friendEvent getFromUser];
      param = @{
                  @"type":@"invite_declined",
                  @"reason":[friendEvent eventDescription] ?: @"",
                  @"fromUsername":[friendEvent getFromUser].username,
                  @"fromUserAppKey":user.appKey
                };
    }
      break;
    case kJMSGEventNotificationDeletedFriend:{
      JMSGFriendNotificationEvent *friendEvent = (JMSGFriendNotificationEvent *) event;
      JMSGUser *user = [friendEvent getFromUser];
      param = @{
                  @"type":@"contact_deleted",
                  @"reason":[friendEvent eventDescription] ?: @"",
                  @"fromUsername":[friendEvent getFromUser].username,
                  @"fromUserAppKey":user.appKey
                };
    }
      break;
      
    default:
      break;
  }
  
  if (param) {
    [_channel invokeMethod:@"onContactNotify" arguments: param];
  }
}

#pragma mark - Group 回调

/*!
 * @abstract 群组信息 (GroupInfo) 信息通知
 * @param group 变更后的群组对象
 * @discussion 如果想要获取通知, 需要先注册回调. 具体请参考 JMessageDelegate 里的说明.
 */
- (void)onGroupInfoChanged:(JMSGGroup *)group {
  [_channel invokeMethod:@"onGroupInfoChanged" arguments: [group groupToDictionary]];
}

/*!
 * @abstract 监听申请入群通知
 * @param event 申请入群事件
 * @discussion 只有群主和管理员能收到此事件；申请入群事件相关参数请查看 JMSGApplyJoinGroupEvent 类，在群主审批此事件时需要传递事件的相关参数
 */
- (void)onReceiveApplyJoinGroupApprovalEvent:(JMSGApplyJoinGroupEvent *)event {
  [_channel invokeMethod:@"onReceiveApplyJoinGroupApproval" arguments: [event eventToDictionary]];
}

/*!
 * @abstract 监听管理员拒绝入群申请通知
 * @param event 拒绝入群申请事件
 * @discussion 只有申请方和被申请方会收到此事件；拒绝的相关描述和原因请查看 JMSGGroupAdminRejectApplicationEvent 类
 */
- (void)onReceiveGroupAdminRejectApplicationEvent:(JMSGGroupAdminRejectApplicationEvent *)event {
  [_channel invokeMethod:@"onReceiveGroupAdminReject" arguments: [event eventToDictionary]];
}

/*!
 * @abstract 监听管理员审批通知
 * @discussion 只有管理员才会收到该事件；当管理员同意或拒绝了某个入群申请事件时，其他管理员就会收到该事件，相关属性请查看 JMSGGroupAdminApprovalEvent 类
 */
- (void)onReceiveGroupAdminApprovalEvent:(JMSGGroupAdminApprovalEvent *)event {
  [_channel invokeMethod:@"onReceiveGroupAdminApproval" arguments: [event eventToDictionary]];
}

/*!
 * @abstract 群成员群昵称变更通知
 * @param events 群成员昵称变更事件列表
 * @discussion 如果是离线事件，SDK 会将所有的修改记录加入数组上抛。事件具体相关属性请查看 JMSGGroupNicknameChangeEvent 类
 */
- (void)onReceiveGroupNicknameChangeEvents:(NSArray<__kindof JMSGGroupNicknameChangeEvent*>*)events {
  NSArray *eventDicArr = [events mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
    JMSGGroupNicknameChangeEvent *event = obj;
    return [event eventToDictionary];
  }];
  [_channel invokeMethod:@"onReceiveGroupNicknameChange" arguments: eventDicArr];
}

- (void)onSendMessageResponse:(JMSGMessage *)message error:(NSError *)error {

    if (!error) {
        NSLog(@"消息发送成功：%@",message.serverMessageId);
    }
  FlutterResult result = self.SendMsgCallbackDic[message.msgId];
  if (error) {
    result([error flutterError]);
    return;
  }
  result([message messageToDictionary]);
}

- (void)onReceiveMessageDownloadFailed:(JMSGMessage *)message{
  NSLog(@"onReceiveMessageDownloadFailed");
}

#pragma mark - Conversation 回调

- (void)onReceiveChatRoomConversation:(JMSGConversation *)conversation messages:(NSArray<__kindof JMSGMessage *> *)messages {
  NSArray *messageDicArr = [messages mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
    JMSGMessage *message = obj;
    return [message messageToDictionary];
  }];
  [_channel invokeMethod:@"onReceiveChatRoomMessage" arguments: messageDicArr];
}

- (void)onConversationChanged:(JMSGConversation *)conversation{
  NSMutableDictionary * conversationDict = [NSMutableDictionary new];
  conversationDict = [conversation conversationToDictionary];
//  [_channel invokeMethod:@"" arguments: conversationDict];
//  DO not support this feature
}

- (void)onUnreadChanged:(NSUInteger)newCount{
  [_channel invokeMethod:@"onUnreadChanged" arguments: @(newCount)];
}

- (void)onSyncRoamingMessageConversation:(JMSGConversation *)conversation {
  [_channel invokeMethod:@"onSyncRoamingMessage" arguments: [conversation conversationToDictionary]];
}

- (void)onSyncOfflineMessageConversation:(JMSGConversation *)conversation
                         offlineMessages:(NSArray JMSG_GENERIC ( __kindof JMSGMessage *) *)offlineMessages {
  NSMutableDictionary *callBackDic = @{}.mutableCopy;
  callBackDic[@"conversation"] = [conversation conversationToDictionary];
  NSMutableArray *messageArr = @[].mutableCopy;
  for (JMSGMessage *message in offlineMessages) {
    [messageArr addObject: [message messageToDictionary]];
  }
  
  callBackDic[@"messageArray"] = messageArr;
  [_channel invokeMethod:@"onSyncOfflineMessage" arguments: callBackDic];
}

@end
