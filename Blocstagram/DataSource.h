//
//  DataSource.h
//  Blocstagram
//
//  Created by Jonathan on 6/26/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

@interface DataSource : NSObject

+ (instancetype)sharedInstance;

//- (void)removeItemFromDataSource:(NSUInteger)index;

- (void)deleteMediaItem:(Media *)item;

@property (nonatomic, strong, readonly) NSArray *mediaItems;

@end
