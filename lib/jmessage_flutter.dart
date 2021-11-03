import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';

final String flutterLog = "| JMessage | Flutter | ";

T getEnumFromString<T>(Iterable<T> values, String str) {
  return values.firstWhere((f) => f.toString().split('.').last == str,
      orElse: null);
}

String? getStringFromEnum<T>(T) {
  if (T == null) {
    return null;
  }
  return T.toString().split('.').last;
}

/// iOS 通知设置项
class JMNotificationSettingsIOS {
  final bool sound;
  final bool alert;
  final bool badge;

  const JMNotificationSettingsIOS({
    this.sound = true,
    this.alert = true,
    this.badge = true,
  });

  Map<String, dynamic> toMap() {
    return <String, bool>{'sound': sound, 'alert': alert, 'badge': badge};
  }
}

/// 函数回调
typedef JMCallback = void Function(dynamic a, dynamic b);

/// 点击通知栏

// message 和 retractedMessage 可能是 JMTextMessage | JMVoiceMessage | JMImageMessage | JMFileMessage | JMEventMessage | JMCustomMessage;
typedef JMMessageEventListener = void Function(dynamic message);
typedef JMSyncOfflineMessageListener = void Function(
    JMConversationInfo conversation, List<dynamic> messageArray);
typedef JMSyncRoamingMessageListener = void Function(
    JMConversationInfo conversation);
typedef JMLoginStateChangedListener = void Function(
    JMLoginStateChangedType type);
typedef JMContactNotifyListener = void Function(JMContactNotifyEvent event);
typedef JMMessageRetractListener = void Function(dynamic retractedMessage);
typedef JMReceiveTransCommandListener = void Function(
    JMReceiveTransCommandEvent event);
typedef JMReceiveChatRoomMessageListener = void Function(
    List<dynamic> messageList);
typedef JMReceiveApplyJoinGroupApprovalListener = void Function(
    JMReceiveApplyJoinGroupApprovalEvent event);
typedef JMReceiveGroupAdminRejectListener = void Function(
    JMReceiveGroupAdminRejectEvent event);
typedef JMReceiveGroupAdminApprovalListener = void Function(
    JMReceiveGroupAdminApprovalEvent event);
typedef JMMessageReceiptStatusChangeListener = void Function(
    JMConversationInfo conversation, List<String> serverMessageIdList);

class JMEventHandlers {
  static final JMEventHandlers _instance = new JMEventHandlers._internal();

  JMEventHandlers._internal();

  factory JMEventHandlers() => _instance;

  /// 收到：消息
  List<JMMessageEventListener> receiveMessage = [];

  /// 收到：离线消息
  List<JMSyncOfflineMessageListener> syncOfflineMessage = [];

  /// 收到：漫游消息
  List<JMSyncRoamingMessageListener> syncRoamingMessage = [];

  /// 收到：聊天室消息
  Map<String, JMReceiveChatRoomMessageListener> receiveChatRoomMessageMap =
      Map();

  /// 收到：登录状态发生变更
  List<JMLoginStateChangedListener> loginStateChanged = [];

  /// 收到：好友事件
  List<JMContactNotifyListener> contactNotify = [];

  /// 收到：触发通知栏点击事件
  List<JMMessageEventListener> clickMessageNotification = [];

  /// 收到：透传命令
  List<JMReceiveTransCommandListener> receiveTransCommand = [];

  /// 收到：申请入群请求
  List<JMReceiveApplyJoinGroupApprovalListener> receiveApplyJoinGroupApproval =
      [];

  /// 收到：管理员拒绝事件
  List<JMReceiveGroupAdminRejectListener> receiveGroupAdminReject = [];

  /// 收到：管理员审核事件
  List<JMReceiveGroupAdminApprovalListener> receiveGroupAdminApproval = [];

  /// 收到：消息已读回执事件
  List<JMMessageReceiptStatusChangeListener> receiveReceiptStatusChangeEvents =
      [];

  /// 收到：消息撤回事件
  List<JMMessageRetractListener> retractMessage = [];
}

class JmessageFlutter {
  static final JmessageFlutter _instance = new JmessageFlutter.private(
      const MethodChannel('jmessage_flutter'), const LocalPlatform());

  factory JmessageFlutter() => _instance;

  final MethodChannel _channel;
  final Platform _platform;
  final JMEventHandlers _eventHanders = new JMEventHandlers();

  @visibleForTesting
  JmessageFlutter.private(MethodChannel channel, Platform platform)
      : _channel = channel,
        _platform = platform;

  // Events
  addReceiveMessageListener(JMMessageEventListener callback) {
    _eventHanders.receiveMessage.add(callback);
  }

  removeReceiveMessageListener(JMMessageEventListener callback) {
    _eventHanders.receiveMessage.removeWhere((cb) => cb == callback);
  }

  addClickMessageNotificationListener(JMMessageEventListener callback) {
    _eventHanders.clickMessageNotification.add(callback);
  }

  removeClickMessageNotificationListener(JMMessageEventListener callback) {
    _eventHanders.clickMessageNotification.removeWhere((cb) => cb == callback);
  }

  addSyncOfflineMessageListener(JMSyncOfflineMessageListener callback) {
    _eventHanders.syncOfflineMessage.add(callback);
  }

  removeSyncOfflineMessageListener(JMSyncOfflineMessageListener callback) {
    _eventHanders.syncOfflineMessage.removeWhere((cb) => cb == callback);
  }

  addSyncRoamingMessageListener(JMSyncRoamingMessageListener callback,
      {String? id}) {
    _eventHanders.syncRoamingMessage.add(callback);
  }

  removeSyncRoamingMessageListener(JMSyncRoamingMessageListener callback) {
    _eventHanders.syncRoamingMessage.removeWhere((cb) => cb == callback);
  }

  addLoginStateChangedListener(JMLoginStateChangedListener callback) {
    _eventHanders.loginStateChanged.add(callback);
  }

  removeLoginStateChangedListener(JMLoginStateChangedListener callback) {
    _eventHanders.loginStateChanged.removeWhere((cb) => cb == callback);
  }

  addContactNotifyListener(JMContactNotifyListener callback) {
    _eventHanders.contactNotify.add(callback);
  }

  removeContactNotifyListener(JMContactNotifyListener callback) {
    _eventHanders.contactNotify.removeWhere((cb) => cb == callback);
  }

  addMessageRetractListener(JMMessageRetractListener callback) {
    _eventHanders.retractMessage.add(callback);
  }

  removeMessageRetractListener(JMMessageRetractListener callback) {
    _eventHanders.retractMessage.removeWhere((cb) => cb == callback);
  }

  addReceiveTransCommandListener(JMReceiveTransCommandListener callback) {
    _eventHanders.receiveTransCommand.add(callback);
  }

  removeReceiveTransCommandListener(JMReceiveTransCommandListener callback) {
    _eventHanders.receiveTransCommand.removeWhere((cb) => cb == callback);
  }

  addReceiveChatRoomMessageListener(
      String? listenerID, JMReceiveChatRoomMessageListener callback) {
    if (listenerID == null) {
      print(flutterLog + "'listenerID' is can not be null.");
      return;
    }
    _eventHanders.receiveChatRoomMessageMap[listenerID] = callback;
  }

  removeReceiveChatRoomMessageListener(String? listenerID) {
    if (listenerID != null) {
      _eventHanders.receiveChatRoomMessageMap.remove(listenerID);
    }
  }

  addReceiveApplyJoinGroupApprovalListener(
      JMReceiveApplyJoinGroupApprovalListener callback) {
    _eventHanders.receiveApplyJoinGroupApproval.add(callback);
  }

  removeReceiveApplyJoinGroupApprovalListener(
      JMReceiveApplyJoinGroupApprovalListener callback) {
    _eventHanders.receiveApplyJoinGroupApproval
        .removeWhere((cb) => cb == callback);
  }

  addReceiveGroupAdminRejectListener(
      JMReceiveGroupAdminRejectListener callback) {
    _eventHanders.receiveGroupAdminReject.add(callback);
  }

  removeReceiveGroupAdminRejectListener(
      JMReceiveGroupAdminRejectListener callback) {
    _eventHanders.receiveGroupAdminReject.removeWhere((cb) => cb == callback);
  }

  addReceiveGroupAdminApprovalListener(
      JMReceiveGroupAdminApprovalListener callback) {
    _eventHanders.receiveGroupAdminApproval.add(callback);
  }

  removeReceiveGroupAdminApprovalListener(
      JMReceiveGroupAdminApprovalListener callback) {
    _eventHanders.receiveGroupAdminApproval.removeWhere((cb) => cb == callback);
  }

  addReceiveMessageReceiptStatusChangelistener(
      JMMessageReceiptStatusChangeListener callback) {
    _eventHanders.receiveReceiptStatusChangeEvents.add(callback);
  }

