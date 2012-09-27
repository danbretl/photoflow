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

@property (nonatomic, retain) NSString * imageLocation;
@property (nonatomic, retain) PFEvent *event;

@end
