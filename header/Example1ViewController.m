//
//  Example1ViewController.m
//  header
//
//  Created by crw on 15/8/17.
//  Copyright (c) 2015年 移动事业部. All rights reserved.
//

#import "Example1ViewController.h"
#import "MLSelectPhotoAssets.h"
#import "MLSelectPhotoPickerAssetsViewController.h"
#import "MLSelectPhotoBrowserViewController.h"
#import "SCPhotoHelper.h"

@interface Example1ViewController () <UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak,nonatomic) UITableView *tableView;
@property (weak,nonatomic) UICollectionView *collectionView;
@property (nonatomic , strong) NSMutableArray *assets;

@end

@implementation Example1ViewController

#pragma mark - Getter
#pragma mark Get data
- (NSMutableArray *)assets{
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}

#pragma mark Get View
- (UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.tableFooterView = [[UIView alloc] init];
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    return _tableView;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLabyout = [[UICollectionViewFlowLayout alloc] init];
        flowLabyout.itemSize = CGSizeMake(50, 50);
        flowLabyout.minimumLineSpacing = 5;
        flowLabyout.minimumInteritemSpacing = 5;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLabyout];
        collectionView.bounces = NO;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"NewShowCell"];
        //_mCollectionView.scrollEnabled = NO;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 初始化UI
    [self setupButtons];
    [self tableView];
    //[self collectionView];
}

- (void) setupButtons{
    self.title = @"图片选择";
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"selectHeadPhotos" style:UIBarButtonItemStyleDone target:self action:@selector(selectHeadPhoto)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"selectPhotos" style:UIBarButtonItemStyleDone target:self action:@selector(selectPhotos)];
}

#pragma mark - 头像选择
- (void)selectHeadPhoto{
    __weak typeof (self) weakSelf = self;
    [[SCPhotoHelper sharedInstance] chooseHeadPicture:^(id headImage) {
        [weakSelf.assets addObject:headImage];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - 选择相册
- (void)selectPhotos {
    __weak typeof (self) weakSelf = self;
    [[SCPhotoHelper sharedInstance] choosePicture:^(NSArray *assets) {
        [weakSelf.assets addObjectsFromArray:assets];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.assets.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    // 判断类型来获取Image
    MLSelectPhotoAssets *asset = self.assets[indexPath.row];
    cell.imageView.image = [MLSelectPhotoPickerViewController getImageWithImageObj:asset];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MLSelectPhotoBrowserViewController *browserVc = [[MLSelectPhotoBrowserViewController alloc] init];
    browserVc.currentPage = indexPath.row;
    [browserVc setValue:@(YES) forKeyPath:@"isTrashing"];
    browserVc.photos = self.assets;
    __weak typeof (self) weakSelf = self;
    browserVc.deleteCallBack = ^(NSArray *assets){
        weakSelf.assets = [NSMutableArray arrayWithArray:assets];
        [weakSelf.tableView reloadData];
    };

    [self.navigationController pushViewController:browserVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"NewShowCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    MLSelectPhotoAssets *asset = self.assets[indexPath.row];
    [cell.contentView setBackgroundColor:[UIColor greenColor]];
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(50,50);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MLSelectPhotoBrowserViewController *browserVc = [[MLSelectPhotoBrowserViewController alloc] init];
    browserVc.currentPage = indexPath.row;
    [browserVc setValue:@(YES) forKeyPath:@"isTrashing"];
    browserVc.photos = self.assets;
    __weak typeof (self) weakSelf = self;
    browserVc.deleteCallBack = ^(NSArray *assets){
        weakSelf.assets = [NSMutableArray arrayWithArray:assets];
        [weakSelf.collectionView reloadData];
    };
    
    [self.navigationController pushViewController:browserVc animated:YES];
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
@end
