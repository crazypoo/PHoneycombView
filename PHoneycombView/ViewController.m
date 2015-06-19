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

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,PHoneycombLayoutDataSource,PHoneycombLayoutDelegateFlowLayout>
{
    UICollectionView *myC;
    NSMutableArray *titleArr;
    UIButton *rBtn;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    titleArr = [[NSMutableArray array] init];
    for (NSInteger i = 1; i <= 100; i++) {
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
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return titleArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHoneycombCell *cell = nil;
    if (cell == nil) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    }
    else
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    cell.titleLabel.text = [NSString stringWithFormat:@"%@",titleArr[indexPath.row]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"it>>>>%@",titleArr[indexPath.row]);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    PHoneycombCell *cell = titleArr[fromIndexPath.item];
    
    [titleArr removeObjectAtIndex:fromIndexPath.item];
    [titleArr insertObject:cell atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    
    return YES;
}

-(void)addAct:(UIButton *)sender
{
    [titleArr insertObject:[NSString stringWithFormat:@"%d",(arc4random() %1000)] atIndex:titleArr.count];
    [myC reloadData];
}

-(void)killAct:(UIButton *)sender
{
#warning 暂时只能随机一个个删除
    if (!titleArr.count) {
        return;
    }
    NSArray *visibleIndexPaths = [myC indexPathsForVisibleItems];
    NSArray *sortedIndexPaths = [visibleIndexPaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSIndexPath *path1 = (NSIndexPath *)obj1;
        NSIndexPath *path2 = (NSIndexPath *)obj2;
        return [path1 compare:path2];
    }];
    NSIndexPath *toRemove = [visibleIndexPaths objectAtIndex:(arc4random() % sortedIndexPaths.count)];
    
    [self removeIndexPath:toRemove];
}

- (void)removeIndexPath:(NSIndexPath *)indexPath {
    if(!titleArr.count || indexPath.row > titleArr.count)
    {
        return;
    }
    
    [myC performBatchUpdates:^{
        NSInteger index = indexPath.row;
        [titleArr removeObjectAtIndex:index];
        [myC deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    } completion:^(BOOL done) {
        [myC reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
