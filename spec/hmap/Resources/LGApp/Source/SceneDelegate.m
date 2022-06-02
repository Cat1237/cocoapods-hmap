//
//  SceneDelegate.m
//  LGApp
//
//  Created by ws on 2021/8/12.
//

#import "SceneDelegate.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

@end

/**
 /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -x objective-c -target x86_64-apple-ios14.5-simulator -fmessage-length\=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit\=0 -std\=gnu11 -fobjc-arc -fobjc-weak -fmodules -gmodules -fmodules-cache-path\=/Users/ws/Library/Developer/Xcode/DerivedData/ModuleCache.noindex -fmodules-prune-interval\=86400 -fmodules-prune-after\=345600 -fbuild-session-file\=/Users/ws/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/Session.modulevalidation -fmodules-validate-once-per-build-session -Wnon-modular-include-in-framework-module -Werror\=non-modular-include-in-framework-module -Wno-trigraphs -fpascal-strings -O0 -fno-common -Wno-missing-field-initializers -Wno-missing-prototypes -Werror\=return-type -Wdocumentation -Wunreachable-code -Wno-implicit-atomic-properties -Werror\=deprecated-objc-isa-usage -Wno-objc-interface-ivars -Werror\=objc-root-class -Wno-arc-repeated-use-of-weak -Wimplicit-retain-self -Wduplicate-method-match -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wuninitialized -Wconditional-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wno-float-conversion -Wnon-literal-null-conversion -Wobjc-literal-conversion -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wundeclared-selector -Wdeprecated-implementations -DDEBUG\=1 -DCOCOAPODS\=1 -DOBJC_OLD_DISPATCH_PROTOTYPES\=0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator15.2.sdk -fasm-blocks -fstrict-aliasing -Wprotocol -Wdeprecated-declarations -g -Wno-sign-conversion -Winfinite-recursion -Wcomma -Wblock-capture-autoreleasing -Wstrict-prototypes -Wno-semicolon-before-method-body -Wunguarded-availability -fobjc-abi-version\=2 -fobjc-legacy-dispatch -index-store-path /Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Index/DataStore -iquote /Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/HMap/LGApp.build/Debug-iphonesimulator/LGApp.build/project-headers.hmap -iquote /Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/HMap/LGApp.build/Debug-iphonesimulator/LGApp.build/project-headers.hmap -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/include -I/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/HMap/LGApp.build/Debug-iphonesimulator/LGApp.build/all-non-framework-target-headers.hmap -I/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/HMap/LGApp.build/Debug-iphonesimulator/LGApp.build/own-target-headers.hmap -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/AFNetworking/AFNetworking.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/CocoaLumberjack/CocoaLumberjack.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/GoogleUtilities/GoogleUtilities.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/IGListDiffKit/IGListDiffKit.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/IGListKit/IGListKit.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/Kingfisher/Kingfisher.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/MagicalRecord/MagicalRecord.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/PromisesObjC/FBLPromises.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/Realm/Realm.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/YYKit/YYKit.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/iOS-Echarts/iOS_Echarts.framework/Headers -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/XCFrameworkIntermediates/Realm/Headers -I/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/HMap/LGApp.build/Debug-iphonesimulator/LGApp.build/all-non-framework-target-headers.hmap -I/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/HMap/LGApp.build/Debug-iphonesimulator/LGApp.build/own-target-headers.hmap -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Intermediates.noindex/LGApp.build/Debug-iphonesimulator/LGApp.build/DerivedSources-normal/x86_64 -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Intermediates.noindex/LGApp.build/Debug-iphonesimulator/LGApp.build/DerivedSources/x86_64 -I/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Intermediates.noindex/LGApp.build/Debug-iphonesimulator/LGApp.build/DerivedSources -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/AFNetworking -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/CocoaLumberjack -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/GoogleUtilities -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/IGListDiffKit -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/IGListKit -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/Kingfisher -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/MagicalRecord -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/PromisesObjC -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/Realm -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/YYKit -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/iOS-Echarts -F/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/Pods/FBAEMKit/XCFrameworks -F/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/Pods/FBSDKCoreKit/XCFrameworks -F/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/Pods/FBSDKCoreKit_Basics/XCFrameworks -F/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/Pods/FBSDKShareKit/XCFrameworks -F/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/Pods/Realm/core -F/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/Pods/YYKit/Vendor -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/XCFrameworkIntermediates/FBAEMKit -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/XCFrameworkIntermediates/FBSDKCoreKit -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/XCFrameworkIntermediates/FBSDKCoreKit_Basics -F/Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Products/Debug-iphonesimulator/XCFrameworkIntermediates/FBSDKShareKit -F/Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp -ivfsoverlay /Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/HMap/LGApp.build/Debug-iphonesimulator/LGApp.build/all-product-headers.yaml -ivfsoverlay /Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/HMap/LGApp.build/Debug-iphonesimulator/LGApp.build/all-product-headers.yaml -MMD -MT dependencies -MF /Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Intermediates.noindex/LGApp.build/Debug-iphonesimulator/LGApp.build/Objects-normal/x86_64/SceneDelegate.d --serialize-diagnostics /Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Intermediates.noindex/LGApp.build/Debug-iphonesimulator/LGApp.build/Objects-normal/x86_64/SceneDelegate.dia -c /Users/ws/Documents/MyLib/cocoapods-hmap/spec/hmap/Resources/LGApp/Source/SceneDelegate.m -o /Users/ws/Library/Developer/Xcode/DerivedData/LGApp-fosvozugmnvzjphepojeuknaclrd/Build/Intermediates.noindex/LGApp.build/Debug-iphonesimulator/LGApp.build/Objects-normal/x86_64/SceneDelegate.o
 */
