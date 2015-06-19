//
//  PHoneycombCell.h
//  
//
//  Created by crazypoo on 15/6/19.
//
//

#import <UIKit/UIKit.h>

@class PHoneycombCell;

@protocol PHoneycombCellDelegate <NSObject>
@optional
- (void)modelCellEvent:(PHoneycombCell *)cell;
@end

@interface PHoneycombCell : UICollectionViewCell
{
    UIButton *deleteBtn;
}
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, weak) id<PHoneycombCellDelegate>delegate;
-(void)hideDeleteBtn;
-(void)showDeleteBtn;
@end
