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
        
        CGFloat thumbnailEdgeSize = CGRectGetHeight(frame);
        
        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
        
      
        
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        self.thumbnail.clipsToBounds = YES;
        
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        
        
        
        [self.contentView addSubview:self.thumbnail];
        [self.contentView addSubview:self.label];
        
    
        
    }
    return self;
}

- (void)layoutSubviews {
    NSLog(@"in layoutSubviews");
    
    CGFloat edgeSize = CGRectGetWidth(self.contentView.frame);
    
    self.thumbnail.frame = CGRectMake(0, 0, edgeSize, edgeSize);
    self.label.frame = CGRectMake(0, edgeSize, edgeSize, 20);
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


//
//static NSInteger imageViewTag = 1000;
//static NSInteger labelTag = 1001;
//
//UIImageView *thumbnail = (UIImageView *)[cell.contentView viewWithTag:imageViewTag];
//UILabel *label = (UILabel *)[cell.contentView viewWithTag:labelTag];
//
//UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.filterCollectionView.collectionViewLayout;
//CGFloat thumbnailEdgeSize = flowLayout.itemSize.width;
//
//if (!thumbnail) {
//    thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
//    thumbnail.contentMode = UIViewContentModeScaleAspectFill;
//    thumbnail.tag = imageViewTag;
//    thumbnail.clipsToBounds = YES;
//    
//    [cell.contentView addSubview:thumbnail];
//}
//
//if (!label) {
//    label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
//    label.tag = labelTag;
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
//    [cell.contentView addSubview:label];
//}


@end


