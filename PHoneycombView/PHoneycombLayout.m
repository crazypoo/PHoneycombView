//
//  PHoneycombLayout.m
//  
//
//  Created by crazypoo on 15/6/19.
//
//

#import "PHoneycombLayout.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static NSString * const kPScrollingDirectionKey = @"PScrollingDirection";
static NSString * const kPCollectionViewKeyPath = @"collectionView";

#ifndef CGGEOMETRY_PSUPPORT_H_
CG_INLINE CGPoint
P_CGPointAdd(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}
#endif

@implementation CADisplayLink (P_userInfo)
-(void)setP_userInfo:(NSDictionary *) P_userInfo
{
    objc_setAssociatedObject(self, "P_userInfo", P_userInfo, OBJC_ASSOCIATION_COPY);
}

-(NSDictionary *)P_userInfo
{
    return objc_getAssociatedObject(self, "P_userInfo");
}
@end

@implementation UICollectionViewCell (PLayout)

-(UIView *)P_snapshotView
{
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        return [self snapshotViewAfterScreenUpdates:YES];
    }
    else
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0f);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return [[UIImageView alloc] initWithImage:image];
    }
}

@end

@implementation PHoneycombLayout

#pragma mark -初始化
-(id)init
{
    self = [super init];
    if (self)
    {
        [self addObserver:self forKeyPath:kPCollectionViewKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)dealloc
{
    [self invalidatesScrollTimer];
    [self removeObserver:self forKeyPath:kPCollectionViewKeyPath];
}

-(id<PHoneycombLayoutDataSource>)dataSource
{
    return (id<PHoneycombLayoutDataSource>)self.collectionView.dataSource;
}

- (id<PHoneycombLayoutDelegateFlowLayout>)delegate
{
    return (id<PHoneycombLayoutDelegateFlowLayout>)self.collectionView.delegate;
}

-(void)invalidateLayoutIfNecessary
{
    NSIndexPath *newIndexPath = [self.collectionView indexPathForItemAtPoint:self.currentView.center];
    NSIndexPath *previousIndexPath = self.selectedItemIndexPath;
    
    if ((newIndexPath == nil) || [newIndexPath isEqual:previousIndexPath])
    {
        return;
    }
    
    if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:canMoveToIndexPath:)] &&
        ![self.dataSource collectionView:self.collectionView itemAtIndexPath:previousIndexPath canMoveToIndexPath:newIndexPath])
    {
        return;
    }
    
    self.selectedItemIndexPath = newIndexPath;
    
    if ([self.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:willMoveToIndexPath:)])
    {
        [self.dataSource collectionView:self.collectionView itemAtIndexPath:previousIndexPath willMoveToIndexPath:newIndexPath];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf.collectionView deleteItemsAtIndexPaths:@[previousIndexPath]];
            [strongSelf.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
        }
    } completion:^(BOOL finished){
        __strong typeof(self) strongSelf = weakSelf;
        if ([strongSelf.dataSource respondsToSelector:@selector(collectionView:itemAtIndexPath:didMoveToIndexPath:)])
        {
            [strongSelf.dataSource collectionView:strongSelf.collectionView itemAtIndexPath:previousIndexPath didMoveToIndexPath:newIndexPath];
        }
    }];
}

-(void)invalidatesScrollTimer
{
    if (!self.displayLink.paused)
    {
        [self.displayLink invalidate];
    }
    self.displayLink = nil;
}

-(void)setUpCollectionViewGesture
{
    if (!_setUped)
    {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _longPressGesture.delegate = self;
        _panGesture.delegate = self;
        for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers)
        {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
            {
                [gestureRecognizer requireGestureRecognizerToFail:_longPressGesture];
            }
        }
        [self.collectionView addGestureRecognizer:_longPressGesture];
        [self.collectionView addGestureRecognizer:_panGesture];
        _setUped = YES;
    }
}

