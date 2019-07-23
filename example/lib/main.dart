import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jmessage_flutter/jmessage_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';

const String kMockAppkey =  '你自己应用的 AppKey';
const String kMockUserName = '0001';
const String kMockPassword = '1111';

const String kMockGroupName = 'TESTGroupName';
const String kMockGroupDesc = 'TESTGroupDecs';

const String kMockTargetUserName = '0002';

// Target test data
final JMSingle kMockUser = JMSingle.fromJson({
            'username': kMockTargetUserName,
            'appKey': kMockAppkey
          });

const String kMockGroupId = '29033635';
final JMGroup kMockGroup = JMGroup.fromJson({
            'type': JMGroupType.private,
            'groupId': kMockGroupId
          });

const String kMockChatRoomid = '10003152';
final JMChatRoom kMockChatRoom = JMChatRoom.fromJson({
  'roomId': kMockChatRoomid
});

MethodChannel channel= MethodChannel('jmessage_flutter');
      JmessageFlutter jmessage = new JmessageFlutter.private(
            channel,
            const LocalPlatform());


void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    // initPlatformState();
    
    jmessage..setDebugMode(enable: true);
    jmessage.init(isOpenMessageRoaming: true, appkey: kMockAppkey);
    jmessage.applyPushAuthority(
        new JMNotificationSettingsIOS(
            sound: true,
            alert: true,
            badge: true)
    );

    // testAPIs();
    // testMediaAPis();s
    // print('setup jmessage');
