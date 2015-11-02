＃图片选择器


将使用的图片选择封装了一下，还有许多不足

----------

头像选择
----

    [[SCPhotoHelper sharedInstance] chooseHeadPicture:^(id headImage) {
        [self.assets addObject:headImage];
        [self.tableView reloadData];
    }];

普通选择
----

    [[SCPhotoHelper sharedInstance] choosePicture:^(NSArray *assets) {
        [self.assets addObjectsFromArray:assets];
        [self.tableView reloadData];
    }];

图片浏览
----

    MLSelectPhotoBrowserViewController *browserVc = [[MLSelectPhotoBrowserViewController alloc] init];
    browserVc.currentPage = indexPath.row;
    [browserVc setValue:@(YES) forKeyPath:@"isTrashing"];
    browserVc.photos = self.assets;
    browserVc.deleteCallBack = ^(NSArray *assets){
        self.assets = [NSMutableArray arrayWithArray:assets];
        [self.tableView reloadData];
    };

    [self.navigationController pushViewController:browserVc animated:YES];
