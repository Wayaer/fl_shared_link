#import "FlBeSharedPlugin.h"
#if __has_include(<fl_be_shared/fl_be_shared-Swift.h>)
#import <fl_be_shared/fl_be_shared-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "fl_be_shared-Swift.h"
#endif

@implementation FlBeSharedPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlBeSharedPlugin registerWithRegistrar:registrar];
}
@end