//    testGetHistorMessage();
  }


  void register1() async {
    // 注册0001
    await jmessage.userRegister(username: kMockUserName, password: kMockPassword,nickname: "shikk1");
    await jmessage.login(username: kMockUserName, password: kMockPassword);
    await jmessage.updateMyInfo(gender:JMGender.female,extras: {"realName":"0001","age:":1,"student":false});
  }

  void register2() async{
    // 注册0002
    await jmessage.userRegister(username: "0002", password: kMockPassword,nickname: "shikk2");
    await jmessage.login(username: "0002", password: kMockPassword);
    await jmessage.updateMyInfo(gender: JMGender.male,extras: {"realName":"0002","age:":2,"student":true});
  }

  void loginUser1() async {
    await jmessage.login(username: "0001", password: kMockPassword);
  }
  void loginUser2() async {
    await jmessage.login(username: "0002", password: kMockPassword);
  }

  void getUserinfo(){
    jmessage.getUserInfo(username: "0001");
  }

  // 测试0001收到的历史消息
  void testGetHistorMessage() async{
    await jmessage.login(username: "0001", password: kMockPassword);
    JMSingle msg = JMSingle.fromJson({"username":"0002"});
    jmessage.getHistoryMessages(type: msg, from: 0, limit: 10).then((msgList){
      for(JMNormalMessage msg in msgList){
        print("shikk history msg ::   ${msg.toJson()}");
      }
    });

  }

  // 0002 向 0001 发消息
  void testSendCustomMsg() async{
    await jmessage.login(username: "0002", password: kMockPassword);
    JMSingle msg = JMSingle.fromJson({"username":"0001"});
    JMCustomMessage customMsg = await jmessage.createMessage(type: JMMessageType.custom, targetType: msg,customObject: {"aa":"aa","bb":"bb"});
    jmessage.sendCustomMessage(type: msg, customObject: customMsg.toJson());
  }

  // 0002 向 0001 发文字消息
  int index = 0;
  void testSendTextMsg() async{
    await jmessage.login(username: "0002", password: kMockPassword);
    JMSingle msg = JMSingle.fromJson({"username":"0001"});
    jmessage.sendTextMessage(type: msg,text: "msg queen index $index");
    index ++;
  }


  void addListener() async {
    print('add listener receive ReceiveMessage');
    await jmessage.login(username: kMockUserName,password: kMockPassword);
    // jmessage.setNoDisturbGlobal(isNoDisturb: false);

    jmessage.addReceiveMessageListener((msg) {//+
      print('receive ReceiveMessage ${msg.toJson()}');
      print('receive ReceiveMessage00 ${msg}');
      testGetHistorMessage();
      // verifyMessage(msg);
      if (msg is JMVoiceMessage) {
        // var type
        print('send voice message11');
        jmessage.sendVoiceMessage(
            type: msg.from.targetType,
            path: msg.path,
          ).then((JMVoiceMessage message) {
            // verifyMessage(message);
            print('send voice message success ${message.toJson()}');
          }).catchError((err) {
            print('send voice error ${err}');
          });
      }
      
      if (msg is JMImageMessage) {
        jmessage.sendImageMessage(
          type: msg.from.targetType,
          path: msg.thumbPath,
          
        ).then((JMImageMessage message) {
          print('send image success ${message.toJson()}');
          jmessage.updateMyAvatar(imgPath: msg.thumbPath);
          jmessage.updateGroupAvatar(
            id: kMockGroupId,
            imgPath: msg.thumbPath
          );
        }).catchError((err) {
          print('the error ${err}');
        });
      }

      if (msg is JMFileMessage) {

        jmessage.downloadFile(
          target: msg.from.targetType,
          messageId: msg.id,
        ).then((Map res) {

          jmessage.sendFileMessage(
            type: msg.from.targetType,
            path: res['filePath'],
            extras: {'fileType': 'video'}
          ).then((JMFileMessage message) {
            print('send file success ${message.toJson()}');
          }).catchError((err) {
            print('the error ${err}');
          });
        }).catchError((err) {
          print('download file error');
        });
      }

      print('send voice message22');
    });
    
    jmessage.addClickMessageNotificationListener((msg) {//+
      verifyMessage(msg);
      print('flutter receive event  receive addClickMessageNotificationListener ${msg.toJson()}');
    });

    jmessage.addSyncOfflineMessageListener((conversation,msgs) {
      print('receive offline message');
      verifyConversation(conversation);
      print('conversation ${conversation}');
      print('messages ${msgs}');
      
      for (dynamic msg in msgs) {
        print('msg ${msg}');
      }
      print('flutter receive event verify receive offline message done!');
    });

    jmessage.addSyncRoamingMessageListener((conversation) {
      verifyConversation(conversation);
      print('flutter receive event receive roaming message');
    });

    jmessage.addLoginStateChangedListener((JMLoginStateChangedType type) {
      print('flutter receive event receive login state change ${type}');
    });

    jmessage.addContactNotifyListener((JMContactNotifyEvent event) {
      print('flutter receive event contact notify ${event.toJson()}');
    });
    
    jmessage.addMessageRetractListener((msg) {
      print('flutter receive event message retract event');
      verifyMessage(msg);
    });


    jmessage.addReceiveChatRoomMessageListener((msgs) {//+
      msgs.map((msg) {
        verifyMessage(msg);
      });
      print('flutter receive event receive chat room message ');
    });

    jmessage.addReceiveTransCommandListener((JMReceiveTransCommandEvent event) {
      expect(event.message, isNotNull, reason: 'JMReceiveTransCommandEvent.message is null');
      expect(event.sender, isNotNull, reason: 'JMReceiveTransCommandEvent.sender is null');
      expect(event.receiver, isNotNull, reason: 'JMReceiveTransCommandEvent.receiver is null');
      expect(event.receiverType, isNotNull, reason: 'JMReceiveTransCommandEvent.receiverType is null');
      print('flutter receive event receive trans command');
    });
    
    jmessage.addReceiveApplyJoinGroupApprovalListener((JMReceiveApplyJoinGroupApprovalEvent event) {

      expect(event.eventId, isNotNull, reason: 'JMReceiveApplyJoinGroupApprovalEvent.eventId is null');
      expect(event.groupId, isNotNull, reason: 'JMReceiveApplyJoinGroupApprovalEvent.groupId is null');
      expect(event.isInitiativeApply, isNotNull, reason: 'JMReceiveApplyJoinGroupApprovalEvent.isInitiativeApply is null');
      expect(event.sendApplyUser, isNotNull, reason: 'JMReceiveApplyJoinGroupApprovalEvent.sendApplyUser is null');
      expect(event.joinGroupUsers, isNotNull, reason: 'JMReceiveApplyJoinGroupApprovalEvent.joinGroupUsers is null');
      expect(event.reason, isNotNull, reason: 'JMReceiveApplyJoinGroupApprovalEvent.reason is null');      
      print('flutter receive event receive apply jocin group approval');
    });
    
    jmessage.addReceiveGroupAdminRejectListener((JMReceiveGroupAdminRejectEvent event) {
      expect(event.groupId, isNotNull, reason: 'JMReceiveGroupAdminRejectEvent.groupId is null');
      verifyUser(event.groupManager);
      expect(event.reason, isNotNull, reason: 'JMReceiveGroupAdminRejectEvent.reason is null');
      print('flutter receive event receive group admin rejected');
    });
    
    jmessage.addReceiveGroupAdminApprovalListener((JMReceiveGroupAdminApprovalEvent event) {
      expect(event.isAgree, isNotNull, reason: 'addReceiveGroupAdminApprovalListener.isAgree is null');
      expect(event.applyEventId, isNotNull, reason: 'addReceiveGroupAdminApprovalListener.applyEventId is null');
      expect(event.groupId, isNotNull, reason: 'addReceiveGroupAdminApprovalListener.groupId is null');
      
      expect(event.isAgree, isNotNull, reason: 'addReceiveGroupAdminApprovalListener.isAgree is null');
      
      verifyUser(event.groupAdmin);
      for (var user in event.users) {
        verifyUser(user);
      }
      print('flutter receive event receive group admin approval');

    });
    
  }

