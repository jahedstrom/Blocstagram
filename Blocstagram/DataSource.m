//
//  DataSource.m
//  Blocstagram
//
//  Created by Jonathan on 6/26/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import <AFNetworking/AFNetworking.h>

@interface DataSource () {
    // Why here and not in implementation?
    NSMutableArray *_mediaItems;
}

// why this line since we are using KVO and _mediaItems?
@property (nonatomic, strong) NSArray *mediaItems;  // is there also a ivar *_mediaItems that is type NSArray in addition to the above ivar?
@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;

@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;

@end

@implementation DataSource


#pragma mark - Setup/Init

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        [self createOperationManager];
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
            [self registerForAccessTokenNotification];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                        // #1 - Check for nil is in downloadImageForMediaItem: method, wouldn't be better to check here?
                        for (Media* mediaItem in self.mediaItems) {
                            [self downloadImageForMediaItem:mediaItem];
                        }
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        }
    }
    
    return self;
}

+ (NSString *)instagramClientID {
    return @"8078713534a4466b908463069927000b";
}

- (void) createOperationManager {
    NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
    self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    
    AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
    imageSerializer.imageScale = 1.0;
    
    AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
    self.instagramOperationManager.responseSerializer = serializer;
}

#pragma mark - Get Data

- (void)registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        
        //Got a token, populate with initial data
        [self populateDataWithParameters:nil completionHandler:nil];
    }];
}

- (void)populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        // only try to get data if there is an access token
        
        NSMutableDictionary *mutableParameters = [@{@"access_token" : self.accessToken} mutableCopy];  // literal syntax for mutable dictionary
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/media/recent"
                                 parameters:mutableParameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                            [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                        }
                                        
                                        if (completionHandler) {
                                            completionHandler(nil);
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        if (completionHandler) {
                                            completionHandler(error);
                                        }
                                    }];
        
    }
}

- (void)parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem];
        }
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetofNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetofNewObjects];
    } else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            // disable infinite scroll since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        } else {
            [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
        }
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    [self saveImages];
}

- (void)downloadImageForMediaItem:(Media *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]]) {
                                            mediaItem.image = responseObject;
                                            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                        }
                                        
                                        [self saveImages];
                                        
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
                                    }];
    }
}

#pragma mark - Data saving

- (NSString *)pathForFilename:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSLog(@"paths: %@", paths);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
//    NSLog(@"dataPath: %@", dataPath);
    
    return dataPath;
}

- (void) saveImages {
    
    if (self.mediaItems.count > 0) {
        // Write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
        
    }
}

#pragma mark - Pull to Request / Infinite Scrolling methods

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    
    self.thereAreNoMoreOlderMessages = NO;
    
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;

        NSString *minID = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters;
       
        if (minID) {
            parameters = @{@"min_id": minID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
        self.isLoadingOlderItems = YES;
    
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters;
        
        if (maxID) {
            parameters = @{@"max_id": maxID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

- (void)deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}



#pragma mark - KVO Functions

- (NSUInteger)countOfMediaItems {
    return self.mediaItems.count;
}

- (id)objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *)mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void)insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

- (void)removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

- (void)replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}


@end
