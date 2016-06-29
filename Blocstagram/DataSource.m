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

@interface DataSource ()

@property (nonatomic, strong) NSArray *mediaItems;

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
        [self addRandomData];
    }
    
    return self;
}

- (void)addRandomData {
    NSMutableArray *randomMediaItems = [NSMutableArray array];
    
    for (int i = 1; i <= 10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg" ,i];
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (image) {
            Media *media = [[Media alloc] init];
            media.user = [self randomUser];
            media.image = image;
            media.caption = [self randomSentence];
            
            NSUInteger commentCount = arc4random_uniform(10) + 2;
            NSMutableArray *randomComments = [NSMutableArray array];
            
            // Bloc checkpoint says i <= commentCount, but that will add one more
            // comment than commentCount..
            for (int j = 0; j < commentCount; j++) {
                Comment *randomComment = [self randomComment];
                [randomComments addObject:randomComment];
            }
            
            media.comments = randomComments;
            
            [randomMediaItems addObject:media];
        }
    }
    
    self.mediaItems = randomMediaItems;
    
}

- (void)removeItemFromDataSource:(NSUInteger)index {
    NSMutableArray *tempMediaItems = [NSMutableArray arrayWithArray:self.mediaItems];
    
    if (index < tempMediaItems.count) {
        [tempMediaItems removeObjectAtIndex:index];
    }
    
    self.mediaItems = tempMediaItems;
}

#pragma mark - Helper Functions


- (User *)randomUser {
    User *user = [[User alloc] init];
    
    user.userName = [self randomStringOfLength:arc4random_uniform(10) + 2];
    
    NSString *firstName = [self randomStringOfLength:arc4random_uniform(7) + 2];
    NSString *lastName = [self randomStringOfLength:arc4random_uniform(12) + 2];
    user.fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    return user;
}

- (Comment *)randomComment {
    Comment *comment = [[Comment alloc] init];
    
    comment.from = [self randomUser];
    comment.text = [self randomSentence];
    
    return comment;
}

- (NSString *)randomSentence {
    NSUInteger wordCount = arc4random_uniform(10) + 2;
    
    NSMutableString *randomSentence = [[NSMutableString alloc] init];
    
    // Bloc checkpoint says i <= wordCount, but that will add one more
    // word than wordCount..
    for (int i = 0; i < wordCount; i++) {
        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12) + 2];
        [randomSentence appendFormat:@"%@ ", randomWord];
    }
    
    return randomSentence;
}

- (NSString *)randomStringOfLength:(NSUInteger)len {
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    
    // why this initializer?
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random_uniform((u_int32_t)[alphabet length]);
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    // what's the point of this?  we don't do it in the randomSentence method
    // I understand it's for memory managment, but won't the NSMutableString s go away
    // anyways after this method exits?
    return [NSString stringWithString:s];
}



@end
