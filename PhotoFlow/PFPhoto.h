//
//  PFPhoto.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PFEvent;

@interface PFPhoto : NSManagedObject

@property (nonatomic, retain) PFEvent *event;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * eid;
@property (nonatomic, retain) NSDate * updatedAt;

@end
