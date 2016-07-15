//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Jonathan on 7/14/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

- (instancetype)initWithMedia:(Media *)media;

- (void)centerScrollView;

@end
