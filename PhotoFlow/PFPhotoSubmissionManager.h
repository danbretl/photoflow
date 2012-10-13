//
//  PFPhotoSubmissionManager.h
//  PhotoFlow
//
//  Created by Dan Bretl on 10/13/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "NSManagedObjectContext+PhotoFlow.h"
#import "PFHTTPClient.h"
#import "PFEvent.h"

extern const int PhotoSubmissionStageMinimumInclusive;
extern const int PhotoSubmissionStageMaximumInclusive;
typedef enum {
    StageImageAccepted    = 0,
    StageImageUpload      = 1,
    StagePhotoSave        = 2,
} PhotoSubmissionStage; // If these values are edited, then so should be PhotoSubmissionStageMinimumInclusive && PhotoSubmissionStageMaximumInclusive.

typedef enum {
    StatusIncomplete  = 0,
    StatusInProgress  = 1,
    StatusComplete    = 2,
    StatusFailure     = 3,
    StatusUnnecessary = 4,
} PhotoSubmissionStatus;

@protocol PFPhotoSubmissionManagerDelegate;

@interface PFPhotoSubmissionManager : NSObject

@property (nonatomic, unsafe_unretained) id<PFPhotoSubmissionManagerDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext * moc;

- (PhotoSubmissionStatus) getStatusForStage:(PhotoSubmissionStage)stage;
- (void) setStatus:(PhotoSubmissionStatus)status forStage:(PhotoSubmissionStage)stage;
- (void) resetStatusForStage:(PhotoSubmissionStage)stage;
- (void) resetStatusForAll;
@property (nonatomic, readonly) BOOL isComplete;

// Web interaction
@property (nonatomic, strong) NSString * photoEID;
- (void) uploadImage:(UIImage *)imageFull;
- (void) cancelFileSaves;
- (void) savePhoto:(NSString *)photoEID toEvent:(PFEvent *)event;
@property (nonatomic, strong) PFPhoto * photoSubmitted;

// Util
+ (NSString *) stringForStatus:(PhotoSubmissionStatus)status;
+ (NSString *) stringForStage: (PhotoSubmissionStage )stage ;

@end

@protocol PFPhotoSubmissionManagerDelegate <NSObject>
- (void) photoSubmissionManager:(PFPhotoSubmissionManager *)manager changedStatus:(PhotoSubmissionStatus)statusNew forStage:(PhotoSubmissionStage)stage photoSubmissionIsComplete:(BOOL)isComplete;
@end