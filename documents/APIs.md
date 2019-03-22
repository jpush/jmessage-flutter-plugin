# API

#### Usage
```dart
import 'package:jmessage_flutter/jmessage_flutter.dart';

JmessageFlutter JMessage = JmessageFlutter();
```

- [初始化](#初始化)
  - [init](#init)
  - [setDebugMode](#setdebugmode)
  - [setBadge](#setbadge)
- [用户登录、注册及属性维护](#用户登录注册及属性维护)
  - [userRegister](#userregister)
  - [login](#login)
  - [logout](#logout)
  - [getMyInfo](#getmyinfo)
  - [getUserInfo](#getuserinfo)
  - [updateMyPassword](#updatemypassword)
  - [updateMyAvatar](#updatemyavatar)
  - [updateMyInfo](#updatemyinfo)
  - [downloadThumbUserAvatar](#downloadthumbuseravatar)
  - [downloadOriginalUserAvatar](#downloadoriginaluseravatar)
- [群组](#群组)
  - [createGroup](#creategroup)
  - [addGroupAdmins](#addgroupadmins)
  - [removeGroupAdmins](#removegroupadmins)
  - [changeGroupType](#changegrouptype)
  - [getPublicGroupInfos](#getpublicgroupinfos)
  - [applyJoinGroup](#applyjoingroup)
  - [processApplyJoinGroup](#processapplyjoingroup)
  - [dissolveGroup](#dissolvegroup)
  - [getGroupIds](#getgroupids)
  - [getGroupInfo](#getgroupinfo)
  - [getGroupMembers](#getgroupmembers)
  - [updateGroupInfo](#updategroupinfo)
  - [addGroupMembers](#addgroupmembers)
  - [removeGroupMembers](#removegroupmembers)
- [聊天](#聊天)
  - [createMessage](#createmessage)
  - [sendMessage](#sendmessage)
  - [sendTextMessage](#sendtextmessage)
  - [sendImageMessage](#sendimagemessage)
  - [sendVoiceMessage](#sendvoicemessage)
  - [sendCustomMessage](#sendcustommessage)
  - [sendLocationMessage](#sendlocationmessage)
  - [sendFileMessage](#sendfilemessage)
  - [retractMessage](#retractmessage)
  - [getHistoryMessages](#gethistorymessages)
  - [downloadOriginalImage](#downloadoriginalimage)
  - [downloadThumbImage](#downloadthumbimage)
  - [downloadVoiceFile](#downloadvoicefile)
  - [downloadFile](#downloadfile)
- [会话](#会话)
  - [createConversation](#createconversation)
  - [deleteConversation](#deleteconversation)
  - [enterConversation](#enterconversation)
  - [exitConversation](#exitconversation)
  - [getConversation](#getconversation)
  - [getConversations](#getconversations)
  - [getAllUnreadCount](#getallunreadcount)
  - [resetUnreadMessageCount](#resetunreadmessagecount)
- [聊天室](#聊天室)
  - [getChatRoomListByApp](#getchatroomlistbyapp)
  - [getChatRoomListByUser](#getchatroomlistbyuser)
  - [getChatRoomInfos](#getchatroominfos)
  - [getChatRoomOwner](#getchatroomowner)
  - [enterChatRoom](#enterchatroom)
  - [leaveChatRoom](#leavechatroom)
  - [getChatRoomConversationList](#getchatroomconversationlist)
- [好友](#好友)
  - [sendInvitationRequest](#sendinvitationrequest)
  - [acceptInvitation](#acceptInvitation)
  - [declineInvitation](#declineinvitation)
  - [getFriends](#getfriends)
  - [removeFromFriendList](#removefromfriendlist)
  - [updateFriendNoteName](#updatefriendnotename)
  - [updateFriendNoteText](#updatefriendnotetext)
- [事件监听]()
  - [消息事件](#addreceivemessagelistener)
    - [addReceiveMessageListener](#addreceivemessagelistener)
    - [removeReceiveMessageListener](#addreceivemessagelistener)
    - [addReceiveChatRoomMsgListener](#addreceivechatroommsglistener)
    - [removeReceiveChatRoomMsgListener](#removereceivechatroommsglistener)
  - [离线消息](#addsyncofflinemessagelistener)
    - [addSyncOfflineMessageListener](#addsyncofflinemessagelistener)
    - [removeSyncOfflineMessageListener](#addsyncofflinemessagelistener)
  - [消息漫游](#addsyncroamingmessagelistener)
    - [addSyncRoamingMessageListener](#addsyncroamingmessagelistener)
    - [removeSyncRoamingMessageListener](#addsyncroamingmessagelistener)
  - [好友请求事件](#addcontactnotifylistener)
    - [addContactNotifyListener](#addcontactnotifylistener)
    - [removeContactNotifyListener](#addcontactnotifylistener)
  - [接收到消息撤回事件](#addmessageretractlistener)
    - [addMessageRetractListener](#addmessageretractlistener)
    - [removeMessageRetractListener](#addmessageretractlistener)
  - [登录状态变更](#addloginstatechangedlistener)
    - [addLoginStateChangedListener](#addloginstatechangedlistener)
    - [removeLoginStateChangedListener](#addloginstatechangedlistener)
  - [监听接收入群申请事件](#addreceiveapplyjoingroupapprovallistener)
    - [addReceiveApplyJoinGroupApprovalListener](#addreceiveapplyjoingroupapprovallistener)
    - [removeReceiveApplyJoinGroupApprovalListener](#removereceiveapplyjoingroupapprovallistener)
  - [监听管理员拒绝入群申请事件](#addreceivegroupadminrejectlistener)
    - [addReceiveGroupAdminRejectListener](#addreceivegroupadminrejectlistener)
    - [removeReceiveGroupAdminRejectListener](#removereceivegroupadminrejectlistener)
  - [监听管理员同意入群申请事件](#addreceivegroupadminapprovallistener)
    - [addReceiveGroupAdminApprovalListener](#addreceivegroupadminapprovallistener)
    - [removeReceiveGroupAdminApprovalListener](#removereceivegroupadminapprovallistener)


- [点击消息通知事件（Android Only）](#addclickmessagenotificationlistener)
  - [addClickMessageNotificationListener](#addclickmessagenotificationlistener)
  - [removeClickMessageNotificationListener](#addclickmessagenotificationlistener)

## 初始化

### init

**注意 Android 仍需在 build.gradle 中配置 appKey，具体可以[参考这个文件](https://github.com/jpush/jmessage-react-plugin/blob/dev/example/android/app/build.gradle)**
初始化插件。建议在应用起始页的构造函数中调用。

#### 示例

```dart
JMessage.init(isOpenMessageRoaming: true, appkey: kMockAppkey);
```

#### 参数说明

- appkey：极光官网注册的应用 AppKey。**Android 仍需配置 app 下 build.gradle 中的 AppKey。**
- isOpenMessageRoaming：是否开启消息漫游，不传默认关闭。
- isProduction：是否为生产模式。
- channel：(选填)应用的渠道名称。

### setDebugMode

设置是否开启 debug 模式，开启后 SDK 将会输出更多日志信息，推荐在应用对外发布时关闭。

#### 示例

```dart
JMessage.setDebugMode( enable: true );
```

#### 参数说明

- enable：为 true 打开 Debug 模式，false 关闭 Debug 模式。

### setBadge

设置 badge 值，该操作会设置本地应用的 badge 值，同时设置极光服务器的 badge 值，收到消息 badge +1 会在极光服务器 badge 的基础上累加。

#### 示例

```dart
await JMessage.setBadge(badge: 5);
```

## 用户登录、注册及属性维护

### userRegister

用户注册。

#### 示例

```dart
// 注册
await JMessage.userRegister(
  username: "登录用户名",
  password: "登录密码"
);
```

#### 参数说明

- username: 用户名。在应用中用于唯一标识用户，必须唯一。支持以字母或者数字开头，支持字母、数字、下划线、英文点（.）、减号、@。长度限制：Byte(4~128)。
- password: 用户密码。不限制字符。长度限制：Byte(4~128)。
- nickname: 昵称

### login

```dart
// 登录
await JMessage.login({
  username: "登录用户名",
  password: "登录密码"
});
```

#### 参数说明

- username: 用户名。
- password: 用户密码。

### logout

用户登出。

#### 示例

```dart
JMessage.logout();
```

### getMyInfo

获取当前登录用户信息。如果未登录返回的 user 对象里面的数据为空，例如 user.username 为空。可以用于判断用户登录状态

#### 示例

```dart
JMUserInfo user = await JMessage.getMyInfo();
```

### getUserInfo

获取用户信息。该接口可以获取不同 AppKey 下（即不同应用）的用户信息，如果 AppKey 为空，则默认为当前应用下。

#### 示例

```dart
JMUserInfo user = await JMessage.getUserInfo( username: 'username', appKey: 'your_app_key' );
```

### updateMyPassword

更新当前登录用户的密码。

#### 示例

```dart
await JMessage.updateMyPassword( oldPwd: 'old_password', newPwd: 'new_password' );
```

### updateMyAvatar

更新当前登录用户的头像。

#### 示例

```dart
await JMessage.updateMyAvatar( imgPath: 'img_local_path' );
```

#### 参数说明

- imgPath: 本地图片文件的绝对路径地址。注意在 Android 6.0 及以上版本系统中，需要动态请求 `WRITE_EXTERNAL_STORAGE` 权限。
  两个系统中的图片路径分别类似于：
  - Android：`/storage/emulated/0/DCIM/Camera/IMG_20160526_130223.jpg`
  - iOS：`/var/mobile/Containers/Data/Application/7DC5CDFF-6581-4AD3-B165-B604EBAB1250/tmp/photo.jpg`

### updateMyInfo

更新当前登录用户信息。包括了：昵称（nickname）、生日（birthday）、个性签名（signature）、性别（gender）、地区（region）和具体地址（address）。

#### 示例

```dart
await JMessage.updateMyInfo( nickname: 'nickname' );
```

#### 参数说明

- nickname: 昵称。不支持字符 "\n" 和 "\r"；长度限制：Byte (0~64)。
- birthday: (Number)生日日期的毫秒数。

### downloadThumbUserAvatar

下载用户头像缩略图。

#### 示例

```dart
Map resJson = await JMessage.downloadThumbUserAvatar(
  username: 'theUserName'，
  appKey: 'you appKey');
resJson = {
      'username': 'user name ',
      'appKey': 'appKey',
      'filePath': 'filePath'
    };
```

#### 参数说明：

- username (string): 用户名
- appKey (string): 不传默认是本应用 appkey。


- resJson (Map):
  - username (string): 用户名
  - appKey (string):
  - filePath (string): 下载后的图片路径（本地路径）

### downloadOriginalUserAvatar

下载用户头像原图。

#### 示例

```dart
const param = {
  username: 'theUserName'，
  appKey: 'you appKey'
}
Map resJson = await JMessage.downloadOriginalUserAvatar(  
  username: 'theUserName'，
  appKey: 'you appKey'
);

resJson = {
      'username': 'user name ',
      'appKey': 'appKey',
      'filePath': 'filePath'
    };
```

#### 参数说明：

- username (string): 用户名
- appKey (string): 不传默认是本应用 appkey。
- result (object):
  - username (string): 用户名
  - appKey (string):
  - filePath (string): 下载后的图片路径

## 群组

### createGroup

创建群组。

#### 示例

```dart
JMessage.createGroup( name: 'group_name', desc: 'group_desc' );
```

#### 参数说明

- name (string): 群组名。不支持 "\n" 和 "\r" 字符，长度限制为 0 ~ 64 Byte。
- groupType (string): 指定创建群的类型，可以为 'private' 和 'public', 默认为 private。
- desc (string): 群组描述。长度限制为 0 ~ 250 Byte。

### dissolveGroup

解散群

#### 示例

```dart
await JMessage.dissolveGroup( groupId: 'group_id' );
```

#### 参数说明

- groupId (string): 要解散的群组 id。

### getGroupIds

获取当前用户群组

#### 示例

```dart
List<String> gids = await JMessage.getGroupIds();
```

#### 参数说明

无

### getGroupInfo

根据群组id获取群组信息

#### 示例

```dart
JMessage.getGroupInfo( id: "1234567" )
```

#### 参数说明

- id(string): 指定群组

### getGroupMembers

获取群成员。

#### 示例

```dart
List<JMGroupMemberInfo>members =  await JMessage.getGroupMembers( id: 'groupId');
```

### updateGroupInfo

更新群组信息。

#### 示例

```dart
await JMessage.updateGroupInfo( id: 'groupId' ,newName: 'group_name', newDesc: 'group_desc' );
```

#### 参数说明

- id (string): 指定操作的群 groupId
- newName (string): 群组名。不支持 "\n" 和 "\r" 字符，长度限制为 0 ~ 64 Byte。
- newDesc (string): 群组描述。长度限制为 0 ~ 250 Byte。

### addGroupMembers

批量添加群成员

#### 示例

```dart
await JMessage.addGroupAdmins( 
  id: 'group_id', 
  usernames: ['ex_username1', 'ex_username2'], 
  appKey: 'appkey' 
);
```

#### 参数说明

- id: 指定操作的群 groupId
- usernames: 被添加的的用户名数组。
- appKey: 被添加用户所属应用的 AppKey。如果不填，默认为当前应用。

### removeGroupMembers

批量删除群成员

#### 示例

```dart
await JMessage.removeGroupMembers(
  id: 'group_id', 
  usernames: ['ex_username1', 'ex_username2'], 
  appKey: 'appkey' );
```

#### 参数说明

- id : 指定操作的群 groupId
- username : 被添加的的用户名数组。
- appKey: 被添加用户所属应用的 AppKey。如果不填，默认为当前应用。

### addGroupAdmins

批量添加管理员

#### 示例

```dart
await JMessage.addGroupAdmins(
  groupId: 'group_id', 
  usernames: ['ex_username1', 'ex_username2'] 
)；
```

#### 参数说明

- groupId (string): 指定操作的群 groupId。
- usernames : 被添加的的用户名数组。

### removeGroupAdmins

批量删除管理员

#### 示例

```dart
await JMessage.removeGroupAdmins( 
  groupId: 'group_id', 
  usernames: ['ex_username1', 'ex_username2'] 
)；
```

#### 参数说明

- groupId (string): 指定操作的群 groupId。
- usernames : 被移除的的用户名数组。

### changeGroupType

修改群类型

#### 示例

```dart
await JMessage.changeGroupType( 
  groupId: 'group_id', 
  type: 'public'
)；
```

#### 参数说明

- groupId (string): 指定操作的群 groupId。
- type : 公有群（类似 QQ 群进群需要管理员以上人员审批），私有群（类似微信群直接邀请就能进）。

### getPublicGroupInfos

分页获取指定 appKey 下的共有群

#### 示例

```dart
List<JMGroupInfo> groups = await JMessage.getPublicGroupInfos( 
  appKey: 'my_appkey', 
  start: 0, 
  count: 20 
)；
```

#### 参数说明

- appKey (string): 获取指定 appkey
- start (int): 开始的位置
- count (int): 获取的数量

### applyJoinGroup

申请入群（公开群）

#### 示例

```dart
await JMessage.applyJoinGroup(
  groupId: 'group_id',
  reason: 'Hello I from ...' 
);
```

#### 

### processApplyJoinGroup

批量处理入群（公开群）申请

#### 示例

```dart
await JMessage.processApplyJoinGroup( 
  events: ['ex_event_id_1', 'ex_event_id_2'], 
  reason: 'Hello I from ...' 
  }
);
```

#### 参数说明

- events (array<string>): eventId 数组,当有用户申请入群的时候(或者被要求)会回调一个 event(通过 addReceiveApplyJoinGroupApprovalListener 监听)，每个 event 会有个 id，用于审核入群操作。
- reason (string): 入群理由。

## 聊天

### createMessage

创建消息，创建好消息后需要调用 [sendMessage](#sendMessage) 来发送消息。如果需要状态更新（发送中 -> 发送完成）可以使用这种方式，聊天室不支持该接口。

```dart
var message = await jmessage.createMessage(
          type: JMMessageType.image,
          targetType: msg.from.targetType,
          path: msg.thumbPath,
          extras: {"key1": "value1"}
        );
```

- type: 不同的消息类型需要不同的参数。
  - type = text 时 `text` 为必填。
  - type = image 时 `path` 为必填。
  - type = voice 时 `path` 为必填。
  - type = file 时 `path` 为必填。
  - type = location 时 `latitude` `longitude` 和 `scale` 为必填，`address` 选填。
  - type = custom 时 `customObject` 为必填。

### sendMessage

与 [createMessage](#createMessage) 配合使用，用于发送创建好的消息。

```dart
var message = await jmessage.createMessage(
          type: JMMessageType.image,
          targetType: msg.from.targetType,
          path: msg.thumbPath,
          extras: {"key1": "value1"}
        );
  
var sendedMessage = await jmessage.sendMessage(
          message: message,
          sendOption: JMMessageSendOptions.fromJson({
              'isShowNotification': true, 
              'isRetainOffline': true,
          })
        );
```



### sendTextMessage

发送文本消息。

#### 示例

```dart
JMTextMessage msg = await JMessage.sendTextMessage(
            type: kMockUser,
            text: 'Text Message Test!',
          );
```

#### 参数说明

- type: 会话类型。可以为 (JMSingle | JMGroup | JMChatRoom)。
- text: 消息内容。
- extras (Map<String, String>): 自定义键值对，value 必须为字符串类型。
- messageSendingOptions: 消息发送配置参数。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### sendImageMessage

发送图片消息，在收到消息时 SDK 默认会自动下载缩略图，如果要下载原图，需调用 `downloadOriginalImage` 方法。

#### 示例

```dart
JMessage.sendImageMessage(
          type: msg.from.targetType,
          path: msg.thumbPath,
        )
```

#### 参数说明

- type: 会话类型。可以为  (JMSingle | JMGroup | JMChatRoom)。
- path: 本地图片的绝对路径。格式分别类似为：
  - Android：`/storage/emulated/0/DCIM/Camera/IMG_20160526_130223.jpg`
  - iOS：`/var/mobile/Containers/Data/Application/7DC5CDFF-6581-4AD3-B165-B604EBAB1250/tmp/photo.jpg`
- extras: 自定义键值对，value 必须为字符串类型。
- sendingOptions: 消息发送配置参数。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### sendVoiceMessage

发送语音消息，在收到消息时 SDK 默认会自动下载语音文件，如果下载失败（即语音消息文件路径为空），可调用 `downloadVoiceFile` 手动下载。

#### 示例

```dart
jmessage.sendVoiceMessage(
            type: msg.from.targetType,
            path: msg.path,
          )
```

#### 参数说明

- type: 会话类型。可以为 (JMSingle | JMGroup | JMChatRoom)。
- path: 本地音频文件的绝对路径。
- extras (Map<String,String>): 自定义键值对，key 、value 必须为字符串类型。
- sendingOptions: 消息发送配置参数。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### sendCustomMessage

发送自定义消息。

#### 示例

```dart
JMCustomMessage msg = await JMessage.sendCustomMessage(
            type: kMockGroup,
            customObject: {'customKey1': 'customValue1'}
          );
```

#### 参数说明

- type: 会话类型。可以为 (JMSingle | JMGroup | JMChatRoom)。
- customObject: 自定义键值对，`value` 必须为字符串类型。
- sendingOptions: 消息发送配置参数。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### sendLocationMessage

发送地理位置消息，通常需要配合地图插件使用。

#### 示例

```dart
JMLocationMessage msg = await jmessage.sendVoiceMessage(
            type: kMockUser,
  	   longitude: kmockgitude,
        latitude: kmocklatitude
          )
```

#### 参数说明

- type: 会话类型。可以为  (JMSingle | JMGroup | JMChatRoom)。
- latitude: 纬度。
- longitude: 经度。
- scale: 地图缩放比例。
- address: 详细地址。
- extras: 自定义键值对，value 必须为字符串类型。
- sendingOptions: 消息发送配置参数。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### sendFileMessage

发送文件消息。对方在收到文件消息时 SDK 不会自动下载，下载文件需手动调用 `downloadFile` 方法。

#### 示例

```dart
JMFileMessage msg = await jmessage.sendFileMessage(
            type: kMockUser,
            path: kMockFilePath,
          );
```

#### 参数说明

- type: 会话类型。可以为   (JMSingle | JMGroup | JMChatRoom)。
- path: 本地文件的绝对路径。
- extras: 自定义键值对，value 必须为字符串类型。
- sendingOptions: 消息发送配置参数。支持的属性：
  - isShowNotification: 接收方是否针对此次消息发送展示通知栏通知。默认为 `true`。
  - isRetainOffline: 是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。默认为 `true`。
  - isCustomNotificationEnabled: 是否开启自定义接收方通知栏功能，设置为 `true` 后可设置下面的 `notificationTitle` 和 `notificationText`。默认未设置。
  - notificationTitle: 设置此条消息在接收方通知栏所展示通知的标题。
  - notificationText: 设置此条消息在接收方通知栏所展示通知的内容。

### retractMessage

消息撤回。调用后被撤回方会收到一条 `retractMessage` 事件。并且双方的消息内容将变为不可见。

#### 示例

```dart
JMessage.retractMessage(
  type: kMockUser,
  messageId: 'target_msg_id'
);
```

#### 参数说明

- type: 会话类型。可以为 (JMSingle | JMGroup)。
- messageId: 要撤回的消息 id。

### getHistoryMessages

从最新的消息开始获取历史消息。

#### 示例

```dart
JMessage.getHistoryMessages(
  type: kMockUser,
  from: 0,
  limit: 10 
);
```

#### 参数说明

- type: 会话类型。可以为 (JMSingle | JMGroup)。

- from: 第一条消息对应的下标，起始为 0。

- limit: 消息数。当 from = 0 并且 limit = -1 时，返回所有的历史消息。

  ​

### downloadOriginalImage

下载图片消息原图。如果已经下载，会直接返回本地文件路径，不会重复下载。

#### 示例

```dart
JMessage.downloadOriginalImage(
  type: kMockUser, 
  messageId: 'target_msg_id' 
  });
```

#### 参数说明

- type: 会话类型。可以为 (JMSingle | JMGroup | JMChatRoom)。
- messageId: 图片消息 id。

### downloadThumbImage

下载图片消息缩略图。如果已经下载，会直接返回本地文件路径，不会重复下载。

#### 示例

```dart
Map resJson = await JMessage.downloadThumbImage(
  type: kMockUser,
  messageId: 'target_msg_id' 
  });
  
  resJson == {
      'messageId': resJson['messageId'],
      'filePath': resJson['filePath']
    }
```

#### 参数说明

- type: 会话类型。可以为 (JMSingle | JMGroup | JMChatRoom)。
- username: 对方用户的用户名。当 `type` 为 'single' 时，`username` 为必填。
- appKey: 对方用户所属应用的 AppKey。如果不填，默认为当前应用。
- groupId: 对象群组 id。当 `type` 为 'group' 时，`groupId` 为必填。
- messageId: 图片消息 id。

### downloadVoiceFile

下载语音文件。如果已经下载，会直接返回本地文件路径，不会重复下载。

### 示例

```dart
Map resJson = await JMessage.downloadVoiceFile(
  type: kMockUser,
  messageId: 'target_msg_id'
);
  resJson == {
      'messageId': resJson['messageId'],
      'filePath': resJson['filePath']
    }
```

#### 参数说明

- type: 会话类型。可以为 (JMSingle | JMGroup)。
- messageId: 语音消息 id。

### downloadFile

下载文件。如果已经下载，会直接返回本地文件路径，不会重复下载。

#### 示例

```dart
Map resJson = await JMessage.downloadFile(
  type: kMockUser, 
  messageId: 'target_msg_id' 
  );

  resJson == {
      'messageId': resJson['messageId'],
      'filePath': resJson['filePath']
    }
```

#### 参数说明

- type: 会话类型。可以为 (JMSingle | JMGroup)。
- messageId: 文件消息 id。

## 会话

### createConversation

创建会话。

#### 示例

```dart
JMConversationInfo conversation = await JMessage.createConversation(
	target：kMockUser
  );
```

#### 参数说明

- target: 会话类型。可以为 (JMSingle | JMGroup | JMChatRoom)。

### deleteConversation

删除聊天会话，同时也会删除本地聊天记录。

#### 示例

```dart
await JMessage.deleteConversation(
	target：kMockUser
  );
```

#### 参数说明

- target: 会话类型。可以为 (JMSingle | JMGroup | JMChatRoom)。

### enterConversation

**(Android only)** 进入聊天会话。当调用后，该聊天会话的消息将不再显示通知。

iOS 默认应用在前台时，就不会显示通知。

#### 示例

```dart
await JMessage.enterConversation(
	target：kMockUser
  );
```

#### 参数说明

- target: 会话类型。可以为 (JMSingle | JMGroup | JMChatRoom)。

### exitConversation

**(Android only)** 退出当前聊天会话。调用后，聊天会话之后的相关消息通知将会被触发。

#### 示例

```dart
await JMessage.exitConversation(
	target：kMockUser
  );
```

### getConversation

获取聊天会话对象。

#### 示例

```dart
JMConversationInfo conversation = await jmessage.getConversation(target: kMockUser);
```

#### 参数说明

- target: 会话类型。可以为 (JMSingle | JMGroup | JMChatRoom)。

### getConversations

从本地数据库获取会话列表。默认按照会话的最后一条消息时间降序排列。

#### 示例

```dart
List<JMConversationInfo> conversations = await JMessage.getConversations();
```

### getAllUnreadCount

当前用户所有会话的未读消息总数

- ⚠️  截止jmessage-sdk-2.6.1 返回的数量为会话列表的未读总数即包括了被移除的群组、好友的未读.

#### 示例

```dart
num unreadCount = await JMessage.getAllUnreadCount();
```

#### 

### resetUnreadMessageCount

重置会话的未读消息数。

#### 示例

```dart
await JMessage.resetUnreadMessageCount(
    target: kMockuser
  );
```

#### 参数说明

- target: 会话类型。可以为 (JMSingle | JMGroup | JMChatRoom)。

## 聊天室

#### 注意： 聊天室相关 api 功能还不完整，建议先不要添加相关功能。

### enterChatRoom

进入聊天室，进入后才能收到聊天室信息及发言。

#### 示例

```dart
await JMessage.enterChatRoom({ roomId: 'Example_RoomId_1'},
  (conversation) => { // 进入聊天室，会自动创建并返回该聊天室会话信息。
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- roomId：要进入的聊天室的 id。

### exitChatRoom

离开指定聊天室。

#### 示例

```dart
await JMessage.leaveChatRoom({ roomId: 'Example_RoomId_1'},
  () => {
    // do something.

  }, (error) => {
    var code = error.code
    var desc = error.description
  })
```

#### 参数说明

- roomId：要离开的聊天室的 id。

### getChatRoomConversationList

从本地获取用户的聊天室会话列表，没有则返回为空的列表。

#### 示例

```dart
List<JMConversationInfo> conversations = await JMessage.getChatRoomConversationList()；
```



## 好友

JMessage 好友模块仅实现对用户好友关系的托管，以及相关好友请求的发送与接收。
除此之外更多的功能，比如仅允许好友间聊天需要开发者自行实现。

### sendInvitationRequest

发送添加好友请求，调用后对方会收到 [好友事件](#addcontactnotifylistener) 事件。

#### 示例

```dart
JMessage.sendInvitationRequest( 
  username: 'username',
  appKey: 'appKey',
  reason: '请求添加好友'
);
```

#### 参数说明

- username: 对方用户的用户名。
- appKey: 对方用户所属应用的 AppKey，如果为空则默认为当前应用。
- reason: 申请理由。

### acceptInvitation

接受申请好友请求，调用后对方会收到 [好友事件](#addcontactnotifylistener) 事件。

#### 示例

```dart
await JMessage.acceptInvitation(
  username: 'username',
  appKey: 'appKey' 
);
```

#### 参数说明

- username: 申请发送用户的用户名。
- appKey: 申请发送用户所在应用的 AppKey。

### declineInvitation

拒绝申请好友请求，调用成功后对方会收到 [好友事件](#addcontactnotifylistener) 事件。

#### 示例

```dart
await JMessage.declineInvitation(
  username: 'username',
  appKey: 'appKey',
  reason: '拒绝理由'
);
```

#### 参数说明

- username: 申请发送用户的用户名。
- appKey: 申请发送用户所在应用的 AppKey。
- reason: 拒绝理由。长度要求为 0 ~ 250 Byte。

### getFriends

获取好友列表。

#### 示例

```dart
List<JMUserInfo> users = await JMessage.getFriends();
```

### removeFromFriendList

删除好友，调用成功后对方会收到 [好友事件](#addcontactnotifylistener) 事件。

#### 示例

```dart
await JMessage.removeFromFriendList(
  username: 'username',
  appKey: 'appKey' 
);
```

### updateFriendNoteName

更新好友备注名。

#### 示例

```dart
await JMessage.updateFriendNoteName(
  username: 'username',
  appKey: 'appKey',
  noteName: 'noteName' 
  );
```

#### 参数说明

- username: 好友的用户名。
- appKey: 好友所属应用的 AppKey，如果为空默认为当前应用。
- noteName: 备注名。不支持 "\n" 和 "\r" 字符，长度要求为 0 ~ 64 Byte。

### updateFriendNoteText

更新用户备注信息。

#### 示例

```dart
await JMessage.updateFriendNoteText(
  username: 'username',
  appKey: 'appKey',
  noteText: 'noteName'
 )
```

#### 参数说明

- username: 好友的用户名。
- appKey: 好友所属应用的 AppKey，如果为空默认为当前应用。
- noteText: 备注名。长度要求为 0 ~ 250 Byte。

## 事件监听

### 消息事件

#### addReceiveMessageListener

添加消息事件的监听。

##### 示例

```dart

JMessage.addReceiveMessageListener(listener) // 添加监听
JMessage.removeReceiveMessageListener(listener) // 移除监听
```

#### addReceiveChatRoomMsgListener

添加聊天室消息事件的监听。

##### 示例

```dart
JMessage.addReceiveChatRoomMsgListene(listener) // 添加监听
JMessage.removeReceiveChatRoomMsgListener(listener) // 移除监听
```

#### addSyncOfflineMessageListener

同步离线消息事件监听。

##### 示例

```dart
JMessage.addSyncOfflineMessageListener(listener) // 添加监听
JMessage.removeSyncOfflineMessageListener(listener) // 移除监听
```

##### 回调参数

- callbackResult
  - conversation：离线消息所在的会话
  - messageArray：指定会话中的离线消息

#### addSyncRoamingMessageListener

同步漫游消息事件监听。

##### 示例

```dart
JMessage.addSyncRoamingMessageListener(listener) // 添加监听
JMessage.removeSyncRoamingMessageListener(listener) // 移除监听
```

##### 回调参数

- callbackResult
  - conversation：漫游消息所在的会话。

#### addMessageRetractListener

消息撤回事件监听。

##### 示例

```dart
JMessage.addMessageRetractListener(listener) // 添加监听
JMessage.removeMessageRetractListener(listener) // 移除监听
```

##### 回调参数

- event
  - conversation: 会话对象
  - retractedMessage：被撤回的消息对象

#### addClickMessageNotificationListener

点击消息通知回调（Android Only，iOS 端可以使用 jpush-react-native 插件的，监听点击推送的事件）。

##### 示例

```dart
JMessage.addClickMessageNotificationListener(listener) // 添加监听
JMessage.removeClickMessageNotificationListener(listener) // 移除监听
```

##### 回调参数

- message: 可以是 JMTextMessage | JMVoiceMessage | JMImageMessage | JMFileMessage | JMEventMessage | JMCustomMessage;

### 好友事件

#### addContactNotifyListener

好友相关通知事件。

##### 示例

```dart
JMessage.addContactNotifyListener(listener) // 添加监听
JMessage.removeContactNotifyListener(listener) // 移除监听
```

##### 回调参数

- event
  - type：'invite_received' / 'invite_accepted' / 'invite_declined' / 'contact_deleted'
  - reason：事件发生的理由，该字段由对方发起请求时所填，对方如果未填则返回默认字符串。
  - fromUsername： 事件发送者的 username。
  - fromUserAppKey： 事件发送者的 AppKey。

### 登录状态事件

#### addLoginStateChangedListener

登录状态变更事件，例如在其他设备登录把当前设备挤出，会触发这个事件。

##### 示例

```dart
JMessage.addLoginStateChangedListener(listener) // 添加监听
JMessage.removeMessageRetractListener(listener) // 移除监听
```

##### 回调参数

- type: JMLoginStateChangedType。

### 群组事件

#### addReceiveApplyJoinGroupApprovalListener

监听接收入群申请事件

##### 示例

```dart

JMessage.addReceiveApplyJoinGroupApprovalListener(listener) // 添加监听
JMessage.removeReceiveApplyJoinGroupApprovalListener(listener) // 移除监听
```

##### 回调参数说明

- event： JMReceiveApplyJoinGroupApprovalEvent
  - eventId (string)：消息 id。
  - groupId (string)：申请入群的 groudId。
  - isInitiativeApply (boolean)：是否是用户主动申请入群，YES：主动申请加入，NO：被邀请加入
  - sendApplyUser (JMUserInfo)：发送申请的用户
  - reason (string)：入群原因

#### addReceiveGroupAdminRejectListener

监听管理员拒绝入群申请事件

##### 示例

```dart
JMessage.addReceiveGroupAdminRejectListener(listener) // 添加监听
JMessage.removeReceiveGroupAdminRejectListener(listener) // 移除监听
```

##### 回调参数说明

- event: JMReceiveGroupAdminRejectEvent
  - eventId (string): 消息 id。
  - rejectReason (string): 拒绝原因。
  - groupManager (JMUserInfo): 操作的管理员

#### addReceiveGroupAdminApprovalListener

监听管理员同意入群申请事件

##### 示例

```dart
JMessage.addReceiveGroupAdminApprovalListener(listener) // 添加监听
JMessage.removeReceiveGroupAdminApprovalListener(listener) // 移除监听
```

##### 回调参数说明

- event: JMReceiveGroupAdminApprovalEvent
  - isAgreeApply (boolean): 管理员是否同意申请，YES：同意，NO：拒绝.
  - applyEventID (string): 申请入群事件的事件 id.
  - groupId (string): 群 gid.
  - groupAdmin (JMGroupInfo): 操作的管理员.
  - users [JMUserInfo]: 申请或被邀请加入群的用户，即：实际入群的用户