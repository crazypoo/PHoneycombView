//
//  ViewController.m
//  PHoneycombView
//
//  Created by crazypoo on 15/6/19.
//  Copyright (c) 2015年 P. All rights reserved.
//

#import "ViewController.h"

#import "PHoneycombCell.h"
#import "PHoneycombLayout.h"

static NSString * const reuseIdentifier = @"Cell";

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,PHoneycombLayoutDataSource,PHoneycombLayoutDelegateFlowLayout,PHoneycombCellDelegate>
{
    UICollectionView *myC;
    NSMutableArray *titleArr;
    UIButton *rBtn;
    PHoneycombCell *myCell;
    BOOL status;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    titleArr = [[NSMutableArray array] init];
    for (NSInteger i = 1; i <= 20; i++) {
        NSString *name = [NSString stringWithFormat:@"%ld",i];
        [titleArr addObject:name];
    }
    
    UIButton *lBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    lBtn.frame = CGRectMake(0, 0, 30, 30);
    [lBtn addTarget:self action:@selector(addAct:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:lBtn];
    
    rBtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    rBtn.frame = CGRectMake(0, 0, 30, 30);
    rBtn.selected = NO;
    [rBtn addTarget:self action:@selector(killAct:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rBtn];
    
    PHoneycombLayout *layout = [[PHoneycombLayout alloc] init];
    
    myC = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    myC.backgroundColor = [UIColor whiteColor];
    myC.dataSource = self;
    myC.delegate = self;
    myC.showsHorizontalScrollIndicator = YES;
    myC.showsVerticalScrollIndicator = YES;
    myC.pagingEnabled = NO;
    myC.scrollEnabled = YES;
    [myC registerClass:[PHoneycombCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.view addSubview:myC];
    status = NO;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return titleArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    myCell = nil;
    if (myCell == nil) {
        myCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    }
    else
    {
        while ([myCell.contentView.subviews lastObject] != nil) {
            [(UIView *)[myCell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    myCell.delegate = self;
    if (status) {
        [myCell showDeleteBtn];
    }
    else
    {
        [myCell hideDeleteBtn];
    }
    myCell.titleLabel.text = [NSString stringWithFormat:@"%@",titleArr[indexPath.row]];
    return myCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"it>>>>%@",titleArr[indexPath.row]);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    myCell = titleArr[fromIndexPath.item];
    [titleArr removeObjectAtIndex:fromIndexPath.item];
    [titleArr insertObject:myCell atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    
    return YES;
}

-(void)modelCellEvent:(PHoneycombCell *)cell {
    NSIndexPath *indexPath = [myC indexPathForCell:cell];
    [myC performBatchUpdates:^{
        NSInteger index = indexPath.row;
        [titleArr removeObjectAtIndex:index];
        [myC deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    } completion:^(BOOL done) {
        [myC reloadData];
        [myC scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        
    }];
}

-(void)addAct:(UIButton *)sender
{
    [titleArr insertObject:[NSString stringWithFormat:@"%d",(arc4random() %1000)] atIndex:titleArr.count];
    [myC reloadData];
    [myC scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:titleArr.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

-(void)killAct:(UIButton *)sender
{
    if (sender.isSelected) {
        rBtn.selected = NO;
        status = NO;
    }
    else
    {
        rBtn.selected = YES;
        status = YES;
    }
    [myC reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
