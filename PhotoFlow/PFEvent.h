//
//  PFEvent.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PFPhoto;

@interface PFEvent : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * descriptionShort;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * eid;
@property (nonatomic, retain) NSDate * dateGetOld;
@property (nonatomic, retain) NSDate * dateGetRecent;

@end

@interface PFEvent (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(PFPhoto *)value;
- (void)removePhotosObject:(PFPhoto *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
