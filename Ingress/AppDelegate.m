//
//  AppDelegate.m
//  Ingress
//
//  Created by Alex Studnicka on 08.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize mapView = _mapView;

+ (AppDelegate *)instance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.

	[MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
	[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Ingress.sqlite"];

	[[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:@"Coda-Regular" size:16]}];
	[[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:@"Coda-Regular" size:10]} forState:UIControlStateNormal];
	[[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:@"Coda-Regular" size:10]} forState:UIControlStateNormal];
	[[UISegmentedControl appearance] setTitleTextAttributes:@{UITextAttributeFont: [UIFont fontWithName:@"Coda-Regular" size:10]} forState:UIControlStateNormal];
	[[UILabel appearance] setFont:[UIFont fontWithName:@"Coda-Regular" size:16]];
	[[UIButton appearance] setFont:[UIFont fontWithName:@"Coda-Regular" size:16]];
	[[UIButton appearanceWhenContainedIn:[UIActionSheet class], nil] setFont:[UIFont fontWithName:@"Coda-Regular" size:18]];
	[[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setFont:[UIFont fontWithName:@"Coda-Regular" size:12]];
	[[UITextField appearance] setFont:[UIFont fontWithName:@"Coda-Regular" size:16]];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[MagicalRecord cleanUp];
	[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Ingress.sqlite"];
	[[API sharedInstance] setPlayer:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	
	// Saves changes in the application's managed object context before the application terminates.
	[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
	[MagicalRecord cleanUp];
}

@end