  removeMessageReceiptStatusChangelistener(
      JMMessageReceiptStatusChangeListener callback) {
    _eventHanders.receiveReceiptStatusChangeEvents
        .removeWhere((cb) => cb == callback);
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> _handleMethod(MethodCall call) async {
    print("handleMethod method = ${call.method}");
    switch (call.method) {
      case 'onReceiveMessage':
        for (JMMessageEventListener cb in _eventHanders.receiveMessage) {
          cb(JMNormalMessage.generateMessageFromJson(
              call.arguments.cast<dynamic, dynamic>()));
        }
        break;
      case 'onRetractMessage':
        for (JMMessageRetractListener cb in _eventHanders.retractMessage) {
          cb(JMNormalMessage.generateMessageFromJson(
              call.arguments.cast<dynamic, dynamic>()['retractedMessage']));
        }
        break;
      case 'onLoginStateChanged':
        for (JMLoginStateChangedListener cb
            in _eventHanders.loginStateChanged) {
          String type = call.arguments.cast<dynamic, dynamic>()['type'];
          JMLoginStateChangedType loginState =
              getEnumFromString(JMLoginStateChangedType.values, type);
          cb(loginState);
        }
        break;
      case 'onSyncOfflineMessage':
        for (JMSyncOfflineMessageListener cb
            in _eventHanders.syncOfflineMessage) {
          Map param = call.arguments.cast<dynamic, dynamic>();
          List msgDicArray = param['messageArray'];
//            List<dynamic> msgs = msgDicArray.map((json) => JMNormalMessage.generateMessageFromJson(json)).toList();

          List<dynamic> msgs = [];
          for (Map json in msgDicArray) {
            print("offline message: ${json.toString()}");
            JMNormalMessage normsg =
                JMNormalMessage.generateMessageFromJson(json);
            msgs.add(normsg);
          }

          cb(JMConversationInfo.fromJson(param['conversation']), msgs);
        }
        break;
      case 'onSyncRoamingMessage':
        for (JMSyncRoamingMessageListener cb
            in _eventHanders.syncRoamingMessage) {
          Map json = call.arguments.cast<dynamic, dynamic>();
          cb(JMConversationInfo.fromJson(json));
        }
        break;
      case 'onContactNotify':
        for (JMContactNotifyListener cb in _eventHanders.contactNotify) {
          Map json = call.arguments.cast<dynamic, dynamic>();
          cb(JMContactNotifyEvent.fromJson(json));
        }
        break;
      case 'onClickMessageNotification':
        for (JMMessageEventListener cb
            in _eventHanders.clickMessageNotification) {
          // TODO: only work in android
          Map json = call.arguments.cast<dynamic, dynamic>();
          cb(JMNormalMessage.generateMessageFromJson(json));
        }
        break;
      case 'onReceiveTransCommand':
        for (JMReceiveTransCommandListener cb
            in _eventHanders.receiveTransCommand) {
          Map json = call.arguments.cast<dynamic, dynamic>();
          JMReceiveTransCommandEvent ev =
              JMReceiveTransCommandEvent.fromJson(json);
          cb(ev);
        }
        break;
      case 'onReceiveChatRoomMessage':
        _eventHanders.receiveChatRoomMessageMap.forEach((key, value) {
          JMReceiveChatRoomMessageListener cb = value;
          List<dynamic> msgJsons = call.arguments.cast();
          List<dynamic> msgsList = msgJsons
              .map((json) => JMNormalMessage.generateMessageFromJson(json))
              .toList();
          cb(msgsList);
        });
        break;
      case 'onReceiveApplyJoinGroupApproval':
        for (JMReceiveApplyJoinGroupApprovalListener cb
            in _eventHanders.receiveApplyJoinGroupApproval) {
          Map json = call.arguments.cast<dynamic, dynamic>();
          JMReceiveApplyJoinGroupApprovalEvent e =
              JMReceiveApplyJoinGroupApprovalEvent.fromJson(json);
          cb(e);
        }
        break;
      case 'onReceiveGroupAdminReject':
        for (JMReceiveGroupAdminRejectListener cb
            in _eventHanders.receiveGroupAdminReject) {
          Map json = call.arguments.cast<dynamic, dynamic>();
          cb(JMReceiveGroupAdminRejectEvent.fromJson(json));
        }
        break;
      case 'onReceiveGroupAdminApproval':
        for (JMReceiveGroupAdminApprovalListener cb
            in _eventHanders.receiveGroupAdminApproval) {
          Map json = call.arguments.cast<dynamic, dynamic>();
          cb(JMReceiveGroupAdminApprovalEvent.fromJson(json));
        }
        break;
      case 'onReceiveMessageReceiptStatusChange':
        for (JMMessageReceiptStatusChangeListener cb
            in _eventHanders.receiveReceiptStatusChangeEvents) {
          Map param = call.arguments.cast<dynamic, dynamic>();
          List<String> serverMessageIdList = param['serverMessageIdList'];
          JMConversationInfo conversationInfo =
              JMConversationInfo.fromJson(param['conversation']);
          cb(conversationInfo, serverMessageIdList);
        }
        break;
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
    return;
  }

  void init({
    required bool? isOpenMessageRoaming,
    required String? appkey,
    String? channel,
    bool isProduction = false,
  }) {
    _channel.setMethodCallHandler(_handleMethod);

    _channel.invokeMethod(
        'setup',
        {
          'isOpenMessageRoaming': isOpenMessageRoaming,
          'appkey': appkey,
          'channel': channel,
          'isProduction': isProduction
        }..removeWhere((key, value) => value == null));
  }

  void setDebugMode({bool enable = false}) {
    _channel.invokeMethod('setDebugMode', {'enable': enable});
  }

  ///
  /// 申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
  ///
  void applyPushAuthority(
      [JMNotificationSettingsIOS iosSettings =
          const JMNotificationSettingsIOS()]) {
    if (!_platform.isIOS) {
      return;
    }
    _channel.invokeMethod('applyPushAuthority', iosSettings.toMap());
  }

  ///
  /// iOS Only
  /// 设置应用 Badge（小红点）
  ///
  /// @param {Int} badge
  ///
  Future<void> setBadge({required int? badge}) async {
    await _channel.invokeMethod('setBadge', {'badge': badge});
    return;
  }

  Future<void> userRegister(
      {required String? username,
      required String? password,
      String? nickname}) async {
    print("Action - userRegister: username=$username,pw=$password");
    await _channel.invokeMethod('userRegister',
        {'username': username, 'password': password, 'nickname': nickname});
  }

  /*
  * 登录
  * @return 用户信息，可能为 null
  * */
  Future<JMUserInfo?> login({
    required String? username,
    required String? password,
  }) async {
    if (username == null || password == null) {
      throw ("username or password was passed null");
    }
    print("Action - login: username=$username,pw=$password");

    Map? userJson = await _channel
        .invokeMethod('login', {'username': username, 'password': password});
    if (userJson == null) {
      return null;
    } else {
      return JMUserInfo.fromJson(userJson);
    }
  }

  Future<void> logout() async {
    await _channel.invokeMethod('logout');
  }

  Future<JMUserInfo?> getMyInfo() async {
    Map? userJson = await _channel.invokeMethod('getMyInfo');
    if (userJson == null) {
      return null;
    } else {
      return JMUserInfo.fromJson(userJson);
    }
  }

  Future<JMUserInfo> getUserInfo(
      {required String? username, String? appKey}) async {
    Map userJson = await _channel.invokeMethod(
        'getUserInfo',
        {'username': username, 'appKey': appKey}
          ..removeWhere((key, value) => value == null));
    return JMUserInfo.fromJson(userJson);
  }

  Future<void> updateMyPassword(
      {required String? oldPwd, required String? newPwd}) async {
    await _channel
        .invokeMethod('updateMyPassword', {'oldPwd': oldPwd, 'newPwd': newPwd});
    return;
  }

  Future<void> updateMyAvatar({required String? imgPath}) async {
    await _channel.invokeMethod('updateMyAvatar', {'imgPath': imgPath});
    return;
  }

  Future<void> updateMyInfo(
      {int? birthday,
      String? nickname,
      String? signature,
      String? region,
      String? address,
      JMGender? gender,
      Map<dynamic, dynamic>? extras}) async {
    await _channel.invokeMethod(
        'updateMyInfo',
        {
          'birthday': birthday,
          'nickname': nickname,
          'signature': signature,
          'region': region,
          'address': address,
          'gender': getStringFromEnum(gender),
          'extras': extras,
        }..removeWhere((key, value) => value == null));
    return;
  }

  Future<void> updateGroupAvatar(
      {required String? id, required String? imgPath}) async {
    await _channel.invokeMethod(
        'updateGroupAvatar',
        {
          'id': id,
          'imgPath': imgPath,
        }..removeWhere((key, value) => value == null));
    return;
  }

  Future<Map> downloadThumbGroupAvatar({
    required String? id,
  }) async {
    Map res = await _channel.invokeMethod(
        'downloadThumbGroupAvatar',
        {
          'id': id,
        }..removeWhere((key, value) => value == null));
    return res;
  }

  Future<Map> downloadOriginalGroupAvatar({
    required String? id,
  }) async {
    Map res = await _channel.invokeMethod(
        'downloadOriginalGroupAvatar',
        {
          'id': id,
        }..removeWhere((key, value) => value == null));
    return {'id': res['id'], 'filePath': res['filePath']};
  }

  Future<JMConversationInfo> setConversationExtras(
      {dynamic type,

      /// (JMSingle | JMGroup | JMChatRoom)
      Map<dynamic, dynamic>? extras}) async {
    var param = type.toJson();
    param['extras'] = extras;
    Map resMap = await _channel.invokeMethod('setConversationExtras',
        param..removeWhere((key, value) => value == null));
    var res = JMConversationInfo.fromJson(resMap);
    return res; // {id: string; filePath: string}
  }

  Future<dynamic> createMessage({
    required JMMessageType? type, // 消息类型
    required dynamic targetType,

    /// (JMSingle | JMGroup | JMChatRoom)
    String? text,
    String? path,
    String? fileName,
    Map<dynamic, dynamic>? customObject,
    double? latitude,
    double? longitude,
    int? scale,
    String? address,
    Map<dynamic, dynamic>? extras,
  }) async {
    Map param = targetType.toJson();

    if (extras != null) {
      param..addAll({'extras': extras});
    }

    param
      ..addAll({
        'messageType': getStringFromEnum(type),
        'text': text,
        'path': path,
        'fileName': fileName,
        'customObject': customObject,
        'latitude': latitude,
        'longitude': longitude,
        'scale': scale,
        'address': address,
      });

    Map resMap = await _channel.invokeMethod(
        'createMessage', param..removeWhere((key, value) => value == null));
    var res = JMNormalMessage.generateMessageFromJson(resMap);
    return res;
  }

  /// message 可能是 JMTextMessage | JMVoiceMessage | JMImageMessage | JMFileMessage | JMCustomMessage;
  /// NOTE: 不要传接收到的消息进去，只能传通过 createMessage 创建的消息。
  Future<dynamic> sendMessage(
      {required JMNormalMessage? message,
      JMMessageSendOptions? sendOption}) async {
    Map param = message?.target?.targetType.toJson();

    Map optionMap = {};

    if (sendOption != null) {
      optionMap = {
        'messageSendingOptions': sendOption.toJson()
          ..removeWhere((key, value) => value == null)
      };
    }

    param..addAll(optionMap)..addAll({'id': message?.id});
    Map resMap = await _channel.invokeMethod(
        'sendDraftMessage', param..removeWhere((key, value) => value == null));
    var res = JMNormalMessage.generateMessageFromJson(resMap);
    return res;
  }

  Future<JMTextMessage> sendTextMessage({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required String? text,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    Map param = type.toJson();
    Map optionMap = {};
    if (sendOption != null) {
      optionMap = {
        'messageSendingOptions': sendOption.toJson()
          ..removeWhere((key, value) => value == null)
      };
    }

    if (extras != null) {
      param..addAll({'extras': extras});
    }

    param..addAll(optionMap)..addAll({'text': text});

    Map resMap = await _channel.invokeMethod(
        'sendTextMessage', param..removeWhere((key, value) => value == null));
    var res = JMNormalMessage.generateMessageFromJson(resMap);
    return res;
  }

  Future<JMImageMessage> sendImageMessage({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required String? path,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    Map param = type.toJson();

    Map optionMap = {};
    if (sendOption != null) {
      optionMap = {
        'messageSendingOptions': sendOption.toJson()
          ..removeWhere((key, value) => value == null)
      };
    }

    if (extras != null) {
      param..addAll({'extras': extras});
    }

    param..addAll(optionMap)..addAll({'path': path});

    Map resMap = await _channel.invokeMethod(
        'sendImageMessage', param..removeWhere((key, value) => value == null));
    var res = JMNormalMessage.generateMessageFromJson(resMap);
    return res;
  }

  Future<JMVoiceMessage> sendVoiceMessage({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required String? path,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    Map param = type.toJson();

    Map optionMap = {};
    if (sendOption != null) {
      optionMap = {
        'messageSendingOptions': sendOption.toJson()
          ..removeWhere((key, value) => value == null)
      };
    }

    if (extras != null) {
      param..addAll({'extras': extras});
    }

    param..addAll(optionMap)..addAll({'path': path});

    Map resMap = await _channel.invokeMethod(
        'sendVoiceMessage', param..removeWhere((key, value) => value == null));
    var res = JMNormalMessage.generateMessageFromJson(resMap);
    return res;
  }

  Future<JMCustomMessage> sendCustomMessage({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required Map<dynamic, dynamic>? customObject,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    Map param = type.toJson();

    Map optionMap = {};
    if (sendOption != null) {
      optionMap = {
        'messageSendingOptions': sendOption.toJson()
          ..removeWhere((key, value) => value == null)
      };
    }

    if (extras != null) {
      param..addAll({'extras': extras});
    }

    param..addAll(optionMap)..addAll({'customObject': customObject});

    Map resMap = await _channel.invokeMethod(
        'sendCustomMessage', param..removeWhere((key, value) => value == null));
    var res = JMNormalMessage.generateMessageFromJson(resMap);
    return res;
  }

  Future<JMLocationMessage> sendLocationMessage({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required double? latitude,
    required double? longitude,
    required int? scale,
    String? address,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    Map param = type.toJson();

    Map optionMap = {};
    if (sendOption != null) {
      optionMap = {
        'messageSendingOptions': sendOption.toJson()
          ..removeWhere((key, value) => value == null)
      };
    }

    if (extras != null) {
      param..addAll({'extras': extras});
    }

    param
      ..addAll(optionMap)
      ..addAll({
        'latitude': latitude,
        'longitude': longitude,
        'scale': scale,
        'address': address,
      });

    Map resMap = await _channel.invokeMethod('sendLocationMessage',
        param..removeWhere((key, value) => value == null));
    var res = JMNormalMessage.generateMessageFromJson(resMap);
    return res;
  }

  Future<JMFileMessage> sendFileMessage({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required String? path,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    Map param = type.toJson();
    Map optionMap = {};
    if (sendOption != null) {
      optionMap = {
        'messageSendingOptions': sendOption.toJson()
          ..removeWhere((key, value) => value == null)
      };
    }

    if (extras != null) {
      param..addAll({'extras': extras});
    }

    param..addAll(optionMap)..addAll({'path': path});

    Map resMap = await _channel.invokeMethod(
        'sendFileMessage', param..removeWhere((key, value) => value == null));
    var res = JMNormalMessage.generateMessageFromJson(resMap);
    return res;
  }

  Future<JMVideoMessage> sendVideoMessage({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    String? thumbImagePath,
    String? thumbFormat,
    required String? videoPath,
    String? videoFileName,
    int? duration,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    Map param = type.toJson();
    Map optionMap = {};
    if (sendOption != null) {
      optionMap = {
        'messageSendingOptions': sendOption.toJson()
          ..removeWhere((key, value) => value == null)
      };
    }

    if (extras != null) {
      param..addAll({'extras': extras});
    }

    param
      ..addAll(optionMap)
      ..addAll({
        'thumbImagePath': thumbImagePath,
        'thumbFormat': thumbFormat,
        'videoPath': videoPath,
        'videoFileName': videoFileName,
        'duration': duration
      });

    Map resMap = await _channel.invokeMethod(
        'sendVideoMessage', param..removeWhere((key, value) => value == null));
    var res = JMNormalMessage.generateMessageFromJson(resMap);
    return res;
  }

  /// 消息撤回 target
  /// 聊天对象， JMSingle | JMGroup
  /// serverMessageId 消息服务器 id
  Future<void> retractMessage({
    required dynamic target,

    /// (JMSingle | JMGroup )
    required String? serverMessageId,
  }) async {
    Map param = target.toJson();

    param..addAll({'messageId': serverMessageId});

    print("retractMessage: ${param.toString()}");

    await _channel.invokeMethod(
        'retractMessage', param..removeWhere((key, value) => value == null));

    return;
  }

  /// 批量获取本地历史消息
  /// target 聊天对象， JMSingle | JMGroup
  /// from  起始位置
  /// limit 获取数量
  /// isDescend 是否倒序
  Future<List> getHistoryMessages(
      {required dynamic type,

      /// (JMSingle | JMGroup)
      required int? from,
      required int? limit,
      bool isDescend = false}) async {
    Map param = type.toJson();

    param..addAll({'from': from, 'limit': limit, 'isDescend': isDescend});

    List resArr = await _channel.invokeMethod('getHistoryMessages',
        param..removeWhere((key, value) => value == null));

    List res = [];
    for (Map messageMap in resArr) {
      dynamic d = JMNormalMessage.generateMessageFromJson(messageMap);
      if (d != null) {
        res.add(d);
      } else {
        print("get history msg, get a message is null");
      }
    }
    //var res = resArr.map((messageMap) => JMNormalMessage.generateMessageFromJson(messageMap)).toList();
    return res;
  }

  /// 获取本地单条消息
  /// 聊天对象， JMSingle | JMGroup
  /// serverMessageId  服务器返回的 serverMessageId，非本地数据库中的消息id，
  Future<dynamic> getMessageByServerMessageId({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required String? serverMessageId,
  }) async {
    Map param = type.toJson();

    param
      ..addAll({
        'serverMessageId': serverMessageId,
      });

    Map msgMap = await _channel.invokeMethod('getMessageByServerMessageId',
        param..removeWhere((key, value) => value == null));

    return JMNormalMessage.generateMessageFromJson(msgMap);
  }

  /// 获取本地单条消息
  /// target    聊天对象， JMSingle | JMGroup
  /// messageId 本地数据库中的消息id，非 serverMessageId
  Future<dynamic> getMessageById({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required String? messageId,
  }) async {
    Map param = type.toJson();

    param
      ..addAll({
        'messageId': messageId,
      });

    Map msgMap = await _channel.invokeMethod(
        'getMessageById', param..removeWhere((key, value) => value == null));

    return JMNormalMessage.generateMessageFromJson(msgMap);
  }

  /// 删除本地单条消息
  /// target    聊天对象， JMSingle | JMGroup
  /// messageId 本地数据库中的消息id，非serverMessageId
  Future<void> deleteMessageById({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required String? messageId,
  }) async {
    Map param = type.toJson();

    param
      ..addAll({
        'messageId': messageId,
      });

    await _channel.invokeMethod(
        'deleteMessageById', param..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> sendInvitationRequest({
    required String? username,
    required String? reason,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'sendInvitationRequest',
        {
          'username': username,
          'reason': reason,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> acceptInvitation({
    required String? username,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'acceptInvitation',
        {
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> declineInvitation({
    required String? username,
    required String? reason,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'declineInvitation',
        {
          'username': username,
          'reason': reason,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> removeFromFriendList({
    required String? username,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'removeFromFriendList',
        {
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> updateFriendNoteName({
    required String? username,
    required String? noteName,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'updateFriendNoteName',
        {
          'username': username,
          'noteName': noteName,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> updateFriendNoteText({
    required String? username,
    required String? noteText,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'updateFriendNoteText',
        {
          'username': username,
          'noteText': noteText,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<List<JMUserInfo>> getFriends() async {
    List<dynamic> userJsons = await _channel.invokeMethod('getFriends');

    List<JMUserInfo> users =
        userJsons.map((userMap) => JMUserInfo.fromJson(userMap)).toList();
    return users;
  }

  Future<String> createGroup({
    JMGroupType groupType = JMGroupType.private,
    String? name,
    String? desc,
  }) async {
    String groupId = await _channel.invokeMethod(
        'createGroup',
        {'groupType': getStringFromEnum(groupType), 'name': name, 'desc': desc}
          ..removeWhere((key, value) => value == null));

    return groupId;
  }

  Future<List<String>> getGroupIds() async {
    List<dynamic> groupIds = await _channel.invokeMethod('getGroupIds');
    List<String> res = groupIds.map((gid) => '' + gid).toList();
    return res;
  }

  Future<JMGroupInfo> getGroupInfo({required String? id}) async {
    Map groupJson = await _channel.invokeMethod(
        'getGroupInfo', {'id': id}..removeWhere((key, value) => value == null));

    return JMGroupInfo.fromJson(groupJson);
  }

  Future<void> updateGroupInfo({
    required String? id,
    String? newName,
    String? newDesc,
  }) async {
    await _channel.invokeMethod(
        'updateGroupInfo',
        {'id': id, 'newName': newName, 'newDesc': newDesc}
          ..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> addGroupMembers({
    required String? id,
    required List<String>? usernameArray,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'addGroupMembers',
        {
          'id': id,
          'usernameArray': usernameArray,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> removeGroupMembers({
    required String? id,
    required List<String>? usernames,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'removeGroupMembers',
        {
          'id': id,
          'usernameArray': usernames,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> exitGroup({required String? id}) async {
    await _channel.invokeMethod(
        'exitGroup', {'id': id}..removeWhere((key, value) => value == null));

    return;
  }

  Future<List<JMGroupMemberInfo>> getGroupMembers({required String? id}) async {
    List membersJsons = await _channel.invokeMethod('getGroupMembers',
        {'id': id}..removeWhere((key, value) => value == null));

    List<JMGroupMemberInfo> res = membersJsons
        .map((memberJson) => JMGroupMemberInfo.fromJson(memberJson))
        .toList();
    return res;
  }

  Future<void> addUsersToBlacklist(
      {required List<String>? usernameArray, String? appKey}) async {
    await _channel.invokeMethod(
        'addUsersToBlacklist',
        {'usernameArray': usernameArray, 'appKey': appKey}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<void> removeUsersFromBlacklist(
      {required List<String>? usernameArray, String? appKey}) async {
    await _channel.invokeMethod(
        'removeUsersFromBlacklist',
        {'usernameArray': usernameArray, 'appKey': appKey}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<List<JMUserInfo>> getBlacklist() async {
    List userJsons = await _channel.invokeMethod('getBlacklist');
    List<JMUserInfo> res =
        userJsons.map((json) => JMUserInfo.fromJson(json)).toList();
    return res;
  }

  Future<void> setNoDisturb({
    required dynamic target, // (JMSingle | JMGroup)
    required bool? isNoDisturb,
  }) async {
    var param = target.toJson();
    param['isNoDisturb'] = isNoDisturb;
    await _channel.invokeMethod(
        'setNoDisturb', param..removeWhere((key, value) => value == null));
    return;
  }

  Future<Map> getNoDisturbList() async {
    Map resJson = await _channel.invokeMethod('getNoDisturbList');
    List userJsons = resJson['userInfoArray'];
    List groupJsons = resJson['groupInfoArray'];

    List<JMUserInfo> users =
        userJsons.map((json) => JMUserInfo.fromJson(json)).toList();
    List<JMGroupInfo> groups =
        groupJsons.map((json) => JMGroupInfo.fromJson(json)).toList();

    return {'userInfos': users, 'groupInfos': groups};
  }

  Future<void> setNoDisturbGlobal({required bool? isNoDisturb}) async {
    await _channel.invokeMethod(
        'setNoDisturbGlobal',
        {'isNoDisturb': isNoDisturb}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<bool> isNoDisturbGlobal() async {
    Map resJson = await _channel.invokeMethod('isNoDisturbGlobal');
    return resJson['isNoDisturb'];
  }

  Future<void> blockGroupMessage({
    required String? id,
    required bool? isBlock,
  }) async {
    await _channel.invokeMethod(
        'blockGroupMessage',
        {'id': id, 'isBlock': isBlock}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<bool> isGroupBlocked({
    required String? id,
  }) async {
    Map resJson = await _channel.invokeMethod('isGroupBlocked',
        {'id': id}..removeWhere((key, value) => value == null));
    return resJson['isBlocked'];
  }

  Future<List<JMGroupInfo>> getBlockedGroupList() async {
    List resJson = await _channel.invokeMethod('getBlockedGroupList');
    List<JMGroupInfo> res =
        resJson.map((json) => JMGroupInfo.fromJson(json)).toList();
    return res;
  }

  Future<Map> downloadThumbUserAvatar({
    required String? username,
    String? appKey,
  }) async {
    Map resJson = await _channel.invokeMethod(
        'downloadThumbUserAvatar',
        {
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return {
      'username': resJson['username'],
      'appKey': resJson['appKey'],
      'filePath': resJson['filePath']
    };
  }

  Future<Map> downloadOriginalUserAvatar({
    required String? username,
    String? appKey,
  }) async {
    Map resJson = await _channel.invokeMethod(
        'downloadOriginalUserAvatar',
        {
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return {
      'username': resJson['username'],
      'appKey': resJson['appKey'],
      'filePath': resJson['filePath']
    };
  }

  /// 下载缩略图
  /// target    聊天对象， JMSingle | JMGroup | JMChatRoom
  /// messageId 本地数据库中的消息 id,非 serverMessageId
  Future<Map> downloadThumbImage({
    required dynamic target,
    required String? messageId,
  }) async {
    Map param = target.toJson();
    param['messageId'] = messageId;
    Map resJson = await _channel.invokeMethod('downloadThumbImage',
        param..removeWhere((key, value) => value == null));

    return {'messageId': resJson['messageId'], 'filePath': resJson['filePath']};
  }

  /// 下载原图
  /// target    聊天对象， JMSingle | JMGroup | JMChatRoom
  /// messageId 本地数据库中的消息 id,非 serverMessageId
  Future<Map> downloadOriginalImage({
    required dynamic target,
    required String? messageId,
  }) async {
    Map param = target.toJson();
    param['messageId'] = messageId;
    Map resJson = await _channel.invokeMethod('downloadOriginalImage',
        param..removeWhere((key, value) => value == null));

    return {'messageId': resJson['messageId'], 'filePath': resJson['filePath']};
  }

  /// 下载语音
  /// target    聊天对象， JMSingle | JMGroup | JMChatRoom
  /// messageId 本地数据库中的消息 id,非 serverMessageId
  Future<Map> downloadVoiceFile({
    required dynamic target,
    required String? messageId,
  }) async {
    Map param = target.toJson();
    param['messageId'] = messageId;
    Map resJson = await _channel.invokeMethod(
        'downloadVoiceFile', param..removeWhere((key, value) => value == null));

    return {'messageId': resJson['messageId'], 'filePath': resJson['filePath']};
  }

  /// 下载文件
  /// target    聊天对象， JMSingle | JMGroup | JMChatRoom
  /// messageId 本地数据库中的消息 id
  Future<Map> downloadFile({
    required dynamic target,
    required String? messageId,
  }) async {
    Map param = target.toJson();
    param['messageId'] = messageId;
    Map resJson = await _channel.invokeMethod(
        'downloadFile', param..removeWhere((key, value) => value == null));

    return {'messageId': resJson['messageId'], 'filePath': resJson['filePath']};
  }

  Future<JMConversationInfo> createConversation({
    required dynamic target, //(JMSingle | JMGroup | JMChatRoom)
  }) async {
    Map param = target.toJson();
    Map resJson = await _channel.invokeMethod('createConversation',
        param..removeWhere((key, value) => value == null));

    return JMConversationInfo.fromJson(resJson);
  }

  Future<void> deleteConversation({
    required dynamic target, //(JMSingle | JMGroup | JMChatRoom)
  }) async {
    Map param = target.toJson();
    await _channel.invokeMethod('deleteConversation',
        param..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> enterConversation({
    required dynamic target, //(JMSingle | JMGroup)
  }) async {
    if (_platform.isAndroid) {
      Map param = target.toJson();
      await _channel.invokeMethod('enterConversation',
          param..removeWhere((key, value) => value == null));
    }

    return;
  }

  Future<void> exitConversation({
    required dynamic target, //(JMSingle | JMGroup)
  }) async {
    if (_platform.isAndroid) {
      Map param = target.toJson();
      await _channel.invokeMethod('exitConversation',
          param..removeWhere((key, value) => value == null));
    }

    return;
  }

  Future<JMConversationInfo> getConversation({
    required dynamic target, //(JMSingle | JMGroup | JMChatRoom)
  }) async {
    Map param = target.toJson();
    Map resJson = await _channel.invokeMethod(
        'getConversation', param..removeWhere((key, value) => value == null));

    return JMConversationInfo.fromJson(resJson);
  }

  Future<List<JMConversationInfo>> getConversations() async {
    List conversionJsons = await _channel.invokeMethod('getConversations');
    List<JMConversationInfo> conversations = conversionJsons
        .map((json) => JMConversationInfo.fromJson(json))
        .toList();
    return conversations;
  }

  Future<void> resetUnreadMessageCount({
    required dynamic target, //(JMSingle | JMGroup | JMChatRoom)
  }) async {
    Map param = target.toJson();
    await _channel.invokeMethod('resetUnreadMessageCount',
        param..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> transferGroupOwner({
    required String? groupId,
    required String? username,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'transferGroupOwner',
        {
          'groupId': groupId,
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> setGroupMemberSilence({
    required String? groupId,
    required bool? isSilence,
    required String? username,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'setGroupMemberSilence',
        {
          'groupId': groupId,
          'username': username,
          'isSilence': isSilence,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<bool> isSilenceMember({
    required String? groupId,
    required String? username,
    String? appKey,
  }) async {
    Map resJson = await _channel.invokeMethod(
        'isSilenceMember',
        {
          'groupId': groupId,
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));
    return resJson['isSilence'];
  }

  Future<List<JMUserInfo>> groupSilenceMembers({
    required String? groupId,
  }) async {
    List memberJsons = await _channel.invokeMethod(
        'groupSilenceMembers',
        {
          'groupId': groupId,
        }..removeWhere((key, value) => value == null));
    List<JMUserInfo> members =
        memberJsons.map((json) => JMUserInfo.fromJson(json)).toList();
    return members;
  }

  Future<void> setGroupNickname({
    required String? groupId,
    required String? nickName,
    required String? username,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'setGroupNickname',
        {
          'groupId': groupId,
          'nickName': nickName,
          'username': username,
          'appKey': appKey,
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<JMConversationInfo> enterChatRoom({
    required String? roomId,
  }) async {
    Map resJson = await _channel.invokeMethod('enterChatRoom',
        {'roomId': roomId}..removeWhere((key, value) => value == null));

    return JMConversationInfo.fromJson(resJson);
  }

  Future<void> exitChatRoom({
    required String? roomId,
  }) async {
    await _channel.invokeMethod('exitChatRoom',
        {'roomId': roomId}..removeWhere((key, value) => value == null));

    return;
  }

  Future<JMConversationInfo?> getChatRoomConversation({
    required String? roomId,
  }) async {
    Map resJson = await _channel.invokeMethod('getChatRoomConversation',
        {'roomId': roomId}..removeWhere((key, value) => value == null));
    if(resJson == null || resJson.isEmpty){
      return null;
    }
    return JMConversationInfo.fromJson(resJson);
  }

  Future<List<JMConversationInfo>> getChatRoomConversationList() async {
    List conversationJsons =
        await _channel.invokeMethod('getChatRoomConversationList');
    List<JMConversationInfo> conversations = conversationJsons
        .map((json) => JMConversationInfo.fromJson(json))
        .toList();
    return conversations;
  }

  Future<num> getAllUnreadCount() async {
    num unreadCount = await _channel.invokeMethod('getAllUnreadCount');
    return unreadCount;
  }

  Future<void> addGroupAdmins({
    required String? groupId,
    required List<String>? usernames,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'addGroupAdmins',
        {'groupId': groupId, 'usernames': usernames, 'appKey': appKey}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<void> removeGroupAdmins({
    required String? groupId,
    required List<String>? usernames,
    String? appKey,
  }) async {
    await _channel.invokeMethod(
        'removeGroupAdmins',
        {'groupId': groupId, 'usernames': usernames, 'appKey': appKey}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<void> changeGroupType({
    required String? groupId,
    required JMGroupType? type,
  }) async {
    await _channel.invokeMethod(
        'changeGroupType',
        {'groupId': groupId, 'type': getStringFromEnum(type)}
          ..removeWhere((key, value) => value == null));
    return;
  }

  Future<List<JMGroupInfo>> getPublicGroupInfos({
    required String? appKey,
    required num? start,
    required num? count,
  }) async {
    List groupJsons = await _channel.invokeMethod(
        'getPublicGroupInfos',
        {'appKey': appKey, 'start': start, 'count': count}
          ..removeWhere((key, value) => value == null));
    List<JMGroupInfo> groups =
        groupJsons.map((json) => JMGroupInfo.fromJson(json)).toList();
    return groups;
  }

  Future<void> applyJoinGroup({
    required String? groupId,
    String? reason,
  }) async {
    await _channel.invokeMethod(
        'applyJoinGroup',
        {'groupId': groupId, 'reason': reason}
          ..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> processApplyJoinGroup({
    required List<String>? events,
    required bool? isAgree,
    required bool? isRespondInviter,
    String? reason,
  }) async {
    await _channel.invokeMethod(
        'processApplyJoinGroup',
        {
          'events': events,
          'isAgree': isAgree,
          'isRespondInviter': isRespondInviter,
          'reason': reason
        }..removeWhere((key, value) => value == null));

    return;
  }

  Future<void> dissolveGroup({
    required String? groupId,
  }) async {
    await _channel.invokeMethod(
        'dissolveGroup',
        {
          'groupId': groupId,
        }..removeWhere((key, value) => value == null));

    return;
  }

  /// 会话间透传命令，只支持 single、group，不支持 chatRoom
  Future<void> sendMessageTransCommand({
    required String? message,
    required dynamic target, //(JMSingle | JMGroup)
  }) async {
    if (target is JMChatRoom) {
      print("does not support chatroom message trans.");
      return;
    }

    Map param = target.toJson();
    param["message"] = message;
    param.removeWhere((key, value) => value == null);

    await _channel.invokeMethod('sendMessageTransCommand', param);
  }

  /// 设备间透传命令
  Future<void> sendCrossDeviceTransCommand({
    required String? message,
    required JMPlatformType? platform,
  }) async {
    Map param = Map();
    param["message"] = message;
    param["type"] = getStringFromEnum(platform);
    param.removeWhere((key, value) => value == null);

    await _channel.invokeMethod('sendCrossDeviceTransCommand', param);
  }

  /*
  * 获取 message 当前未发送已读回执的人数
  *
  * @param target 消息所处的会话对象，user or group
  * @param msgId  消息本地 id，即：message.id
  *
  * */
  Future<int> getMessageUnreceiptCount({
    required dynamic target,

    /// (JMSingle | JMGroup)
    required String? msgId,
  }) async {
    print(flutterLog + "getMessageUnreceiptCount" + " msgid = $msgId");

    if (msgId == null || msgId.length == 0 || target == null) {
      return 0;
    }

    Map param = target.toJson();
    param["id"] = msgId;

    int count = await _channel.invokeMethod('getMessageUnreceiptCount',
        param..removeWhere((key, value) => value == null));
    return count;
  }

  /*
   * 获取 message 已读回执详情
   *
   * @param target    消息所处的会话对象，user or group
   * @param msgId     消息本地 id，即：message.id
   * @param callback  函数回调，返回已发回执和未发回执的 user 列表，如下：
   *                      a = List<JMUserInfo>receiptList
   *                      b = List<JMUserInfo>unreceiptList
   *
   */
  void getMessageReceiptDetails({
    required dynamic target,

    /// (JMSingle | JMGroup)
    required String? msgId,
    required JMCallback? callback,
  }) async {
    print(flutterLog + "getMessageUnreceiptCount" + " msgid = $msgId");

    if (callback == null) {
      return;
    }

    if (msgId == null || msgId.length == 0 || target == null) {
      callback(null, null);
      return;
    }

    Map param = target.toJson();
    param["id"] = msgId;

    Map? resultMap = await _channel.invokeMethod('getMessageReceiptDetails',
        param..removeWhere((key, value) => value == null));
    if (resultMap != null) {
      List receiptJosnList = resultMap["receiptList"];
      List unreceiptJosnList = resultMap["unreceiptList"];

      List<JMUserInfo> receiptUserList =
          receiptJosnList.map((json) => JMUserInfo.fromJson(json)).toList();
      List<JMUserInfo> unreceiptUserList =
          unreceiptJosnList.map((json) => JMUserInfo.fromJson(json)).toList();
      callback(receiptUserList, unreceiptUserList);
    } else {
      callback(null, null);
    }
  }

  /// 将消息设置为已读
  /// target    消息所处的会话对象，user or group
  /// msgId     消息本地 id，即：message.id
  /// true/false 设置成功返回 true，设置失败返回 false
  Future<bool> setMessageHaveRead({
    required dynamic target,

    /// (JMSingle | JMGroup)
    required String? msgId,
  }) async {
    print(flutterLog + "setMessageHaveRead" + " msgid = $msgId");

    if (msgId == null || msgId.length == 0 || target == null) {
      return false;
    }

    Map param = target.toJson();
    param["id"] = msgId;
    bool isSuccess = await _channel.invokeMethod('setMessageHaveRead',
        param..removeWhere((key, value) => value == null));

    return isSuccess;
  }

  /// 获取消息已读状态
  /// target    消息所处的会话对象，user or group
  /// msgId     消息本地 id，即：message.id
  Future<bool> getMessageHaveReadStatus({
    required dynamic target,

    /// (JMSingle | JMGroup)
    required String? msgId,
  }) async {
    print(flutterLog + "getMessageHaveReadStatus" + " msgid = $msgId");

    if (msgId == null || msgId.length == 0 || target == null) {
      return false;
    }

    Map param = target.toJson();
    param["id"] = msgId;
    bool isSuccess = await _channel.invokeMethod('getMessageHaveReadStatus',
        param..removeWhere((key, value) => value == null));

    return isSuccess;
  }
}

enum JMPlatformType { android, ios, windows, web, all }
enum JMConversationType { single, group, chatRoom }

enum JMTargetType { user, group }

// 'male' | 'female' | 'unknown';
enum JMGender { male, female, unknown }

class JMSingle {
  final JMConversationType type = JMConversationType.single;
  String? username;
  String? appKey;

  Map toJson() {
    return {
      "type": getStringFromEnum(JMConversationType.single),
      "username": username,
      "appKey": appKey
    };
  }

  JMSingle.fromJson(Map<dynamic, dynamic> json)
      : username = json['username'],
        appKey = json['appKey'];
}

enum JMGroupType { private, public }

class JMGroup {
  final JMConversationType type = JMConversationType.group;
  String groupId;

  bool operator ==(dynamic other) {
    return (other is JMGroup && other.groupId == groupId);
  }

  Map toJson() {
    return {
      "type": getStringFromEnum(JMConversationType.group),
      "groupId": groupId
    };
  }

  JMGroup.fromJson(Map<dynamic, dynamic> json) : groupId = json['groupId'];

  @override
  int get hashCode => super.hashCode;
}

class JMChatRoom {
  final JMConversationType type = JMConversationType.chatRoom;
  String roomId;

  bool operator ==(dynamic other) {
    return (other is JMChatRoom && other.roomId == roomId);
  }

  Map toJson() {
    return {
      "type": getStringFromEnum(JMConversationType.chatRoom),
      "roomId": roomId
    };
  }

  JMChatRoom.fromJson(Map<dynamic, dynamic> json) : roomId = json['roomId'];

  @override
  int get hashCode => super.hashCode;
}

// export type JMAllType = (JMSingle | JMGroup | JMChatRoom);

class JMMessageSendOptions {
  /// 接收方是否针对此次消息发送展示通知栏通知。
  /// @defaultvalue
  bool isShowNotification;

  ///  是否让后台在对方不在线时保存这条离线消息，等到对方上线后再推送给对方。
  ///  @defaultvalue
  bool isRetainOffline;

  bool isCustomNotificationEnabled;

  /// 设置此条消息在接收方通知栏所展示通知的标题。
  String notificationTitle;

  /// 设置此条消息在接收方通知栏所展示通知的内容。
  String notificationText;

  /// 设置这条消息的发送是否需要对方发送已读回执，false，默认值
  bool needReadReceipt = false;

  Map toJson() {
    return {
      'isShowNotification': isShowNotification,
      'isRetainOffline': isRetainOffline,
      'isCustomNotificationEnabled': isCustomNotificationEnabled,
      'notificationTitle': notificationTitle,
      'notificationText': notificationText,
      'needReadReceipt': needReadReceipt,
    };
  }

  JMMessageSendOptions.fromJson(Map<dynamic, dynamic> json)
      : isShowNotification = json['isShowNotification'],
        isRetainOffline = json['isRetainOffline'],
        isCustomNotificationEnabled = json['isCustomNotificationEnabled'],
        notificationTitle = json['notificationTitle'],
        notificationText = json['notificationText'],
        needReadReceipt = json['needReadReceipt'];
}

class JMMessageOptions {
  Map<dynamic, dynamic>? extras;
  JMMessageSendOptions? messageSendingOptions;

  Map toJson() {
    return {
      'extras': extras,
      'messageSendingOptions': messageSendingOptions?.toJson()
    };
  }
}

class JMError {
  String code;
  String description;

  Map toJson() {
    return {
      'code': code,
      'description': description,
    };
  }

  JMError.fromJson(Map<dynamic, dynamic> json)
      : code = json['code'],
        description = json['description'];
}

class JMUserInfo {
  JMTargetType type = JMTargetType.user;

  String username; // 用户名
  String appKey; // 用户所属应用的 appKey，可与 username 共同作为用户的唯一标识
  String nickname; // 昵称
  JMGender gender; // 性别
  String avatarThumbPath; // 头像的缩略图地址
  String birthday; // 日期的毫秒数
  String region; // 地区
  String signature; // 个性签名
  String address; // 具体地址
  String noteName; // 备注名
  String noteText; // 备注信息
  bool isNoDisturb; // 是否免打扰
  bool isInBlackList; // 是否在黑名单中
  bool isFriend; // 是否为好友
  Map<dynamic, dynamic> extras; // 自定义键值对

  JMSingle get targetType =>
      JMSingle.fromJson({'username': username, 'appKey': appKey});

  bool operator ==(dynamic other) {
    return (other is JMUserInfo && other.username == username);
  }

  Map toJson() {
    return {
      'type': getStringFromEnum(type),
      'gender': getStringFromEnum(gender),
      'username': username,
      'appKey': appKey,
      'nickname': nickname,
      'avatarThumbPath': avatarThumbPath,
      'birthday': birthday,
      'region': region,
      'signature': signature,
      'address': address,
      'noteName': noteName,
      'noteText': noteText,
      'isNoDisturb': isNoDisturb,
      'isInBlackList': isInBlackList,
      'isFriend': isFriend,
      'extras': extras
    };
  }

  JMUserInfo.fromJson(Map<dynamic, dynamic> json)
      : username = json['username'],
        appKey = json['appKey'],
        nickname = json['nickname'],
        avatarThumbPath = json['avatarThumbPath'],
        birthday = json['birthday'],
        region = json['region'],
        signature = json['signature'],
        address = json['address'],
        noteName = json['noteName'],
        noteText = json['noteText'],
        isNoDisturb = json['isNoDisturb'],
        isInBlackList = json['isInBlackList'],
        isFriend = json['isFriend'],
        gender = getEnumFromString(JMGender.values, json['gender']),
        extras = json['extras'];

  @override
  int get hashCode => super.hashCode;
}

enum JMMessageState {
  draft, // 创建的消息，还未发送
  sending, // 正在发送中
  send_succeed, // 发送成功
  receiving, // 接收中的消息，一般在 SDK 内部使用，无需考虑
  received, // 已经成功接收
  send_failed, // 发送失败
  upload_succeed, // 上传成功
  upload_failed, // 上传失败
  download_failed // 接收消息时自动下载资源失败
}

class JMNormalMessage {
  String id; // 本地数据库中的消息 id
  JMMessageState state; // 消息的状态
  String serverMessageId; // 对应服务器端的消息 id，只用于在服务端查询问题
  bool isSend; // 消息是否由当前用户发出。true：为当前用户发送；false：为对方用户发送。
  JMUserInfo from; // 消息发送者对象
  int createTime; // 发送消息时间
  Map<dynamic, dynamic> extras; // 附带的键值对
  dynamic target; // JMUserInfo | JMGroupInfo

  Map toJson() {
    return {
      'id': id,
      'serverMessageId': serverMessageId,
      'isSend': isSend,
      'from': from.toJson(),
      'createTime': createTime,
      'extras': extras,
      'target': target.toJson()
    };
  }

  JMNormalMessage.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        createTime = json['createTime'],
        serverMessageId = json['serverMessageId'],
        isSend = json['isSend'],
        state = getEnumFromString(JMMessageState.values, json['state']),
        from = JMUserInfo.fromJson(json['from']),
        extras = json['extras'] {
    switch (json['target']['type']) {
      case 'user':
        target = JMUserInfo.fromJson(json['target']);
        break;
      case 'group':
        target = JMGroupInfo.fromJson(json['target']);
        break;
    }
  }

  static dynamic generateMessageFromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return null;

    JMMessageType type = getEnumFromString(JMMessageType.values, json['type']);
    switch (type) {
      case JMMessageType.text:
        return JMTextMessage.fromJson(json);
      case JMMessageType.image:
        return JMImageMessage.fromJson(json);
      case JMMessageType.voice:
        return JMVoiceMessage.fromJson(json);
      case JMMessageType.location:
        return JMLocationMessage.fromJson(json);
      case JMMessageType.file:
        return JMFileMessage.fromJson(json);
      case JMMessageType.custom:
        return JMCustomMessage.fromJson(json);
      case JMMessageType.event:
        return JMEventMessage.fromJson(json);
      case JMMessageType.prompt:
        return JMPromptMessage.fromJson(json);
      case JMMessageType.video:
        return JMPromptMessage.fromJson(json);
    }
  }
}

enum JMMessageType {
  text,
  image,
  voice,
  file,
  custom,
  location,
  event,
  prompt,
  video
}

class JMTextMessage extends JMNormalMessage {
  final JMMessageType type = JMMessageType.text;
  String text;

  Map toJson() {
    var json = super.toJson();
    json['type'] = getStringFromEnum(JMMessageType.text);
    json['text'] = text;
    return json;
  }

  JMTextMessage.fromJson(Map<dynamic, dynamic> json)
      : text = json['text'],
        super.fromJson(json);
}

class JMVoiceMessage extends JMNormalMessage {
  String path; // 语音文件路径,如果为空需要调用相应下载方法，注意这是本地路径，不能是 url
  num duration; // 语音时长，单位秒

  Map toJson() {
    var json = super.toJson();
    json['path'] = path;
    json['duration'] = duration;
    return json;
  }

  JMVoiceMessage.fromJson(Map<dynamic, dynamic> json)
      : path = json['path'],
        duration = json['duration'],
        super.fromJson(json);
}

class JMImageMessage extends JMNormalMessage {
  String thumbPath; // 图片的缩略图路径, 如果为空需要调用相应下载方法

  Map toJson() {
    var json = super.toJson();
    json['thumbPath'] = thumbPath;
    return json;
  }

  JMImageMessage.fromJson(Map<dynamic, dynamic> json)
      : thumbPath = json['thumbPath'],
        super.fromJson(json);
}

class JMFileMessage extends JMNormalMessage {
  String fileName; // 文件名

  Map toJson() {
    var json = super.toJson();
    json['fileName'] = fileName;
    return json;
  }

  JMFileMessage.fromJson(Map<dynamic, dynamic> json)
      : fileName = json['fileName'],
        super.fromJson(json);
}

class JMLocationMessage extends JMNormalMessage {
  double longitude; // 经度
  double latitude; // 纬度
  int scale; // 地图缩放比例
  String address; // 详细地址

  Map toJson() {
    var json = super.toJson();
    json['longitude'] = longitude;
    json['latitude'] = latitude;
    json['scale'] = scale;
    json['address'] = address;

    return json;
  }

  JMLocationMessage.fromJson(Map<dynamic, dynamic> json)
      : longitude = json['longitude'],
        latitude = json['latitude'],
        scale = json['scale'],
        address = json['address'],
        super.fromJson(json);
}

class JMVideoMessage extends JMNormalMessage {
  String videoPath; // 视频地址
  String thumbFormat; //视频缩略图格式名
  int duration; // 视频时长
  String thumbImagePath; // 视频缩略图
  String videoFileName; // 视频名称

  Map toJson() {
    var json = super.toJson();
    json['thumbImagePath'] = thumbImagePath;
    json['videoPath'] = videoPath;
    json['duration'] = duration;
    json['thumbImagePath'] = thumbImagePath;
    json['videoFileName'] = videoFileName;

    return json;
  }

  JMVideoMessage.fromJson(Map<dynamic, dynamic> json)
      : videoPath = json['videoPath'],
        thumbFormat = json['thumbFormat'],
        duration = json['duration'],
        thumbImagePath = json['thumbImagePath'],
        videoFileName = json['videoFileName'],
        super.fromJson(json);
}

class JMCustomMessage extends JMNormalMessage {
  Map<dynamic, dynamic> customObject; // 自定义键值对

  Map toJson() {
    var json = super.toJson();
    json['customObject'] = customObject;
    return json;
  }

  JMCustomMessage.fromJson(Map<dynamic, dynamic> json)
      : customObject = json['customObject'],
        super.fromJson(json);
}

class JMPromptMessage extends JMNormalMessage {
  String promptText;

  Map toJson() {
    var json = super.toJson();
    json["promptText"] = promptText;
    return json;
  }

  JMPromptMessage.fromJson(Map<dynamic, dynamic> json)
      : promptText = json["promptText"],
        super.fromJson(json);
}

enum JMEventType { group_member_added, group_member_removed, group_member_exit }

class JMEventMessage extends JMNormalMessage {
  JMEventType eventType; // 事件类型
  List<dynamic> usernames; // List<String>
  List<dynamic> nicknames; // List<String>

  Map toJson() {
    var json = super.toJson();
    json['eventType'] = getStringFromEnum(eventType);
    json['usernames'] = usernames;
    json['nicknames'] = nicknames;
    return json;
  }

  JMEventMessage.fromJson(Map<dynamic, dynamic> json)
      : eventType = getEnumFromString(JMEventType.values, json['eventType']),
        usernames = json['usernames'],
        nicknames = json['nicknames'],
        super.fromJson(json);
}

enum JMLoginStateChangedType {
  user_logout, // 被踢、被迫退出
  user_deleted, // 用户被删除
  user_password_change, // 非客户端修改密码
  user_login_status_unexpected, // 用户登录状态异常
  user_disabled //用户被禁用
}

enum JMContactNotifyType {
  invite_received,
  invite_accepted,
  invite_declined,
  contact_deleted
}

class JMContactNotifyEvent {
  JMContactNotifyType type;
  String reason;
  String fromUserName;
  String fromUserAppKey;

  Map toJson() {
    return {
      'type': getStringFromEnum(type),
      'reason': reason,
      'fromUserName': fromUserName,
      'fromUserAppKey': fromUserAppKey
    };
  }

  JMContactNotifyEvent.fromJson(Map<dynamic, dynamic> json)
      : type = getEnumFromString(JMContactNotifyType.values, json['type']),
        reason = json['reason'],
        fromUserName = json['fromUsername'],
        fromUserAppKey = json['fromUserAppKey'];
}

class JMReceiveTransCommandEvent {
  String message;
  JMUserInfo sender;
  dynamic receiver; // JMUserInfo | JMGroupInfo;
  JMTargetType receiverType; // user | group // DIFFerent

  Map toJson() {
    return {
      'message': message,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'receiverType': getStringFromEnum(receiverType)
    };
  }

  JMReceiveTransCommandEvent.fromJson(Map<dynamic, dynamic> json)
      : receiverType =
            getEnumFromString(JMTargetType.values, json['receiverType']),
        message = json['message'],
        sender = JMUserInfo.fromJson(json['sender']) {
    switch (receiverType) {
      case JMTargetType.user:
        receiver = JMUserInfo.fromJson(json['receiver']);
        break;
      case JMTargetType.group:
        receiver = JMGroupInfo.fromJson(json['receiver']);
        break;
    }
  }
}

class JMReceiveApplyJoinGroupApprovalEvent {
  String? eventId;
  String? groupId;
  bool? isInitiativeApply;
  JMUserInfo? sendApplyUser;
  List<JMUserInfo>? joinGroupUsers;
  String? reason;

  JMReceiveApplyJoinGroupApprovalEvent.fromJson(Map<dynamic, dynamic> json)
      : eventId = json['eventId'],
        groupId = json['groupId'],
        isInitiativeApply = json['isInitiativeApply'],
        sendApplyUser = JMUserInfo.fromJson(json['sendApplyUser']),
        reason = json['reason'] {
    List<dynamic> userJsons = json['joinGroupUsers'];
    joinGroupUsers = userJsons.map((userJson) {
      return JMUserInfo.fromJson(userJson);
    }).toList();
  }
}

class JMReceiveGroupAdminRejectEvent {
  String groupId;
  JMUserInfo groupManager;
  String reason;

  JMReceiveGroupAdminRejectEvent.fromJson(Map<dynamic, dynamic> json)
      : groupId = json['groupId'],
        groupManager = JMUserInfo.fromJson(json['groupManager']),
        reason = json['reason'];
}

class JMReceiveGroupAdminApprovalEvent {
  bool? isAgree;
  String? applyEventId;
  String? groupId;
  JMUserInfo? groupAdmin;
  List<JMUserInfo>? users;

  JMReceiveGroupAdminApprovalEvent.fromJson(Map<dynamic, dynamic> json)
      : isAgree = json['isAgree'],
        applyEventId = json['applyEventId'],
        groupId = json['groupId'],
        groupAdmin = JMUserInfo.fromJson(json['groupAdmin']) {
    List<dynamic> userJsons = json['users'];
    users = userJsons.map((userJson) {
      return JMUserInfo.fromJson(userJson);
    }).toList();
  }
}

class JMGroupInfo {
  String id; // 群组 id
  String name; // 群组名称
  String desc; // 群组描述
  int level; // 群组等级，默认等级 4
  String owner; // 群主的 username
  String ownerAppKey; // 群主的 appKey
  int maxMemberCount; // 最大成员数
  bool isNoDisturb; // 是否免打扰
  bool isBlocked; // 是否屏蔽群消息
  JMGroupType groupType; // 群类型
  JMGroup get targetType => JMGroup.fromJson({'groupId': id});

  bool operator ==(dynamic other) {
    return (other is JMGroupInfo && other.id == id);
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'level': level,
      'owner': owner,
      'ownerAppKey': ownerAppKey,
      'maxMemberCount': maxMemberCount,
      'isNoDisturb': isNoDisturb,
      'isBlocked': isBlocked,
      'groupType': getStringFromEnum(groupType),
    };
  }

  JMGroupInfo.fromJson(Map<dynamic, dynamic> json)
      : id = json['id'],
        name = json['name'],
        desc = json['desc'],
        level = json['level'],
        owner = json['owner'],
        ownerAppKey = json['ownerAppKey'],
        maxMemberCount = json['maxMemberCount'],
        isNoDisturb = json['isNoDisturb'],
        isBlocked = json['isBlocked'],
        groupType = getEnumFromString(JMGroupType.values, json['groupType']);

  Future<void> exitGroup({required String? id}) async {
    await JmessageFlutter().exitGroup(id: id);
    return;
  }

  Future<void> updateGroupInfo({
    String? newName,
    String? newDesc,
  }) async {
    await JmessageFlutter().updateGroupInfo(
      id: id,
      newDesc: newDesc,
      newName: newName,
    );
    return;
  }

  @override
  int get hashCode => super.hashCode;
}

enum JMGroupMemberType {
  owner, // 群主
  admin, // 管理员
  ordinary // 普通成员
}

class JMGroupMemberInfo {
  JMUserInfo? user;
  String? groupNickname;
  JMGroupMemberType? memberType;
  num? joinGroupTime;

  Map toJson() {
    return {
      'user': user?.toJson(),
      'groupNickname': groupNickname,
      'memberType': getStringFromEnum(memberType),
      'joinGroupTime': joinGroupTime
    };
  }

  JMGroupMemberInfo.fromJson(Map<dynamic, dynamic> json)
      : user = JMUserInfo.fromJson(json['user']),
        groupNickname = json['groupNickname'],
        memberType =
            getEnumFromString(JMGroupMemberType.values, json['memberType']),
        joinGroupTime = json['joinGroupTime'];
}

class JMChatRoomInfo {
  String roomId; // 聊天室 id
  String name; // 聊天室名称
  String appKey; // 聊天室所属应用的 App Key
  String description; // 聊天室描述信息
  int createTime; // 创建日期，单位：秒
  int maxMemberCount; // 最大成员数
  int memberCount; // 当前成员数

  JMChatRoom get targetType => JMChatRoom.fromJson({'roomId': roomId});

  bool operator ==(dynamic other) {
    return (other is JMChatRoomInfo && other.roomId == roomId);
  }

  Map toJson() {
    return {
      'roomId': roomId,
      'name': name,
      'appKey': appKey,
      'description': description,
      'createTime': createTime,
      'maxMemberCount': maxMemberCount,
      'memberCount': memberCount,
    };
  }

  JMChatRoomInfo.fromJson(Map<dynamic, dynamic> json)
      : roomId = json['roomId'],
        name = json['name'],
        appKey = json['appKey'],
        description = json['description'],
        createTime = json['createTime'],
        maxMemberCount = json['maxMemberCount'],
        memberCount = json['memberCount'];

  @override
  int get hashCode => super.hashCode;
}

class JMConversationInfo {
  JMConversationType conversationType; // 会话类型
  String title; // 会话标题
  int unreadCount; // 未读消息数
  dynamic target; // JMUserInfo or JMGroupInfo or JMChatRoom
  dynamic latestMessage; // 最近的一条消息对象。如果不存在消息，则 conversation 对象中没有该属性。
  Map<dynamic, dynamic> extras;

  Map toJson() {
    return {
      'title': title,
      'conversationType': getStringFromEnum(conversationType),
      'unreadCount': unreadCount,
      'extras': extras.toString(),
    };
  }

  JMConversationInfo.fromJson(Map<dynamic, dynamic> json)
      : conversationType = getEnumFromString(
            JMConversationType.values, json['conversationType']),
        title = json['title'],
        unreadCount = json['unreadCount'],
        extras = json['extras'] {
    switch (conversationType) {
      case JMConversationType.single:
        target = JMUserInfo.fromJson(json['target']);
        break;
      case JMConversationType.group:
        target = JMGroupInfo.fromJson(json['target']);
        break;
      case JMConversationType.chatRoom:
        target = JMChatRoomInfo.fromJson(json['target']);
        break;
    }

    latestMessage =
        JMNormalMessage.generateMessageFromJson(json['latestMessage']);
  }

  bool isMyMessage(dynamic message) {
    // TODO:
    return target == message.target;
  }

  // extras use Map<String, String>
  Future<void> setExtras(Map<dynamic, dynamic> extras) async {
    this.extras = extras;
    await JmessageFlutter().setConversationExtras(
      type: target.targetType,
      extras: extras,
    );
  }

  // sendText
  Future<JMTextMessage> sendTextMessage({
    required String? text,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    JMTextMessage msg = await JmessageFlutter().sendTextMessage(
        type: target.targetType,
        text: text,
        sendOption: sendOption,
        extras: extras);
    return msg;
  }

  // sendImage
  Future<JMImageMessage> sendImageMessage({
    required String? path,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    JMImageMessage msg = await JmessageFlutter().sendImageMessage(
      type: target.targetType,
      path: path,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  // sendVoice
  Future<JMVoiceMessage> sendVoiceMessage({
    required String? path,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    JMVoiceMessage msg = await JmessageFlutter().sendVoiceMessage(
      type: target.targetType,
      path: path,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  // sendCustom
  Future<JMCustomMessage> sendCustomMessage({
    required Map<dynamic, dynamic>? customObject,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    JMCustomMessage msg = await JmessageFlutter().sendCustomMessage(
      type: target.targetType,
      customObject: customObject,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  // sendLocation
  Future<JMLocationMessage> sendLocationMessage({
    required double? latitude,
    required double? longitude,
    required int? scale,
    String? address,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    JMLocationMessage msg = await JmessageFlutter().sendLocationMessage(
      type: target.targetType,
      latitude: latitude,
      longitude: longitude,
      scale: scale,
      address: address,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  // sendFile
  Future<JMFileMessage> sendFileMessage({
    required dynamic type,

    /// (JMSingle | JMGroup | JMChatRoom)
    required String? path,
    JMMessageSendOptions? sendOption,
    Map<dynamic, dynamic>? extras,
  }) async {
    JMFileMessage msg = await JmessageFlutter().sendFileMessage(
      type: target.targetType,
      path: path,
      sendOption: sendOption,
      extras: extras,
    );
    return msg;
  }

  // getHistoryMessages
  Future<List> getHistoryMessages(
      {required int? from, required int? limit, bool isDescend = false}) async {
    List msgs = await JmessageFlutter().getHistoryMessages(
        type: target.targetType,
        from: from,
        limit: limit,
        isDescend: isDescend);
    return msgs;
  }
}
