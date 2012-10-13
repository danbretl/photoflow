//
//  PFAppDelegate.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/24/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFAppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import "LocalyticsSession.h"
#import "PFJoinEventViewController.h"
#import "PFEventsViewController.h"
#import "NSManagedObjectContext+PhotoFlow.h"
#import "UIFont+PhotoFlow.h"
#import "PFPhotosViewController.h"
#import "PFPhotoContainerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>
#import "DefaultsManager.h"

@implementation PFAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //////////////////////////////////////
    // UIAPPEARANCE CUSTOMIZATION BELOW //
    //////////////////////////////////////

    // UINavigationBar - I can't get this stuff to work for me really... Reverting back to changing things more manually per view controller.
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"nav_bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0) resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"nav_bar_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0) resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsLandscapePhone];
    
//    [UIFont logAvailableFonts];
    
    //////////////////////////////////////
    // UIAPPEARANCE CUSTOMIZATION ABOVE //
    //////////////////////////////////////
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:PFC_BASE_URL_STRING_SAVED_KEY] == nil) {
//        [[NSUserDefaults standardUserDefaults] setObject:@"http://localhost:8000" forKey:PFC_BASE_URL_STRING_SAVED_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:@"http://ec2-23-23-24-116.compute-1.amazonaws.com" forKey:PFC_BASE_URL_STRING_SAVED_KEY];
    }
    
    [[LocalyticsSession sharedLocalyticsSession] startSession:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PFLocalyticsKeyDevelopment"]];
    
    [Crashlytics startWithAPIKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PFCrashlyticsKey"]];
    
    [Parse setApplicationId:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PFParseApplicationID"] clientKey:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PFParseClientKey"]];
    // Enabling automatic anonymous users
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] incrementKey:@"appRunCount"];
    [[PFUser currentUser] saveInBackground];
    
    // The following seems rather roundabout...
    UINavigationController * rootNavController = (UINavigationController *)self.window.rootViewController;
    rootNavController.delegate = self;
    PFJoinEventViewController * joinViewController = (PFJoinEventViewController *)rootNavController.viewControllers[0];
    joinViewController.moc = self.managedObjectContext;
    NSArray * events = [self.managedObjectContext getAllObjectsForEntityName:@"PFEvent" predicate:nil sortDescriptors:nil];
    if (events.count > 0) {
        PFEventsViewController * eventsViewController = [rootNavController.storyboard instantiateViewControllerWithIdentifier:@"PFEventsViewController"];
        eventsViewController.moc = self.managedObjectContext;
        [rootNavController pushViewController:eventsViewController animated:NO];
    }
    
    return YES;
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // Navbar visibility
    if (![viewController isKindOfClass:[PFJoinEventViewController class]]) {
        navigationController.navigationBarHidden = NO;
    }
    
    // Toolbar visibility
    if ([viewController isKindOfClass:[PFJoinEventViewController class]] ||
        [viewController isKindOfClass:[PFEventsViewController    class]]    ) {
        [navigationController setToolbarHidden:YES animated:animated];
    } else {
        [navigationController setToolbarHidden:NO animated:animated];
        // Toolbar background image
        NSString * toolbarImageName = @"toolbar.png";
        if ([viewController isKindOfClass:[PFPhotoContainerViewController class]]) toolbarImageName = [toolbarImageName stringByReplacingOccurrencesOfString:@".png" withString:@"_photos.png"];
        [navigationController.toolbar setBackgroundImage:[[UIImage imageNamed:toolbarImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 0, 0, 0)] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
        [navigationController.toolbar setBackgroundImage:[[UIImage imageNamed:toolbarImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 0, 0, 0)] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsLandscapePhone];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
    [DefaultsManager setAppDidEnterBackgroundSinceEventReload:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PhotoFlow" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PhotoFlow.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
