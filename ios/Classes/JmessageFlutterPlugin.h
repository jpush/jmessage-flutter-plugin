#import <Flutter/Flutter.h>
#import <JMessage/JMessage.h>

@interface JmessageFlutterPlugin : NSObject<FlutterPlugin, JMessageDelegate>
@property NSString *JMessageAppKey;
@property NSDictionary *launchOptions;
@property FlutterMethodChannel *channel;
@end