// addReceiveMessageListener
// addClickMessageNotificationListener
// addSyncOfflineMessageListener
// addSyncRoamingMessageListener
// addLoginStateChangedListener
// addContactNotifyListener
// addMessageRetractListener
// addReceiveTransCommandListener
// removeReceiveTransCommandListener
// addReceiveChatRoomMessageListener
// addReceiveApplyJoinGroupApprovalListener
// addReceiveGroupAdminRejectListener
// addReceiveGroupAdminApprovalListener
  void testSendMessageAPIs() async {
    // test('sendTextMessage', () async {
    //       JMTextMessage msg = await jmessage.sendTextMessage(
    //         type: kMockUser,
    //         text: 'Text Message Test!',
    //       );
    //       verifyMessage(msg);
    //     });

        test('sendImageMessage', () async {
        // TODO: send prepare image file
          JMImageMessage msg = await jmessage.sendImageMessage(
            type: kMockUser,
            path: '',
          );
          verifyMessage(msg);

          // TODO: test download media
          //downloadThumbImage
          //downloadOriginalImage
    
        });

        test('sendVoiceMessage', () async {
          // TODO: send prepare voice file
          JMVoiceMessage msg = await jmessage.sendVoiceMessage(
            type: kMockGroup,
            path: '',
          );
          verifyMessage(msg);
          // TODO: test download media
          //downloadVoiceFile
        });

        test('sendCustomMessage', () async {
          JMCustomMessage msg = await jmessage.sendCustomMessage(
            type: kMockGroup,
            customObject: {'customKey1': 'customValue1'}
          );
          verifyMessage(msg);
        });

        test('sendLocationMessage', () async {
          // JMLocationMessage msg = await jmessage.sendVoiceMessage(
          //   type: kMockUser
          // )
          // verifyMessage(msg);
        });

        test('sendFileMessage', () async {
          // JMFileMessage msg = await jmessage.sendFileMessage(
          //   type: kMockUser,
          // );
          // verifyMessage(msg);


          // await jmessage.retractMessage(
          //   type: kMockUser,
          //   messageId: msg.id
          // );
          
          // TODO: test Download file
          //downloadFile
        });
        test('retractMessage', () async {
          
          JMTextMessage msg = await jmessage.sendTextMessage(
            type: kMockUser,
            text: 'Text Message Test!',
          );

          await jmessage.retractMessage(
            type: kMockUser,
            messageId: msg.id
          );
        });
  }

  void testMediaAPis() async {
        test('updateMyAvatar', () async {
          // TODO:
        });

        test('updateGroupAvatar', () async {
          // TODO:
        });
  }

  void testHandleRequest() async {
// TODO: Handle request
    test('acceptInvitation', () async {});

    test('declineInvitation', () async {});

    test('removeFromFriendList', () async {
      // await jmessage.removeFromFriendList(
      //   username: kMockTargetUserName,
      // );
    });
  }

  void testAPIs() async {

    await jmessage.login(username: kMockUserName,password: kMockPassword);
    group('$JmessageFlutter', () {
      // JmessageFlutter jmessage = JmessageFlutter();

      setUp(() async {
        // TEST: Event
        // jmessage.addClickMessageNotificationListener(callback)
      });
      
      // jmessage.login(username: kMockUserName,password: kMockPassword).then((res) {

      // }
      // );

        

        // TODO: TEST: register
        //   await jmessage.userRegister({username: });  
        
        // test('getMyInfo', () async {
        //   final JMUserInfo user = await jmessage.getMyInfo();
        //   print('the user info: ${user.toJson()}');
        //   verifyUser(user);
        //   print('test   getMyInfo success');
        // });

        test('setBadge', () async {
          // Must success
          await jmessage.setBadge(badge: 5);
          print('test   setBadge success');
        });


        // test('getUserInfo', () async {
        //   final JMUserInfo user = await jmessage.getUserInfo(username: '0002');
        //   print(user.toJson());
        //   verifyUser(user);
        //   print('test    getUserInfo success');
        // });

        test('updateMyPassword', () async {
          await jmessage.updateMyPassword(oldPwd: kMockPassword,newPwd: kMockPassword);
          print('test    updateMyPassword success');
        });
        
        test('updateMyInfo', () async {
          JMGender _gender = JMGender.male;
          Map _extras = {'aa': 'aaa', 'key1': 'value1'};
          await jmessage.updateMyInfo(

            birthday:new DateTime.now().millisecondsSinceEpoch,
            gender: _gender,
            extras: _extras
            );
          
          final JMUserInfo user = await jmessage.getMyInfo();
          // expect(user.extras, _extras);
          expect(user.gender, _gender);
          print('test    updateMyInfo success');
          print(user.toJson());

        });

        
        test('createGroup', () async {
          String gid = await jmessage.createGroup(
              groupType: JMGroupType.private,
              name: kMockGroupName,
              desc: kMockGroupDesc
            );
          expect(gid, isNotNull);
          
          Map res = await jmessage.downloadThumbGroupAvatar(id: gid);
          expect(res['id'], isNotNull,reason: 'downloadThumbGroupAvatar id is null');
          expect(res['filePath'], isNotNull, reason: 'downloadThumbGroupAvatar filePath is null');
          

          Map originRes = await jmessage.downloadOriginalGroupAvatar(id: gid);
          expect(originRes['id'], isNotNull,reason: 'downloadOriginalGroupAvatar id is null');
          expect(originRes['filePath'], isNotNull, reason: 'downloadOriginalGroupAvatar filePath is null');
          print('test    createGroup success');
        });

        

        test('createConversation', () async {
          
          // User
          print('test    create conversation single');
          JMConversationInfo singleConversation = await jmessage.createConversation(target: kMockUser);//@required dynamic target, //(JMSingle | JMGroup | JMChatRoom)
          verifyConversation(singleConversation);
          // Group
          print('test    create conversation group');
          JMConversationInfo groupConversation = await jmessage.createConversation(target: kMockGroup);
          verifyConversation(groupConversation);
          print('test    create conversation group1');
          // ChatRoom
          JMConversationInfo chatRoomConversation  = await jmessage.createConversation(target: kMockChatRoom);
          print('test    create conversation chatRoom');
          verifyConversation(chatRoomConversation);
          print('test    createConversation done');
        });

        test('setConversationExtras', () async {
          JMConversationInfo singleConversation = await jmessage.createConversation(target: kMockUser);//@required dynamic target, //(JMSingle | JMGroup | JMChatRoom)
          verifyConversation(singleConversation);

          print('test    setConversationExtras');
          JMConversationInfo conversationInfo = await jmessage.setConversationExtras(
            type: kMockUser,
            extras: {'extrasKey1': 'extrasValue'}
            );
          verifyConversation(conversationInfo);
          print('test    setConversationExtras done');
        });


        test('getHistoryMessages', () async {
          List msgs = await jmessage.getHistoryMessages(
            type: kMockUser,
            from: 0,
            limit: 20
          );

          for (var msg in msgs) {
            verifyMessage(msg);  
            print('test   getHistoryMessages the message: ${msg.toJson()}');
          }

          print('test   getHistoryMessages done');
        });

        test('getMessageById', () async {
          print('test getMessageById');
          JMTextMessage msg = await jmessage.sendTextMessage(
            type: kMockUser,
            text: 'Text Message Test!',
            // extras: {'messageKey1': 'messageValue2'},
            // sendOption: JMMessageSendOptions.fromJson({
            //   'isShowNotification': true, 
            //   'isRetainOffline': true,
            // })
          );
          print('test getMessageById :send text message succes');
          var message = await jmessage.getMessageById(
            type: kMockUser,
            messageId: msg.id
          );
          verifyMessage(message);
          print('test   getMessageById done');
        });

        test('deleteMessageById', () async {
          JMTextMessage msg = await jmessage.sendTextMessage(
            type: kMockUser,
            text: 'Text Message Test!',
          );
          await jmessage.deleteMessageById(
            type: kMockUser,
            messageId: msg.id
          );

          print('test   deleteMessageById done');
        });

        test('sendInvitationRequest', () async {
          // await jmessage.sendInvitationRequest(
          //   username: kMockTargetUserName,
          //   reason: 'hi~'
          // );

          // print('test   sendInvitationRequest done');
        });

        test('updateFriendNoteName', () async {
          await jmessage.updateFriendNoteName(
            username: kMockTargetUserName,
            noteName: 'test   update FriendNoteName'
          );

          print('test   updateFriendNoteName done');
        });

        test('updateFriendNoteText', () async {
          await jmessage.updateFriendNoteText(
            username: kMockTargetUserName,
            noteText: 'test   update FriendNoteText'
          );

          print('test   updateFriendNoteText done');
        });

        test('getFriends', () async {
          List friends = await jmessage.getFriends();
          friends.map((user) {
            verifyUser(user);
          });

          print('test   getFriends done');
        });

        test('getGroupIds', () async {
          List gids = await jmessage.getGroupIds();
          gids.map((gid) {
            expect(gid, isNotNull);
          });

          print('test   getIds done');
        });

        test('updateGroupInfo', () async {
          const String kMockNewName = 'the new name';
          const String kMockNewDesc = 'the new desc';
          await jmessage.updateGroupInfo(
            id: kMockGroupId,
            newName: kMockNewName,
            newDesc: kMockNewDesc
          );

          JMGroupInfo group = await jmessage.getGroupInfo(id: kMockGroupId);
          expect(group.name, kMockNewName, reason: 'the group name udpate failed');
          expect(group.desc, kMockNewDesc, reason: 'the group name desc failed');
          print('test   updateGroupInfo done');
        });

        test('addGroupMembers', () async {
          await jmessage.addGroupMembers(
            id: kMockGroupId,
            usernameArray: ['0002','0003'],
          );
          print('test   addGroupMembers done');
        });

        test('removeGroupMembers', () async {
          // TODO:
          // jmessage.removeGroupMembers(
          //   id: kMockGroupId,
          //   usernameArray: ['0002', '0003'],
          // );
        });

        test('exitGroup', () async {
          // dart operation
          // await jmessage.exitGroup(
          //   id: kMockGroupId
          // );
          // print('test   exitGroup done');
        });

        test('getGroupMembers', () async {
          List groups = await jmessage.getGroupMembers(
            id: kMockGroupId
          );

          groups.map((groupMember) {
            verifyGroupMember(groupMember);
          });
          print('test   getGroupMembers done');
        });

        test('addUsersToBlacklist', () async {
          await jmessage.addUsersToBlacklist(
            usernameArray: ['0006'],
          );
          print('test   addUsersToBlacklist done');
        });

        test('removeUsersFromBlacklist', () async {
          await jmessage.removeUsersFromBlacklist(
            usernameArray: ['0006'],
          );
          print('test   removeUsersFromBlacklist done');
        });

        test('getBlacklist', () async {
          List users = await jmessage.getBlacklist();
          users.map((user) {
            verifyUser(user);
          });
          print('test   getBlacklist done');
        });

        test('setNoDisturb', () async {
          await jmessage.setNoDisturb(
            target: kMockUser,
            isNoDisturb: false
          );

          await jmessage.setNoDisturb(
            target: kMockUser,
            isNoDisturb: true
          );

          print('test   setNoDisturb done');
        });

        test('getNoDisturbList', () async {
          
          Map res = await jmessage.getNoDisturbList();
          expect(res['userInfos'], isNotNull, reason: 'getNoDisturbList userInfos is null');
          expect(res['groupInfos'], isNotNull, reason: 'getNoDisturbList groupInfos is null');

          List userInfos = res['userInfos'];
          userInfos.map((user) {
            verifyUser(user);
          });
          
          List groupInfos = res['groupInfos'];
          groupInfos.map((group) {
            verifyGroupInfo(group);
          });
          print('test   getNoDisturbList done');
        });

        test('setNoDisturbGlobal', () async {
          await jmessage.setNoDisturbGlobal(isNoDisturb: true);
          bool isNoDisturb = await jmessage.isNoDisturbGlobal();
          expect(isNoDisturb, true);

          await jmessage.setNoDisturbGlobal(isNoDisturb: false);
          isNoDisturb = await jmessage.isNoDisturbGlobal();
          expect(isNoDisturb, false);

          print('test   setNoDisturbGlobal done');
        });

        test('blockGroupMessage', () async {
          await jmessage.blockGroupMessage(
            id: kMockGroupId,
            isBlock: true
          );

          bool res = await jmessage.isGroupBlocked(id: kMockGroupId);
          expect(res, true);

          await jmessage.blockGroupMessage(
            id: kMockGroupId,
            isBlock: false
          );

          res = await jmessage.isGroupBlocked(id: kMockGroupId);
          expect(res, false);
          print('test   blockGroupMessage done');
        });

        test('getBlockedGroupList', () async {
          List groups = await jmessage.getBlockedGroupList();
          groups.map((group) {
            verifyGroupInfo(group);
          });

          print('test   getBlockedGroupList done');
        });

        test('downloadThumbUserAvatar', () async {
          Map resJson = await jmessage.downloadThumbUserAvatar(
            username: kMockUserName
          );
          expect(resJson['username'], isNotNull);
          expect(resJson['appKey'], isNotNull);
          expect(resJson['filePath'], isNotNull);
          print('test   downloadThumbUserAvatar done');
        });

        test('downloadOriginalUserAvatar', () async {
          Map resJson = await jmessage.downloadThumbUserAvatar( username: kMockUserName );
          expect(resJson['username'], isNotNull);
          expect(resJson['appKey'], isNotNull);
          expect(resJson['filePath'], isNotNull);
          print('test   downloadOriginalUserAvatar done');
        });

        // test('deleteConversation', () async {
        //   await jmessage.deleteConversation(
        //     target: kMockUser
        //   );
        //   await jmessage.createConversation(target: kMockUser);
        // });

        test('enterConversation', () {
          jmessage.enterConversation(target: kMockUser);
          jmessage.exitConversation(target: kMockUser);
          print('test   enterConversation done');
        });

        test('getConversation', () async {
          JMConversationInfo conversation = await jmessage.getConversation(target: kMockUser);
          verifyConversation(conversation);
          print('test   getConversation done ');
        });

        test('getConversations', () async {
          List conversations = await jmessage.getConversations();
          conversations.map((conv) {
            verifyConversation(conv);
          });

          print('test   getConversations done ');
        });

        test('resetUnreadMessageCount', () async {
          await jmessage.resetUnreadMessageCount(target: kMockUser);
        });

        test('transferGroupOwner', () async {
          // TODO:
          // NOTE: dart
          // await jmessage.transferGroupOwner(
          //   groupId: kMockGroupId,
          //   username: '0002',
          //   );
        });

        test('setGroupMemberSilence', () async {
          print('flutter test setGroupMemberSilence');
          await jmessage.setGroupMemberSilence(
            groupId: kMockGroupId,
            isSilence: true,
            username: '0002',
          );
          print('flutter setGroupMemberSilence done');

          bool isSilenceMember = await jmessage.isSilenceMember(
            groupId: kMockGroupId,
            username: '0002'
          );
          print('flutter isSilenceMember done');


          expect(isSilenceMember, true, reason: 'isSilenceMember is not true');

          await jmessage.setGroupMemberSilence(
            groupId: kMockGroupId,
            isSilence: false,
            username: '0002',
          );

          isSilenceMember = await jmessage.isSilenceMember(
            groupId: kMockGroupId,
            username: '0002'
          );

          expect(isSilenceMember, false, reason: 'isSilenceMember is not false');
          print('flutter test setGroupMemberSilence isSilenceMember done');
        });

        test('groupSilenceMembers', () async {
          List members = await jmessage.groupSilenceMembers(groupId: kMockGroupId);
          members.map((user) {
            verifyUser(user);
          });
        });

        test('setGroupNickname', () async {
          const String kMockgroupNickName = 'newGroupMemberNickName';
          await jmessage.setGroupNickname(
            groupId: kMockGroupId,
            username: '0002',
            nickName: kMockgroupNickName
          );

          List<JMGroupMemberInfo> groups = await jmessage.getGroupMembers(id: kMockGroupId);
          groups.map((groupMember) {
            verifyGroupMember(groupMember);
            if (groupMember.user.username == '0002') {
              expect(groupMember.groupNickname, kMockgroupNickName);
            }
          });
        });

        test('enterChatRoom', () async {
          await jmessage.enterChatRoom(roomId: kMockChatRoomid);
        });

        test('exitChatRoom', () async {
          await jmessage.exitChatRoom(roomId: kMockChatRoomid);
        });

        test('getChatRoomConversation', () async {
          JMConversationInfo conv = await jmessage.getChatRoomConversation(roomId: kMockChatRoomid);
          verifyConversation(conv);
        });

        test('getChatRoomConversationList', () async {
          List<JMConversationInfo>conversations = await jmessage.getChatRoomConversationList();
          conversations.map((conv) {
            verifyConversation(conv);
          });
          print('test   getChatRoomConversationList done ');
        });

        test('getAllUnreadCount', () async {
          num allUnreadCount = await jmessage.getAllUnreadCount();
          expect(allUnreadCount, isNotNull);
        });

        test('addGroupAdmins', () async {
          await jmessage.addGroupAdmins(
            groupId: kMockGroupId,
            usernames: ['0002'],
          );

          List<JMGroupMemberInfo> groups = await jmessage.getGroupMembers(id: kMockGroupId);
          groups.map((groupMember) {
            verifyGroupMember(groupMember);
            if (groupMember.user.username == '0002') {
              expect(groupMember.memberType, JMGroupMemberType.admin);
            }
          });

          await jmessage.removeGroupAdmins(
            groupId: kMockGroupId,
            usernames: ['0002'],
          );

          groups = await jmessage.getGroupMembers(id: kMockGroupId);
          groups.map((groupMember) {
            verifyGroupMember(groupMember);
            if (groupMember.user.username == '0002') {
              expect(groupMember.memberType, JMGroupMemberType.ordinary);
            }
          });
        });

        test('changeGroupType', () async {
          await jmessage.changeGroupType(
            groupId: kMockGroupId,
            type: JMGroupType.public
          );

          await jmessage.changeGroupType(
            groupId: kMockGroupId,
            type: JMGroupType.private
          );
        });

        test('getPublicGroupInfos', () async {
          List groups= await jmessage.getPublicGroupInfos(
            appKey: kMockAppkey,
            start: 0,
            count: 20,
          );

          groups.map((group) {
            verifyGroupInfo(group);
          });
          print('get group info success');
        });

        test('applyJoinGroup', () async {
          // await jmessage.applyJoinGroup(
          //   groupId: kMockGroupId
          // );
        });

        test('processApplyJoinGroup', () async {
          // await jmessage.processApplyJoinGroup(
          //   events: [],
          //   isAgree: true,
          //   isRespondInviter: true,
          // );
        });

        test('dissolveGroup', () async {
          // await jmessage.dissolveGroup(groupId: kMockGroupId);
        });

        test('logout', () async {
          // await jmessage.logout();
        });


    });

    //processApplyJoinGroup
    //dissolveGroup
    // logout
  }


  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('JMessage Plugin App'),
        ),
        body: new Center(
          child: new Column(
            children: <Widget>[
              new Text('Running Unit test... \n'),
              new FlatButton(onPressed: (){
                register1();
              }, child: new Text("0001 测试注册用户")),
              new FlatButton(onPressed: () {
                loginUser1();
              }, child: new Text("0001 登录")),
              new FlatButton(onPressed: (){
                testGetHistorMessage();
              }, child: new Text("0001 获取收到的历史消息")),
              new Text('============================== \n'),
              new FlatButton(onPressed: (){
                register2();
              }, child: new Text("0002 测试注册用户")),
              new FlatButton(onPressed: () {
                loginUser2();
              }, child: new Text("0002 登录")),
              new FlatButton(onPressed: (){
                testSendCustomMsg();
              }, child: new Text("0002 测试向0001 发送自定义消息")),
              new FlatButton(onPressed: (){
                testSendTextMsg();
              }, child: new Text("0002 测试向0001 发送文字消息")),
              new Text('============================== \n'),
              new FlatButton(onPressed: (){
                addListener();
              }, child: new Text("添加消息监听")),
            ],
          ),
        ),
      ),
    );
  }
}


