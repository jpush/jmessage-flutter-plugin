## 2.1.6
+修复：修复判空异常
## 2.1.4
+新增：新增发送视频接口 sendVideoMessage
## 2.1.2
+升级：升级 android jcore 2.8.2
## 2.1.0
+适配：适配 null safety
## 2.0.5
+ 升级：Android jcore sdk 升级到 2.7.8
## 2.0.3
+ 升级：Android msg sdk 升级到 2.1.4
## 2.0.1
+ 适配Flutter 2.0
## 0.6.5
+ 修复Android端下载消息原图失败问题
## 0.6.4
+ 聊天室消息添加监听、移除监听方法修改
+ 修复聊天室消息移除监听失败问题
## 0.6.3
+ 新增：消息已读回执监听方法
## 0.6.2
+ 内部安全策略优化
## 0.6.1
+ 修复：获取用户信息时黑名单字段错误问题
## 0.6.0
+ 修复：获取消息失败问题
+ 注意：接口参数请严格按照接口说明传值
## 0.5.0
+ 修复：黑名单接口异常
## 0.4.0
+ 1、新增：消息已读未读回执功能
+ 2、修复：删除会话 Android 报错问题
+ 3、下载消息多媒体文件时，统一传入本地消息 id 
+ 4、统一iOS、Android 的用户登录状态变更事件枚举
## 0.3.0
### fix:
+ 1、新增：发送消息透传接口，支持会话间、设备间透传命令；
+ 2、修复经纬度数据错误问题；
## 0.2.0
fix:
    1、新增：消息撤回类型消息；
    2、修复：Group 和 GroupInfo 属性 maxMemberCount 改为 int 类型；
    3、修复：获取我的群组 crash
    
## 0.1.0
fix:
    1、修复：createMessage 方法中经纬度为 int 的错误；
    2、修复：在 Android 下 GroupInfo 的属性 maxMemberCount 为 int 的错误；
    3、修复：消息撤回事件回调中 message 为 null 的错误；
    4、修复：监听不到入群申请通知事件的 bug ;
## 0.0.20
fix:
    1、修改： sendLocationMessage 方法经纬度参数改为 double 类型
## 0.0.19
fix:
    1、修复：Android 接收消息时 flutter 没回调问题
    2、适配 Android 最新 SDK
    3、修改代码书写错误
## 0.0.18
fix:
    1、添加 iOS 端 apns 注册方法
    2、修复：Android 端 serverMessageId 超过 int 存储范围问题；
    3、更新到最新版本 JMessage SDK
## 0.0.17
 fix:
    1、修复IOS发送文件消息获取不到文件问题
## 0.0.16
 fix:
    1、修复发送自定义消息解析失败的bug
    2、修复安卓端exitConversation没有回调的问题。
    3、升级安卓端JMessage sdk版本2.8.2

## 0.0.15
  fix:
    1.修复getHistoryMessages 安卓和ios的消息排序不一致
    2.修复updateMyInfo 的参数缺失问题。
## 0.0.14
 fix: contact event username is null bug

## 0.0.13
 feature: getHistoryMessages parameters add isDescend-option.

## 0.0.12
 feature: onLoginStateChanged add user_kicked event.

## 0.0.11
 fix: jmessage login api remove without avatar path error.

## 0.0.10
 fix: updateGroupInfo update desc error.
 new feature: add extras field in JMConversationInfo.

## 0.0.9
 
 fix: JMConversationInfo getHistoryMessages helper function

## 0.0.8
 
 fix: group.maxMemberCount type

## 0.0.7
 
 new feature: add message.state property

## 0.0.6
 
 fix: voice message error
 new feature: add createMessage and sendMessage api

## 0.0.5 
 
 fix: login state changed not fire in android

## 0.0.4

 fix：isSend 返回 null 的情况。

## 0.0.3

 fix：android isSend 返回错误。

## 0.0.2

 fix：swift 工程集成报错。

## 0.0.1

 第一个版本。
