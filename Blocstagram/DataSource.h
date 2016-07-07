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

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

@property (nonatomic, strong, readonly) NSArray *mediaItems;

@end
