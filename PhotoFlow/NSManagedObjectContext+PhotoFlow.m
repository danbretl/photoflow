//
//  NSManagedObjectContext+PhotoFlow.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "NSManagedObjectContext+PhotoFlow.h"
#import "PFHTTPClient.h"

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

- (void)deleteAllObjectsForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate {
    NSArray * allObjects = [self getAllObjectsForEntityName:entityName predicate:predicate sortDescriptors:nil];
    for (id object in allObjects) {
        [self deleteObject:object];
    }
}

- (PFEvent *)addOrUpdateEventFromAPI:(NSDictionary *)objectFromAPI {
    BOOL newObjectMadeIndicator;
    PFEvent * object = (PFEvent *)[self getFirstObjectForEntityName:@"PFEvent" matchingPredicate:[NSPredicate predicateWithFormat:@"eid == %@", objectFromAPI[@"eid"]] usingSortDescriptors:nil shouldMakeObjectIfNoMatch:YES newObjectMadeIndicator:&newObjectMadeIndicator];
    if (newObjectMadeIndicator) object.eid = objectFromAPI[@"eid"];
    object.title = objectFromAPI[@"title"];
    object.descriptionShort = objectFromAPI[@"descriptionShort"];
    object.location = objectFromAPI[@"location"];
    object.date = [[PFHTTPClient sharedClient] dateFromString:objectFromAPI[@"date"]];
    return object;
}

- (PFPhoto *)addOrUpdatePhotoFromAPI:(NSDictionary *)objectFromAPI toEvent:(PFEvent *)event checkIfExists:(BOOL)shouldCheckIfExists {
    PFPhoto * object = nil;
    if (shouldCheckIfExists) {
        BOOL newObjectMadeIndicator;
        object = (PFPhoto *)[self getFirstObjectForEntityName:@"PFPhoto" matchingPredicate:[NSPredicate predicateWithFormat:@"eid == %@", objectFromAPI[@"eid"]] usingSortDescriptors:nil shouldMakeObjectIfNoMatch:YES newObjectMadeIndicator:&newObjectMadeIndicator];
        if (newObjectMadeIndicator) object.eid = objectFromAPI[@"eid"];
    } else {
        object = [NSEntityDescription insertNewObjectForEntityForName:@"PFPhoto" inManagedObjectContext:self];
        object.eid = objectFromAPI[@"eid"];
    }
    object.createdAt = [[PFHTTPClient sharedClient] dateFromString:objectFromAPI[@"createdAt"]];
    object.updatedAt = [[PFHTTPClient sharedClient] dateFromString:objectFromAPI[@"updatedAt"]];
    object.event = event;
    return object;
}

- (void)addPhotosFromAPI:(NSArray *)objectsFromAPI toEvent:(PFEvent *)event {
    for (NSDictionary * objectFromAPI in objectsFromAPI) {
        [self addOrUpdatePhotoFromAPI:objectFromAPI toEvent:event checkIfExists:NO];
    }
}

- (void)devFlushContent {
    // Delete all Events. The Photos should be deleted from cascades.
    [self deleteAllObjectsForEntityName:@"PFEvent" matchingPredicate:nil];
}

// Event 0 - 6 photos
// Event 1 - 5 photos
// image url like https://dl.dropbox.com/u/7634478/iOS/PhotoFlow/event0-0.jpg
- (void)devSeedContentAfterForcedFlush:(BOOL)forceFlush {
    
    NSMutableDictionary * event0 = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Jim & Amy", @"descriptionShort" : @"Jim & Amy's Wedding", @"location" : @"Santa Clara, CA", @"photosCount" : @6}];
    NSMutableDictionary * event1 = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Duane & Linda", @"descriptionShort" : @"Duane & Linda's Wedding", @"location" : @"Rochester, NY", @"photosCount" : @5}];
    NSMutableDictionary * event2 = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"NY Giants Game", @"descriptionShort" : @"NY Giants vs MN Vikings", @"location" : @"East Rutherford, NJ", @"photosCount" : @5}];
    
    NSTimeInterval secondsInDay = 60 * 60 * 24;
    NSArray * events = @[event0, event1, event2];
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
//            photoCoreData.imageLocation = photo[@"imageLocation"];
            photoCoreData.event = eventCoreData;
            photoCoreData.eid = @"foo";
        }
    }
    
}

@end
