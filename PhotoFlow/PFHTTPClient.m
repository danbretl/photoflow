//
//  PFHTTPClient.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/29/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFHTTPClient.h"

NSString * const PFC_BASE_URL_STRING_SAVED_KEY    = @"devBaseURL" ;

@interface PFHTTPClient()
@property (strong, nonatomic) AFJSONRequestOperation * uploadImageOperation;
@property (nonatomic, strong, readonly) NSMutableArray * datetimeFormattersVariablePrecision;
- (NSDateFormatter *) datetimeFormatterWithPrecision:(int)precision;
@end

@implementation PFHTTPClient
@synthesize datetimeFormatterNormal=_datetimeFormatterNormal;
@synthesize datetimeFormattersVariablePrecision=_datetimeFormattersVariablePrecision;
@synthesize uploadImageOperation;

+ (PFHTTPClient *)sharedClient {
    static PFHTTPClient * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:PFC_BASE_URL_STRING_SAVED_KEY]]];
    });
    return sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        // Custom settings
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setParameterEncoding:AFJSONParameterEncoding];
    }
    return self;
}

- (void) setAuthorizationHeaderWithUsername:(NSString *)username userServerID:(NSString *)userServerID {
    [self setAuthorizationHeaderWithUsername:username password:userServerID];
}

+ (void)clearCookiesForURL:(NSURL *)url {
    NSArray * specificCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    int deletedCount = 0;
    for (NSHTTPCookie * cookie in specificCookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        deletedCount++;
    }
}

////////////////////
// GETTING EVENTS //
////////////////////

- (void)getEventDetails:(NSString *)eventEID successBlock:(PFCSuccessBlock)successBlock failureBlock:(PFCFailureBlock)failureBlock {
    [self getPath:[NSString stringWithFormat:@"/api/v1/events/%@/", eventEID] parameters:nil success:successBlock failure:failureBlock];
}

////////////////////
// GETTING PHOTOS //
////////////////////

- (void)getPhotosForEvent:(NSString *)eventEID limit:(NSNumber *)limit updatedAfter:(NSDate *)updatedAfter updatedBefore:(NSDate *)updatedBefore successBlock:(PFCSuccessBlock)successBlock failureBlock:(PFCFailureBlock)failureBlock {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    if (limit) {
        [parameters setObject:limit forKey:@"limit"];
    }
    
    if (updatedAfter) {
        [parameters setObject:[self stringFromDate:updatedAfter] forKey:@"updatedAfter"];
    }
    if (updatedBefore) {
        [parameters setObject:[self stringFromDate:updatedBefore] forKey:@"updatedBefore"];
    }
    
    [self getPath:[NSString stringWithFormat:@"/api/v1/events/%@/photos/", eventEID] parameters:parameters success:successBlock failure:failureBlock];
    
}

////////////////////
// GETTING IMAGES //
////////////////////

- (NSString *)imageURLStringForPhoto:(NSString *)photoEID {
    return [NSString stringWithFormat:@"%@/api/v1/images/%@/", self.baseURL.absoluteString, photoEID];
}

- (NSString *)imageURLStringForPhoto:(NSString *)photoEID size:(NSUInteger)size quality:(NSUInteger)quality {
    return [[self imageURLStringForPhoto:photoEID] stringByAppendingFormat:@"%d/%d/", size, quality];
}

///////////////////
// SAVING IMAGES //
///////////////////

- (void) saveImage:(UIImage *)image successBlock:(PFCSuccessBlock)successBlock failureBlock:(PFCFailureBlock)failureBlock {
    
    CGFloat compressionQuality = /*0.8;*/1.0;
    NSData * imageData = UIImageJPEGRepresentation(image, compressionQuality);
    NSString * filename = [NSString stringWithFormat:@"%d.jpg", abs([[NSDate date] timeIntervalSince1970])];
    NSMutableURLRequest * request = [self multipartFormRequestWithMethod:@"POST" path:@"/api/v1/images/" parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:filename mimeType:@"image/jpeg"];
    }];
    
    self.uploadImageOperation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [self.uploadImageOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        //        NSLog(@"Uploading image, sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [self.uploadImageOperation setCompletionBlockWithSuccess:successBlock failure:failureBlock];
    [self.uploadImageOperation start];
}
- (void) cancelUploadImage {
    [self.uploadImageOperation cancel];
}

