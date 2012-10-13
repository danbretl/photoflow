//
//  NSManagedObjectContext+PhotoFlow.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "PFEvent.h"
#import "PFPhoto.h"

@interface NSManagedObjectContext (PhotoFlow)

- (void) saveCoreData;

- (NSArray *) getAllObjectsForEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
- (NSManagedObject *) getFirstObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors shouldMakeObjectIfNoMatch:(BOOL)shouldMakeObjectIfNoMatch newObjectMadeIndicator:(BOOL *)newObjectMadeIndicator;
- (NSManagedObject *) getFirstObjectForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors;

- (void) deleteAllObjectsForEntityName:(NSString *)entityName matchingPredicate:(NSPredicate *)predicate;

- (PFEvent *) addOrUpdateEventFromAPI:(NSDictionary *)objectFromAPI;
- (PFPhoto *) addOrUpdatePhotoFromAPI:(NSDictionary *)objectFromAPI toEvent:(PFEvent *)event checkIfExists:(BOOL)shouldCheckIfExists;
- (void) addPhotosFromAPI:(NSArray *)objectsFromAPI toEvent:(PFEvent *)event;

- (void) devFlushContent;
- (void) devSeedContentAfterForcedFlush:(BOOL)forceFlush;

@end
