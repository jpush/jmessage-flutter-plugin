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