#pragma mark -整个View高度控制来断定是否可滑动
-(CGSize)collectionViewContentSize
{
    float height = (SIZE + self.margin) * ([self.collectionView numberOfItemsInSection:0] / 2);
    return CGSizeMake(screenWidth, height);
}

#pragma mark -布局
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    UICollectionView *collection = self.collectionView;
    itemY = SIZE/2+SIZE/5;
    if (indexPath.item %5 == 0)
    {
        float x = (screenWidth-SIZE)/2;
//        float y = 70;
        attributes.center = CGPointMake(x+collection.contentOffset.x, (indexPath.item+5)/5*itemY+indexPath.item/5*SIZE);
        attributes.size = CGSizeMake(SIZE, SIZE * cos(M_PI * 30.0f / 180.0f));
    }
    else if (indexPath.item %5 == 1)
    {
        float x = (screenWidth-SIZE)/2;
//        float y = 70;
        x = x+SIZE;
        attributes.center = CGPointMake(x + collection.contentOffset.x, (indexPath.item+5)/5*itemY+indexPath.item/5*SIZE);
        attributes.size = CGSizeMake(SIZE, SIZE * cos(M_PI * 30.0f / 180.0f));
    }
    else if (indexPath.item %5 == 2)
    {
        float y = itemY+SIZE * cos(M_PI * 30.0f / 180.0f);
        attributes.center = CGPointMake((screenWidth-SIZE*3)/2+SIZE/2, (indexPath.item+5)/5*y+indexPath.item/5*+(SIZE-SIZE * cos(M_PI * 30.0f / 180.0f)));
        attributes.size = CGSizeMake(SIZE, SIZE * cos(M_PI * 30.0f / 180.0f));
    }
    else if (indexPath.item %5 == 3)
    {
//        float y = 155;
        float y = itemY+SIZE * cos(M_PI * 30.0f / 180.0f);
        attributes.center = CGPointMake((screenWidth-SIZE*3)/2+SIZE*1.5, (indexPath.item+5)/5*y+indexPath.item/5*+(SIZE-SIZE * cos(M_PI * 30.0f / 180.0f)));
        attributes.size = CGSizeMake(SIZE, SIZE * cos(M_PI * 30.0f / 180.0f));
    }
    else if (indexPath.item %5 == 4)
    {
        float y = itemY+SIZE * cos(M_PI * 30.0f / 180.0f);
        attributes.center = CGPointMake((screenWidth-SIZE*3)/2+SIZE*2.5, (indexPath.item+5)/5*y+indexPath.item/5*+(SIZE-SIZE * cos(M_PI * 30.0f / 180.0f)));
        attributes.size = CGSizeMake(SIZE, SIZE * cos(M_PI * 30.0f / 180.0f));
    }
    NSLog(@"%f",SIZE * cos(M_PI * 30.0f / 180.0f));
    return attributes;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *arr = [super layoutAttributesForElementsInRect:rect];
    if ([arr count] > 0)
    {
        return arr;
    }
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger i = 0 ; i < [self.collectionView numberOfItemsInSection:0 ]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

