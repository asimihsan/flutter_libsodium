#import "FlutterLibsodiumPlugin.h"
#if __has_include(<flutter_libsodium/flutter_libsodium-Swift.h>)
#import <flutter_libsodium/flutter_libsodium-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_libsodium-Swift.h"
#endif

@implementation FlutterLibsodiumPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLibsodiumPlugin registerWithRegistrar:registrar];
}
@end
