#import "EyflutterUikitPlugin.h"
#if __has_include(<eyflutter_uikit/eyflutter_uikit-Swift.h>)
#import <eyflutter_uikit/eyflutter_uikit-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "eyflutter_uikit-Swift.h"
#endif

@implementation EyflutterUikitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEyflutterUikitPlugin registerWithRegistrar:registrar];
}
@end
