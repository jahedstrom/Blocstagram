//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Jonathan on 6/29/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MediaTableViewCell;

@protocol MediaTableViewCellDelegate <NSObject>

- (void)cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void)cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;
- (void)cell:(MediaTableViewCell *)cell didTwoFingerTapImageView:(UIImageView *)imageView;


@end

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaItem;
@property (nonatomic, weak) id <MediaTableViewCellDelegate> delegate;

+ (CGFloat)heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
