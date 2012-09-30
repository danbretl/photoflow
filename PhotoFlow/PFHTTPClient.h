//
//  PFHTTPClient.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/29/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "AFNetworking.h"

typedef enum {
    EmotishClientDateNone = 0,
    EmotishClientDateCreated = 1,
    EmotishClientDateUpdated = 2,
} EmotishClientDateType;

typedef void(^PFCSuccessBlock)(AFHTTPRequestOperation * operation, id responseObject);
typedef void(^PFCFailureBlock)(AFHTTPRequestOperation * operation, NSError * error);

extern NSString * const PFC_BASE_URL_STRING_SAVED_KEY;

@interface PFHTTPClient : AFHTTPClient

+ (PFHTTPClient *) sharedClient;
+ (void) clearCookiesForURL:(NSURL *)url;
- (void) setAuthorizationHeaderWithUsername:(NSString *)username userServerID:(NSString *)userServerID;

// Get details for given event
// Response: { event_eid, title, descriptionShort, location, date, coverPhoto }
- (void) getEventDetails:(NSString *)eventEID successBlock:(PFCSuccessBlock)successBlock failureBlock:(PFCFailureBlock)failureBlock;

// Get photos for a given event
// Response: { photos } (sorted most recent to oldest)
- (void) getPhotosForEvent:(NSString *)eventEID limit:(NSNumber *)limit updatedAfter:(NSDate *)updatedAfter updatedBefore:(NSDate *)updatedBefore successBlock:(PFCSuccessBlock)successBlock failureBlock:(PFCFailureBlock)failureBlock;

// Get an image for a given photo
- (NSString *) imageURLStringForPhoto:(NSString *)photoEID size:(int)size quality:(int)quality;

// Save image
// Response: { photo_eid }
- (void) saveImage:(UIImage *)image successBlock:(PFCSuccessBlock)successBlock failureBlock:(PFCFailureBlock)failureBlock;
- (void) cancelUploadImage;

// Save photo
// Response: { status, photo }
- (void) savePhoto:(NSString *)photoEID toEvent:(NSString *)eventEID successBlock:(PFCSuccessBlock)successBlock failureBlock:(PFCFailureBlock)failureBlock;

// Delete a given photo
// Response code 204 for success, 404 for failure
// Response: { status }
- (void) deletePhoto:(NSString *)photoEID successBlock:(PFCSuccessBlock)successBlock failureBlock:(PFCFailureBlock)failureBlock;

- (NSString *) stringFromDate:(NSDate   *)date;
- (NSDate   *) dateFromString:(NSString *)string;
@property (nonatomic, strong, readonly) NSDateFormatter * datetimeFormatterNormal;

////////////
// LOGGING
- (void) logSuccess:(BOOL)success forURL:(NSURL *)url;
- (void) logCountForArray:(NSArray *)array ofObjectsWithNoun:(NSString *)objectPluralNoun;
- (void) logResponseObject:(id)responseObject;
- (void) logError:(NSError *)error fromOperation:(AFHTTPRequestOperation *)operation;
- (void) logString:(NSString *)string;

@end
