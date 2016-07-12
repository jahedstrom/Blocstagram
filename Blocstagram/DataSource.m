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

@interface DataSource () {
    NSMutableArray *_mediaItems;
}

// why this line since we are using KVO and _mediaItems?
@property (nonatomic, strong) NSArray *mediaItems;
@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;

@end

@implementation DataSource

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
//        [self addRandomData];
        [self registerForAccessTokenNotification];
    }
    
    return self;
}

- (void)registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        
        //Got a token, populate with initial data
        [self populateDataWithParameters:nil];
    }];
}

- (void)populateDataWithParameters:(NSDictionary *)parameters {
    if (self.accessToken) {
        // only try to get data if there is an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
           // do the network request in the background, so the UI doesn't lock up
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/recent?access_token=%@", self.accessToken];
            
            for (NSString *parameterName in parameters) {
                // for example, if dictionary contains {count: 50}, append '&count=50' to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                if (responseData) {
                    NSError *jsonError;
                    NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    
                    if (feedDictionary) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // done networking, go back on the main thread
                            [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                        });
                    }
                }
            }
        });
    }
}

- (void)parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSLog(@"%@", feedDictionary);
}

//- (void)addRandomData {
//    NSMutableArray *randomMediaItems = [NSMutableArray array];
//    
//    for (int i = 1; i <= 10; i++) {
//        NSString *imageName = [NSString stringWithFormat:@"%d.jpg" ,i];
//        UIImage *image = [UIImage imageNamed:imageName];
//        
//        if (image) {
//            Media *media = [[Media alloc] init];
//            media.user = [self randomUser];
//            media.image = image;
//            media.caption = [self randomSentence];
//            
//            NSUInteger commentCount = arc4random_uniform(10) + 2;
//            NSMutableArray *randomComments = [NSMutableArray array];
//            
//            // Bloc checkpoint says i <= commentCount, but that will add one more
//            // comment than commentCount..
//            for (int j = 0; j < commentCount; j++) {
//                Comment *randomComment = [self randomComment];
//                [randomComments addObject:randomComment];
//            }
//            
//            media.comments = randomComments;
//            
//            [randomMediaItems addObject:media];
//        }
//    }
//    
//    self.mediaItems = randomMediaItems;
//    
//}

/*
- (void)removeItemFromDataSource:(NSUInteger)index {
    NSMutableArray *tempMediaItems = [NSMutableArray arrayWithArray:self.mediaItems];
    
    if (index < tempMediaItems.count) {
        [tempMediaItems removeObjectAtIndex:index];
    }
    
    self.mediaItems = tempMediaItems;
}
*/

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
//        Media *media = [[Media alloc] init];
//        media.user = [self randomUser];
//        media.image = [UIImage imageNamed:@"10.jpg"];
//        media.caption = [self randomSentence];
//        
//        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
//        [mutableArrayWithKVO insertObject:media atIndex:0];
        
        // TODO: Add images..
        
        self.isRefreshing = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    
    if (self.isLoadingOlderItems == NO) {
        self.isLoadingOlderItems = YES;
//        Media *media = [[Media alloc] init];
//        media.user = [self randomUser];
//        media.image = [UIImage imageNamed:@"1.jpg"];
//        media.caption = [self randomSentence];
//        
//        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
//        [mutableArrayWithKVO addObject:media];
        
        // TODO: Add images..
        
        self.isLoadingOlderItems = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (void)deleteMediaItem:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

+ (NSString *)instagramClientID {
    return @"8078713534a4466b908463069927000b";
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

#pragma mark - Helper Functions


//- (User *)randomUser {
//    User *user = [[User alloc] init];
//    
//    user.userName = [self randomStringOfLength:arc4random_uniform(10) + 2];
//    
//    NSString *firstName = [self randomStringOfLength:arc4random_uniform(7) + 2];
//    NSString *lastName = [self randomStringOfLength:arc4random_uniform(12) + 2];
//    user.fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
//    
//    return user;
//}
//
//- (Comment *)randomComment {
//    Comment *comment = [[Comment alloc] init];
//    
//    comment.from = [self randomUser];
//    comment.text = [self randomSentence];
//    
//    return comment;
//}
//
//- (NSString *)randomSentence {
//    NSUInteger wordCount = arc4random_uniform(10) + 2;
//    
//    NSMutableString *randomSentence = [[NSMutableString alloc] init];
//    
//    // Bloc checkpoint says i <= wordCount, but that will add one more
//    // word than wordCount..
//    for (int i = 0; i < wordCount; i++) {
//        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12) + 2];
//        [randomSentence appendFormat:@"%@ ", randomWord];
//    }
//    
//    return randomSentence;
//}
//
//- (NSString *)randomStringOfLength:(NSUInteger)len {
//    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
//    
//    // why this initializer?
//    NSMutableString *s = [NSMutableString string];
//    for (NSUInteger i = 0U; i < len; i++) {
//        u_int32_t r = arc4random_uniform((u_int32_t)[alphabet length]);
//        unichar c = [alphabet characterAtIndex:r];
//        [s appendFormat:@"%C", c];
//    }
//    
//    // what's the point of this?  we don't do it in the randomSentence method
//    // I understand it's for memory managment, but won't the NSMutableString s go away
//    // anyways after this method exits?
//    return [NSString stringWithString:s];
//}



@end