void verifyUser(JMUserInfo user) {
  expect(user, isNotNull, reason: 'user');
  expect(user.username, isNotNull, reason: 'user.username');
  expect(user.appKey, isNotNull, reason: 'user.appkey');
  expect(user.nickname, isNotNull, reason: 'user.nickname');
  expect(user.avatarThumbPath, isNotNull, reason: 'user.avatarThumbPath');
  expect(user.birthday, isNotNull, reason: 'user.birthday');
  expect(user.region, isNotNull, reason: 'user.region');
  expect(user.signature, isNotNull, reason: 'user.signature');
  expect(user.address, isNotNull, reason: 'user.address');
  expect(user.noteName, isNotNull, reason: 'user.noteName');
  expect(user.noteText, isNotNull, reason: 'user.noteText');
  expect(user.isNoDisturb, isNotNull, reason: 'user.isNoDisturb');
  expect(user.isInBlackList, isNotNull, reason: 'user.isInBlackList');
  expect(user.isFriend, isNotNull, reason: 'user.isFriend');
  expect(user.extras, isNotNull, reason: 'user.extras');
}

void verifyGroupInfo(JMGroupInfo group) {
  expect(group, isNotNull,reason: 'group is null');
  expect(group.id, isNotNull,reason: 'group id is null');
  expect(group.name, isNotNull,reason: 'group name is null');
  expect(group.desc, isNotNull,reason: 'group desc is null');
  expect(group.level, isNotNull,reason: 'group level is null');
  expect(group.owner, isNotNull,reason: 'group owner is null');
  expect(group.ownerAppKey, isNotNull,reason: 'group ownerAppKey is null');
  expect(group.maxMemberCount, isNotNull,reason: 'group maxMemberCount is null');
  expect(group.isNoDisturb, isNotNull,reason: 'group isNoDisturb is null');
  expect(group.isBlocked, isNotNull,reason: 'group isBlocked is null');
}