#pragma mark -触摸事件
-(void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            //indexPath
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
            //can move
            if ([self.dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)])
            {
                if (![self.dataSource collectionView:self.collectionView canMoveItemAtIndexPath:indexPath])
                {
                    return;
                }
            }
            //will begin dragging
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)])
            {
                [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:indexPath];
            }
            
            self.selectedItemIndexPath = indexPath;
            
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)])
            {
                [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:self.selectedItemIndexPath];
            }
            
            UICollectionViewCell *collectionViewCell = [self.collectionView cellForItemAtIndexPath:self.selectedItemIndexPath];
            
            self.currentView = [[UIView alloc] initWithFrame:collectionViewCell.frame];
            
            collectionViewCell.highlighted = YES;
            UIView *highlightedImageView = [collectionViewCell P_snapshotView];
            highlightedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            highlightedImageView.alpha = 1.0f;
            
            collectionViewCell.highlighted = NO;
            UIView *imageView = [collectionViewCell P_snapshotView];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView.alpha = 0.0f;
            
            [self.currentView addSubview:imageView];
            [self.currentView addSubview:highlightedImageView];
            [self.collectionView addSubview:self.currentView];
            
            self.currentViewCenter = self.currentView.center;
            
            __weak typeof(self) weakSelf = self;
            [UIView
             animateWithDuration:0.3
             delay:0.0
             options:UIViewAnimationOptionBeginFromCurrentState
             animations:^{
                 __strong typeof(self) strongSelf = weakSelf;
                 if (strongSelf)
                 {
                     strongSelf.currentView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                     highlightedImageView.alpha = 0.0f;
                     imageView.alpha = 1.0f;
                 }
             }
             completion:^(BOOL finished) {
                 __strong typeof(self) strongSelf = weakSelf;
                 if (strongSelf)
                 {
                     [highlightedImageView removeFromSuperview];
                     
                     if ([strongSelf.delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAtIndexPath:)])
                     {
                         [strongSelf.delegate collectionView:strongSelf.collectionView layout:strongSelf didBeginDraggingItemAtIndexPath:strongSelf.selectedItemIndexPath];
                     }
                 }
             }];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            NSIndexPath *currentIndexPath = self.selectedItemIndexPath;
            
            if (currentIndexPath)
            {
                if ([self.delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemAtIndexPath:)])
                {
                    [self.delegate collectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:currentIndexPath];
                }
                self.selectedItemIndexPath = nil;
                self.currentViewCenter = CGPointZero;
                UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:currentIndexPath];
                self.longPressGesture.enabled = NO;
                __weak typeof(self) weakSelf = self;
                [UIView
                 animateWithDuration:0.3
                 delay:0.0
                 options:UIViewAnimationOptionBeginFromCurrentState
                 animations:^{
                     __strong typeof(self) strongSelf = weakSelf;
                     if (strongSelf)
                     {
                         strongSelf.currentView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         strongSelf.currentView.center = layoutAttributes.center;
                     }
                 }
                 completion:^(BOOL finished) {
                     
                     self.longPressGesture.enabled = YES;
                     
                     __strong typeof(self) strongSelf = weakSelf;
                     if (strongSelf)
                     {
                         [strongSelf.currentView removeFromSuperview];
                         strongSelf.currentView = nil;
                         [strongSelf invalidateLayout];
                         
                         if ([strongSelf.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:)])
                         {
                             [strongSelf.delegate collectionView:strongSelf.collectionView layout:strongSelf didEndDraggingItemAtIndexPath:currentIndexPath];
                         }
                     }
                 }];
            }
            break;
        }
        default:
            break;
    }
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    switch (pan.state)
    {
        case UIGestureRecognizerStateChanged:
        {
            self.panTranslationInCollectionView = [pan translationInView:self.collectionView];
            self.currentView.center = P_CGPointAdd(self.currentViewCenter, self.panTranslationInCollectionView);
            
            [self invalidateLayoutIfNecessary];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self invalidatesScrollTimer];
            break;
            
        default:
            break;
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.panGesture isEqual:gestureRecognizer]) {
        return (self.selectedItemIndexPath != nil);
    }
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self.longPressGesture isEqual:gestureRecognizer])
    {
        return [self.panGesture isEqual:otherGestureRecognizer];
    }
    
    if ([self.panGesture isEqual:gestureRecognizer])
    {
        return [self.longPressGesture isEqual:otherGestureRecognizer];
    }
    
    return NO;
}

#pragma mark -KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kPCollectionViewKeyPath])
    {
        if (self.collectionView != nil)
        {
            [self setUpCollectionViewGesture];
        }
        else
        {
            [self invalidatesScrollTimer];
        }
    }
}

#pragma mark -通知
-(void)handleApplicationWillResignActive:(NSNotification *)notification
{
    self.panGesture.enabled = NO;
    self.panGesture.enabled = YES;
}

@end

