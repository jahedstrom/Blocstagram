//
//  UserTests.m
//  Blocstagram
//
//  Created by Jonathan on 7/22/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "User.h"
#import "Media.h"
#import "ComposeCommentView.h"
#import "MediaTableViewCell.h"

@interface UserTests : XCTestCase

@end

@implementation UserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatInitializationWorks
{
    NSDictionary *sourceDictionary = @{@"id": @"8675309",
                                       @"username" : @"d'oh",
                                       @"full_name" : @"Homer Simpson",
                                       @"profile_picture" : @"http://www.example.com/example.jpg"};
    User *testUser = [[User alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testUser.idNumber, sourceDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testUser.userName, sourceDictionary[@"username"], @"The username should be equal");
    XCTAssertEqualObjects(testUser.fullName, sourceDictionary[@"full_name"], @"The full name should be equal");
    XCTAssertEqualObjects(testUser.profilePictureURL, [NSURL URLWithString:sourceDictionary[@"profile_picture"]], @"The profile picture should be equal");
}

- (void)testThatMediaInitializationWorks
{
       NSDictionary *mediaDictionary = @{
                                      @"attribution": @"<null>",
                                      @"caption":     @{
                                              @"created_time": @"1469199393",
                                              @"from":         @{
                                                      @"full_name": @"Biff",
                                                      @"id": @"184626549593",
                                                      @"profile_picture": @"https://www.example.com/example.jpg",
                                                      @"username": @"likesbeer",
                                                      },
                                              @"id": @"2974097079346732",
                                              @"text": @"Hello There!",
                                              },
                                      @"comments":     @{
                                              @"count": @"0",
                                              },
                                      @"created_time": @"1469199393",
                                      @"filter": @"Normal",
                                      @"id": @"1293874093470987340981273",
                                      @"images":     @{
                                              @"low_resolution":         @{
                                                      @"height": @"320",
                                                      @"url": @"https://www.example.com/1.jpg",
                                                      @"width": @"320",
                                                      },
                                              @"standard_resolution":         @{
                                                      @"height": @"640",
                                                      @"url": @"https://www.example.com/2.jpg",
                                                      @"width": @"640",
                                                      },
                                              @"thumbnail":         @{
                                                      @"height": @"150",
                                                      @"url": @"https://www.example.com/3.jpg",
                                                      @"width": @"150",
                                                      },
                                              },
                                      @"likes":     @{
                                              @"count": @"11",
                                              },
                                      @"link": @"https://www.instagram.com/",
                                      @"location": @"<null>",
                                      @"tags":     @[],
                                      @"type": @"image",
                                      @"user":     @{
                                              @"full_name": @"Duff",
                                              @"id": @"23784682362",
                                              @"profile_picture": @"https://www.example.com/5.jpg",
                                              @"username": @"likeswine",
                                              },
                                      @"user_has_liked": @"0",
                                      @"users_in_photo":     @[
                                              @{
                                                  @"position":             @{
                                                          @"x": @"0.3375",
                                                          @"y": @"0.5828125",
                                                          },
                                                  @"user":             @{
                                                          @"full_name": @"Barf",
                                                          @"id": @"867857653653",
                                                          @"profile_picture": @"https://www.example.com/4.jpg",
                                                          @"username": @"spaceballs",
                                                          },
                                                  }
                                              ],
                                      };
    
    
    Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
    
    
    XCTAssertEqualObjects(mediaItem.user.idNumber, mediaDictionary[@"user"][@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(mediaItem.user.userName, mediaDictionary[@"user"][@"username"], @"The username should be equal");
    XCTAssertEqualObjects(mediaItem.user.fullName, mediaDictionary[@"user"][@"full_name"], @"The full name should be equal");
    XCTAssertEqualObjects(mediaItem.user.profilePictureURL, [NSURL URLWithString:mediaDictionary[@"user"][@"profile_picture"]], @"The profile picture should be equal");

    
    XCTAssertEqualObjects(mediaItem.idNumber, mediaDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(mediaItem.caption, mediaDictionary[@"caption"][@"text"], @"The caption text should be equal");
    XCTAssertEqual(mediaItem.numberOfLikes, [mediaDictionary[@"likes"][@"count"] integerValue], @"The number of likes should be equal");
    XCTAssertEqualObjects(mediaItem.mediaURL, [NSURL URLWithString:mediaDictionary[@"images"][@"standard_resolution"][@"url"]], @"The profile picture should be equal");
}

- (void)testComposeCommentViewSetTextWorks
{
    
    ComposeCommentView *commentView = [[ComposeCommentView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    
    commentView.text = @"Some comment text";
    
    XCTAssertEqual(commentView.isWritingComment, YES, @"Comment view isWritingComment should be True");
    
    commentView.text = nil;
    
    XCTAssertEqual(commentView.isWritingComment, NO, @"Comment view isWritingComment should be False");
    
}

- (void)testHeightForMediaItemWorks
{
    NSDictionary *mediaDictionary = @{
                                      @"attribution": @"<null>",
                                      @"caption":     @{
                                              @"created_time": @"1469199393",
                                              @"from":         @{
                                                      @"full_name": @"Biff",
                                                      @"id": @"184626549593",
                                                      @"profile_picture": @"https://www.example.com/example.jpg",
                                                      @"username": @"likesbeer",
                                                      },
                                              @"id": @"2974097079346732",
                                              @"text": @"Hello There!",
                                              },
                                      @"comments":     @{
                                              @"count": @"0",
                                              },
                                      @"created_time": @"1469199393",
                                      @"filter": @"Normal",
                                      @"id": @"1293874093470987340981273",
                                      @"images":     @{
                                              @"low_resolution":         @{
                                                      @"height": @"320",
                                                      @"url": @"https://www.example.com/1.jpg",
                                                      @"width": @"320",
                                                      },
                                              @"standard_resolution":         @{
                                                      @"height": @"640",
                                                      @"url": @"https://www.example.com/2.jpg",
                                                      @"width": @"640",
                                                      },
                                              @"thumbnail":         @{
                                                      @"height": @"150",
                                                      @"url": @"https://www.example.com/3.jpg",
                                                      @"width": @"150",
                                                      },
                                              },
                                      @"likes":     @{
                                              @"count": @"11",
                                              },
                                      @"link": @"https://www.instagram.com/",
                                      @"location": @"<null>",
                                      @"tags":     @[],
                                      @"type": @"image",
                                      @"user":     @{
                                              @"full_name": @"Duff",
                                              @"id": @"23784682362",
                                              @"profile_picture": @"https://www.example.com/5.jpg",
                                              @"username": @"likeswine",
                                              },
                                      @"user_has_liked": @"0",
                                      @"users_in_photo":     @[
                                              @{
                                                  @"position":             @{
                                                          @"x": @"0.3375",
                                                          @"y": @"0.5828125",
                                                          },
                                                  @"user":             @{
                                                          @"full_name": @"Barf",
                                                          @"id": @"867857653653",
                                                          @"profile_picture": @"https://www.example.com/4.jpg",
                                                          @"username": @"spaceballs",
                                                          },
                                                  }
                                              ],
                                      };
    
    
    Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:@"1" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    mediaItem.image = image;
    UITraitCollection *traitCollection = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact]; // classcompact will make the image height equal to it's width
    CGFloat imageHeight = [MediaTableViewCell heightForMediaItem:mediaItem width:320 traitCollection:traitCollection];
    CGFloat actualImageHeight = 320 + 138;      // 138 is the height of the user name and caption label plus the comment label
    XCTAssertEqual(imageHeight, actualImageHeight, @"The image height should be equal");
   
    imageHeight = [MediaTableViewCell heightForMediaItem:mediaItem width:480 traitCollection:traitCollection];
    actualImageHeight = 480 + 138;
    XCTAssertEqual(imageHeight, actualImageHeight, @"The image height should be equal");
    
    imageHeight = [MediaTableViewCell heightForMediaItem:mediaItem width:600 traitCollection:traitCollection];
    actualImageHeight = 600 + 138;
    XCTAssertEqual(imageHeight, actualImageHeight, @"The image height should be equal");
}

@end
