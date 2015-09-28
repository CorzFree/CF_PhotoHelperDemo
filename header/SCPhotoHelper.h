//
//  SCPhotoHelper.h
//  header
//
//  Created by crw on 15/8/17.
//  Copyright (c) 2015年 移动事业部. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^SCPhotoHelperHeadComplete)(UIImage *headImage);
typedef void(^SCPhotoHelperComplete)(NSArray *assets);

@interface SCPhotoHelper : NSObject<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

+ (SCPhotoHelper *)sharedInstance;

- (void)chooseHeadPicture:(SCPhotoHelperHeadComplete) headCompleteBlock;
- (void)choosePicture:(SCPhotoHelperComplete)         completeBlock;
@property (nonatomic, assign)   NSInteger                  maxCount;
@property (nonatomic, copy)     SCPhotoHelperHeadComplete  headCompleteBlock;
@property (nonatomic, copy)     SCPhotoHelperComplete      completeBlock;
@end