void verifyGroupMember(JMGroupMemberInfo groupMember) {
  expect(groupMember, isNotNull);
  expect(groupMember.groupNickname, isNotNull);
  expect(groupMember.joinGroupTime, isNotNull);
  verifyUser(groupMember.user);
}

void verifyConversation(JMConversationInfo conversation) {
  expect(conversation, isNotNull,reason: 'conversation is null');
  expect(conversation.conversationType, isNotNull, reason: 'conversation conversationType is null');
  expect(conversation.title, isNotNull, reason: 'conversation title is null');
  expect(conversation.unreadCount, isNotNull, reason: 'conversation unreadCount is null');
  expect(conversation.target, isNotNull, reason: 'conversation target is null');
  
  // do not test lastMessage, if conversation do not have lastmessage it will be null 
  // expect(conversation.latestMessage, isNotNull, reason: 'conversation conversationType is null');
}

void verifyMessage(dynamic msg) {
  expect(msg.id, isNotNull, reason: 'message id is null');
  expect(msg.serverMessageId, isNotNull, reason: 'serverMessageId id is null');
  expect(msg.isSend, isNotNull, reason: 'message isSend is null');
  expect(msg.createTime, isNotNull, reason: 'message createTime is null');
  expect(msg.extras, isNotNull, reason: 'message extras is null');
  expect(msg.from, isNotNull, reason: 'message from is null');
  verifyUser(msg.from);

  expect(msg.target, isNotNull, reason: 'message from is null');
  if (msg.target is JMUserInfo) {
    verifyUser(msg.target);
  }
  if (msg.target is JMGroupInfo) {
    verifyGroupInfo(msg.target);
  }
}
