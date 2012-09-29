//
//  NSManagedObjectContext+PhotoFlow.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "NSManagedObjectContext+PhotoFlow.h"

@implementation NSManagedObjectContext (PhotoFlow)

- (void)saveCoreData {
    NSError *error = nil;
    if (self.hasChanges && ![self save:&error]) {
        abort();
    }
}

- (NSArray *) getAllObjectsForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
	[fetchRequest setEntity:entity];
    if (predicate)       { [fetchRequest setPredicate:predicate]; }
    if (sortDescriptors) { [fetchRequest setSortDescriptors:sortDescriptors]; }
	NSError * error;
	NSArray * fetchedObjects = [self executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

- (NSManagedObject *)getFirstObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors {
    BOOL newObjectMadeIndicator;
    return [self getFirstObjectForEntityName:entityName matchingPredicate:predicate usingSortDescriptors:sortDescriptors shouldMakeObjectIfNoMatch:NO newObjectMadeIndicator:&newObjectMadeIndicator];
}

- (NSManagedObject *)getFirstObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors shouldMakeObjectIfNoMatch:(BOOL)shouldMakeObjectIfNoMatch newObjectMadeIndicator:(BOOL *)newObjectMadeIndicator {
    NSArray * matchingObjects = [self getAllObjectsForEntityName:entityName predicate:predicate sortDescriptors:sortDescriptors];
    NSManagedObject * matchingObject = matchingObjects.count > 0 ? [matchingObjects objectAtIndex:0] : nil;
    if (shouldMakeObjectIfNoMatch && matchingObject == nil) {
        matchingObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self];
        *newObjectMadeIndicator = YES;
    } else {
        *newObjectMadeIndicator = NO;
    }
    return matchingObject;
}

- (void)deleteAllObjectsForEntityName:(NSString *)entityName {
    NSArray * allObjects = [self getAllObjectsForEntityName:entityName predicate:nil sortDescriptors:nil];
    for (id object in allObjects) {
        [self deleteObject:object];
    }
}

- (void)devFlushContent {
    // Delete all Events. The Photos should be deleted from cascades.
    [self deleteAllObjectsForEntityName:@"PFEvent"];
}

// Event 0 - 6 photos
// Event 1 - 5 photos
// image url like https://dl.dropbox.com/u/7634478/iOS/PhotoFlow/event0-0.jpg
- (void)devSeedContentAfterForcedFlush:(BOOL)forceFlush {
    
    NSMutableDictionary * event0 = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Jim & Amy", @"descriptionShort" : @"Jim & Amy's Wedding", @"location" : @"Santa Clara, CA", @"photosCount" : @6}];
    NSMutableDictionary * event1 = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Duane & Linda", @"descriptionShort" : @"Duane & Linda's Wedding", @"location" : @"Rochester, NY", @"photosCount" : @5}];
    
    NSTimeInterval secondsInDay = 60 * 60 * 24;
    NSArray * events = @[event0, event1];
    for (NSMutableDictionary * event in events) {
        NSUInteger indexEvent = [events indexOfObject:event];
        [event setObject:[NSDate dateWithTimeIntervalSinceNow:secondsInDay * (indexEvent * 5)] forKey:@"date"];
        int photosCount = [[event objectForKey:@"photosCount"] intValue];
        if (photosCount > 0) {
            NSMutableArray * photos = [NSMutableArray array];
            for (int p=0; p<photosCount; p++) {
                [photos addObject:@{@"imageLocation" : [NSString stringWithFormat:@"https://dl.dropbox.com/u/7634478/iOS/PhotoFlow/event%d-%d.jpg", indexEvent, p]}];
            }
            [event setObject:photos forKey:@"photos"];
        }
    }
    
    NSArray * coreDataEvents = [self getAllObjectsForEntityName:@"PFEvent" predicate:nil sortDescriptors:nil];
    if (forceFlush || coreDataEvents.count < events.count) {
        [self devFlushContent];
    }
    for (NSDictionary * event in events) {
        PFEvent * eventCoreData = [NSEntityDescription insertNewObjectForEntityForName:@"PFEvent" inManagedObjectContext:self];
        eventCoreData.date = event[@"date"];
        eventCoreData.title = event[@"title"];
        eventCoreData.descriptionShort = event[@"descriptionShort"];
        eventCoreData.location = event[@"location"];
        for (NSDictionary * photo in event[@"photos"]) {
            PFPhoto * photoCoreData = [NSEntityDescription insertNewObjectForEntityForName:@"PFPhoto" inManagedObjectContext:self];
            photoCoreData.imageLocation = photo[@"imageLocation"];
            photoCoreData.event = eventCoreData;
        }
    }
    
}

@end
