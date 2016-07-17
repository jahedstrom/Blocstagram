//
//  DataSource.h
//  Blocstagram
//
//  Created by Jonathan on 6/26/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

+ (instancetype)sharedInstance;

//- (void)removeItemFromDataSource:(NSUInteger)index;

- (void)deleteMediaItem:(Media *)item;

- (void)downloadImageForMediaItem:(Media *)mediaItem;

- (void)toggleLikeOnMediaItem:(Media *)mediaItem withCompletionHandler:(void (^)(void))completionHandler;

- (void)commentOnMediaItem:(Media *)mediaItem withCommentText:(NSString *)commentText;

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

+ (NSString *)instagramClientID;

@property (nonatomic, strong, readonly) NSArray *mediaItems;
@property (nonatomic, strong, readonly) NSString *accessToken;

@end
