[![QQ Group](https://img.shields.io/badge/QQ%20Group-862401307-red.svg)]()
[![pub package](https://img.shields.io/pub/v/jmessage_flutter.svg)](https://pub.flutter-io.cn/packages/jmessage_flutter)

# jmessage_flutter

### 安装

在工程 pubspec.yaml 中加入 dependencies

```
dependencies:
  jmessage_flutter: 0.0.17
```



### 配置

在 `/android/app/build.gradle` 中添加下列代码：

```gradle
android {
    ......
    defaultConfig {
        applicationId "com.xxx.xxx" //JPush上注册的包名.
        ......

        ndk {
            //选择要添加的对应cpu类型的.so库。
            abiFilters 'armeabi', 'armeabi-v7a', 'armeabi-v8a'
            // 还可以添加 'x86', 'x86_64', 'mips', 'mips64'
        }

        manifestPlaceholders = [
            JPUSH_PKGNAME : applicationId,
            JPUSH_APPKEY : "你的appkey", //JPush上注册的包名对应的appkey.
            JPUSH_CHANNEL : "developer-default", //暂时填写默认值即可.
        ]
        ......
    }
    ......
}
```



### 使用

```dart
import 'package:jmessage_flutter/jmessage_flutter.dart';
```



### APIs

**注意** : 需要先调用 `JmessageFlutter().init` 来初始化插件，才能保证其它功能正常工作。

[参考](/documents/APIs.md)

