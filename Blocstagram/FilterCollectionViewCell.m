//
//  FilterCollectionViewCell.m
//  Blocstagram
//
//  Created by Jonathan on 7/19/16.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "FilterCollectionViewCell.h"

@interface FilterCollectionViewCell ()

@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *label;

@end

@implementation FilterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat thumbnailEdgeSize = CGRectGetWidth(frame);
        
        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
        
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnail.clipsToBounds = YES;
        
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        
        
        
        [self.contentView addSubview:self.thumbnail];
        [self.contentView addSubview:self.label];
        
    
        
    }
    return self;
}

// Override setters to set Image and text properties of the UIImageView and UILabel
- (void)setFilterImage:(UIImage *)filterImage {
    _filterImage = filterImage;
    self.thumbnail.image = filterImage;
}

- (void)setFilterTitle:(NSString *)filterTitle {
    _filterTitle = filterTitle;
    self.label.text = filterTitle;
}

@end


