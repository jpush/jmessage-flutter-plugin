//	            __    __                ________
//	| |    | |  \ \  / /  | |    | |   / _______|
//	| |____| |   \ \/ /   | |____| |  / /
//	| |____| |    \  /    | |____| |  | |   _____
//	| |    | |    /  \    | |    | |  | |  |____ |
//  | |    | |   / /\ \   | |    | |  \ \______| |
//  | |    | |  /_/  \_\  | |    | |   \_________|
//
//	Copyright (c) 2012年 HXHG. All rights reserved.
//	http://www.jpush.cn
//  Created by liangjianguo
//


#import <Foundation/Foundation.h>
#import <JMessage/JMessage.h>

//static NSString *JMessageAppKey;

@interface JMessageHelper : NSObject<JMessageDelegate>
@property(nonatomic, strong)NSString *JMessageAppKey;
@property(strong,nonatomic)NSDictionary *launchOptions;
+ (JMessageHelper *)shareInstance;

@end


@interface NSArray (JMessage)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
@end

@interface NSDictionary (JMessage)
-(NSString*)toJsonString;
@end

@interface NSString (JMessage)
-(NSDictionary*)toDictionary;
@end

@interface JMSGConversation (JMessage)
-(NSMutableDictionary*)conversationToDictionary;
@end

@interface JMSGUser (JMessage)
-(NSMutableDictionary*)userToDictionary;
@end

@interface JMSGGroup (JMessage)
-(NSMutableDictionary*)groupToDictionary;
@end

@interface JMSGGroupMemberInfo (JMessage)
- (NSMutableDictionary *)memberToDictionary;
@end

@interface JMSGGroupInfo (JMessage)
-(NSMutableDictionary*)groupToDictionary;
@end

@interface JMSGMessage (JMessage)
- (NSMutableDictionary *)messageToDictionary;
@end

@interface JMSGChatRoom (JMessage)
- (NSMutableDictionary *)chatRoomToDictionary;
@end

@interface JMSGApplyJoinGroupEvent (JMessage)
- (NSMutableDictionary *)eventToDictionary;
@end

@interface JMSGGroupAdminRejectApplicationEvent (JMessage)
- (NSMutableDictionary *)eventToDictionary;
@end

@interface JMSGGroupAdminApprovalEvent (JMessage)
- (NSMutableDictionary *)eventToDictionary;
@end

@interface JMSGGroupNicknameChangeEvent (JMessage)
- (NSMutableDictionary *)eventToDictionary;
@end

