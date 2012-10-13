//
//  PFPhotoSubmissionManager.m
//  PhotoFlow
//
//  Created by Dan Bretl on 10/13/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotoSubmissionManager.h"

const int PhotoSubmissionStageMinimumInclusive = 0;
const int PhotoSubmissionStageMaximumInclusive = 2;

@interface PFPhotoSubmissionManager()
@property (nonatomic, strong) NSMutableArray * stages;
@end

@implementation PFPhotoSubmissionManager

- (id)init {
    self = [super init];
    if (self) {
        self.stages = [NSMutableArray array];
        for (PhotoSubmissionStage stage = PhotoSubmissionStageMinimumInclusive; stage<=PhotoSubmissionStageMaximumInclusive; stage++) {
            [self.stages addObject:@(StatusIncomplete)];
        }
    }
    return self;
}

- (PhotoSubmissionStatus)getStatusForStage:(PhotoSubmissionStage)stage {
    return [self.stages[stage] intValue];
}

- (void)setStatus:(PhotoSubmissionStatus)status forStage:(PhotoSubmissionStage)stage {
    if (status != [self getStatusForStage:stage]) {
        [self.stages replaceObjectAtIndex:stage withObject:@(status)];
        [self.delegate photoSubmissionManager:self changedStatus:status forStage:stage photoSubmissionIsComplete:self.isComplete];
    }
}

- (void)resetStatusForStage:(PhotoSubmissionStage)stage {
    [self setStatus:StatusIncomplete forStage:stage];
}

- (void)resetStatusForAll {
    for (PhotoSubmissionStage stage = PhotoSubmissionStageMinimumInclusive; stage<=PhotoSubmissionStageMaximumInclusive; stage++) {
        [self resetStatusForStage:stage];
    }
}

- (BOOL)isComplete {
    BOOL isComplete = YES;
    for (PhotoSubmissionStage stage = PhotoSubmissionStageMinimumInclusive; stage<=PhotoSubmissionStageMaximumInclusive; stage++) {
        isComplete &= ([self getStatusForStage:stage] == StatusComplete || [self getStatusForStage:stage] == StatusUnnecessary);
        if (!isComplete) { break; }
    }
    return isComplete;
}

- (void) uploadImage:(UIImage *)imageFull {
    //NSLog(@"uploadImage:(imageOfSize=%@)", NSStringFromCGSize(imageFull.size));
    
    if ([self getStatusForStage:StageImageUpload] == StatusIncomplete ||
        [self getStatusForStage:StageImageUpload] == StatusFailure) {

        [self setStatus:StatusInProgress forStage:StageImageUpload];
        
        [[PFHTTPClient sharedClient] saveImage:imageFull successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.photoEID = responseObject[@"photo_eid"];
            [self setStatus:self.photoEID != nil ? StatusComplete : StatusFailure forStage:StageImageUpload];
        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[PFHTTPClient sharedClient] logSuccess:NO forURL:operation.response.URL];
            [[PFHTTPClient sharedClient] logError:error fromOperation:operation];
            self.photoEID = nil;
            [self setStatus:StatusFailure forStage:StageImageUpload];
        }];
        
    }
    
}

- (void) cancelFileSaves {
    [[PFHTTPClient sharedClient] cancelUploadImage];
    self.photoEID = nil;
    [self setStatus:StatusIncomplete forStage:StageImageUpload];
}

- (void)savePhoto:(NSString *)photoEID toEvent:(PFEvent *)event {
    
    if ([self getStatusForStage:StagePhotoSave] == StatusIncomplete ||
        [self getStatusForStage:StagePhotoSave] == StatusFailure) {
        [self setStatus:StatusInProgress forStage:StagePhotoSave];
        
        [[PFHTTPClient sharedClient] savePhoto:photoEID toEvent:event.eid successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject != nil) {
                self.photoSubmitted = [self.moc addOrUpdatePhotoFromAPI:responseObject toEvent:event checkIfExists:NO];
                [self.moc saveCoreData];
                [self setStatus:StatusComplete forStage:StagePhotoSave];
            } else {
                self.photoSubmitted = nil;
                [self setStatus:StatusFailure forStage:StagePhotoSave];
            }
            
        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [[PFHTTPClient sharedClient] logSuccess:NO forURL:operation.response.URL];
            [[PFHTTPClient sharedClient] logError:error fromOperation:operation];
            self.photoSubmitted = nil;
            [self setStatus:StatusFailure forStage:StagePhotoSave];
            
        }];
        
    }
    
}

+ (NSString *) stringForStatus:(PhotoSubmissionStatus)status {
    NSString * string = nil;
    switch (status) {
        case StatusIncomplete:  string = @"StatusIncomplete";  break;
        case StatusInProgress:  string = @"StatusInProgress";  break;
        case StatusComplete:    string = @"StatusComplete";    break;
        case StatusFailure:     string = @"StatusFailure";     break;
        case StatusUnnecessary: string = @"StatusUnnecessary"; break;
        default:
            break;
    }
    return string;
}
+ (NSString *) stringForStage: (PhotoSubmissionStage )stage  {
    NSString * string = nil;
    switch (stage) {
        case StageImageAccepted:    string = @"StageImageAccepted";    break;
        case StageImageUpload:      string = @"StageImageUpload";      break;
        case StagePhotoSave:        string = @"StagePhotoSave";        break;
        default:
            break;
    }
    return string;
}

@end
