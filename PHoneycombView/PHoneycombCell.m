//
//  PHoneycombCell.m
//  
//
//  Created by crazypoo on 15/6/19.
//
//

#import "PHoneycombCell.h"

@implementation PHoneycombCell

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLabel];
        
        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.backgroundColor = [UIColor redColor];
        [deleteBtn addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.hidden = YES;
        [self.contentView addSubview:deleteBtn];
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
#warning 还有bug,未能根据item大小来变化
    //// Polygon Drawing
    UIBezierPath* polygonPath = UIBezierPath.bezierPath;
    [polygonPath moveToPoint: CGPointMake(CGRectGetMinX(rect) + 50, CGRectGetMaxY(rect) + 0.9)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 93.3, CGRectGetMaxY(rect) - 20.85)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 93.3, CGRectGetMaxY(rect) - 64.35)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 50, CGRectGetMaxY(rect) - 86.1)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 6.7, CGRectGetMaxY(rect) - 64.35)];
    [polygonPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 6.7, CGRectGetMaxY(rect) - 20.85)];
    [polygonPath closePath];
    [UIColor.orangeColor setFill];
    [polygonPath fill];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [polygonPath CGPath];
    
    self.layer.mask = maskLayer;
    self.titleLabel.frame = self.contentView.frame;
    deleteBtn.frame = CGRectMake((self.contentView.frame.size.width-20)/2, 5, 20, 20);

}

#pragma mark -Delegate
- (void)buttonEvent:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(modelCellEvent:)]) {
        [_delegate modelCellEvent:self];
    }
}

#pragma mark -AboutDeleteButton
-(void)hideDeleteBtn
{
    deleteBtn.hidden = YES;
    
    [self.layer removeAnimationForKey:@"shakeAnimation"];
}

-(void)showDeleteBtn
{
    deleteBtn.hidden = NO;
    
    CGFloat rotation = 0.03;
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
    shake.duration = 0.13;
    shake.autoreverses = YES;
    shake.repeatCount  = MAXFLOAT;
    shake.removedOnCompletion = NO;
    shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform,-rotation, 0.0 ,0.0 ,10.0)];
    shake.toValue   = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, rotation, 0.0 ,0.0 ,10.0)];
    [self.layer addAnimation:shake forKey:@"shakeAnimation"];

}
@end