///////////////////
// SAVING PHOTOS //
///////////////////


- (void)savePhoto:(NSString *)photoEID toEvent:(NSString *)eventEID successBlock:(PFCSuccessBlock)successBlock failureBlock:(PFCFailureBlock)failureBlock {
    NSDictionary * parameters = @{@"event_id" : eventEID};
    [self putPath:[NSString stringWithFormat:@"/api/v1/photos/%@/", photoEID] parameters:parameters success:successBlock failure:failureBlock];
}

/////////////////////
// DELETING PHOTOS //
/////////////////////

- (void) deletePhoto:(NSString *)photoEID successBlock:(PFCSuccessBlock)successBlock failureBlock:(PFCFailureBlock)failureBlock {
    [self deletePath:[NSString stringWithFormat:@"/api/v1/photos/"] parameters:@{@"photo_eid" : photoEID} success:successBlock failure:failureBlock];
}

/////////////////////////
// DATETIME FORMATTING //
/////////////////////////

- (NSString *)stringFromDate:(NSDate *)date {
    return [self.datetimeFormatterNormal stringFromDate:date];
}

- (NSDate *)dateFromString:(NSString *)string {
    NSDate * date = [self.datetimeFormatterNormal dateFromString:string];
    if (date == nil) {
        int precision = 0;
        NSRange decimalRange = [string rangeOfString:@"."];
        if (decimalRange.location != NSNotFound) {
            NSRange zRange = [string rangeOfString:@"Z"];
            precision = zRange.location - decimalRange.location - decimalRange.length;
        }
        date = [[self datetimeFormatterWithPrecision:precision] dateFromString:string];
    }
    return date;
}

- (NSDateFormatter *)datetimeFormatterNormal {
    if (_datetimeFormatterNormal == nil) {
        _datetimeFormatterNormal = [[NSDateFormatter alloc] init];
        _datetimeFormatterNormal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        [_datetimeFormatterNormal setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    }
    return _datetimeFormatterNormal;
}

- (NSMutableArray *)datetimeFormattersVariablePrecision {
    if (_datetimeFormattersVariablePrecision == nil) {
        _datetimeFormattersVariablePrecision = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], nil];
    }
    return _datetimeFormattersVariablePrecision;
}

- (NSDateFormatter *)datetimeFormatterWithPrecision:(int)precision {
    NSDateFormatter * datetimeFormatter = nil;
    if ([[self.datetimeFormattersVariablePrecision objectAtIndex:precision] isEqual:[NSNull null]]) {
        datetimeFormatter = [[NSDateFormatter alloc] init];
        datetimeFormatter.timeZone = self.datetimeFormatterNormal.timeZone;
        NSMutableString * precisionString = [NSMutableString stringWithString:@""];
        if (precision > 0) {
            [precisionString appendString:@"."];
            for (int i=precision; i>0; i--) {
                [precisionString appendString:@"S"];
            }
        }
        datetimeFormatter.dateFormat = [self.datetimeFormatterNormal.dateFormat stringByReplacingOccurrencesOfString:@".SSS" withString:precisionString];
        [self.datetimeFormattersVariablePrecision replaceObjectAtIndex:precision withObject:datetimeFormatter];
    }
    return [self.datetimeFormattersVariablePrecision objectAtIndex:precision];
}

/////////////
// LOGGING //
/////////////

- (void) logSuccess:(BOOL)success forURL:(NSURL *)url {
    [self logString:[NSString stringWithFormat:@"PFHTTPClient %@ for URL %@", success ? @"success" : @"failure", url.absoluteString]];
}
- (void) logCountForArray:(NSArray *)array ofObjectsWithNoun:(NSString *)objectPluralNoun {
    [self logString:[NSString stringWithFormat:@"Retrieved %d %@", array.count, objectPluralNoun]];
}
- (void) logResponseObject:(id)responseObject {
    [self logString:[NSString stringWithFormat:@"%@", responseObject]];
}
- (void) logError:(NSError *)error fromOperation:(AFHTTPRequestOperation *)operation {
    [self logString:[NSString stringWithFormat:@"%@", error]];
    if (operation != nil) {
        [self logString:[NSString stringWithFormat:@"%@", operation.responseString]];
    }
}
- (void) logString:(NSString *)string {
    NSLog(@"%@", string);
}

@end
