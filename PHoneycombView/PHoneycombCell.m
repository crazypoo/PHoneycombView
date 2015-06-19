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
        self.titleLabel = [[UILabel alloc] initWithFrame:frame];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLabel];
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
}

@end
