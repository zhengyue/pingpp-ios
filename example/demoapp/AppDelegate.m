//
//  AppDelegate.m
//  AppDelegate
//
//  Created by Jacky Hu on 07/14/14.
//

#import "AppDelegate.h"
#import "Pingpp.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    ViewController* root = [[ViewController alloc] init];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:root];

    self.viewController = nav;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    /*----------------------------
     
     set Ping++ SDK to debug mode,
     so no real payment is made
     
     -----------------------------*/
    [Pingpp setDebugMode:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

/*-------------------------------------------------------------------------------------
 
 Note from Step 3:
 
 handle payment notifications if user has installed WeChat or AliPay app. After user finished payment,
 WeChat or AliPay will open our app using our URL scheme. We need to call this [Pingpp handleOpenURL:] method to
 pass the result to the calling block.
 
 for iOS 8 and below, implement application:openURL:sourceApplication:annotation
 for iOS 9 and later, implement application:openURL:options
 
 -------------------------------------------------------------------------------------*/
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [Pingpp handleOpenURL:url withCompletion:nil];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    return [Pingpp handleOpenURL:url withCompletion:nil];
}

@end
