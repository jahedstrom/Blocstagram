//
//  Comment.h
//  Blocstagram
//
//  Created by Jonathan on 6/26/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Comment : NSObject <NSCoding>

- (instancetype)initWithDictionary:(NSDictionary *)commentDictionary;

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) User *from;
@property (nonatomic, strong) NSString *text;

@end
