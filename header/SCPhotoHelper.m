//
//  SCPhotoHelper.m
//  header
//
//  Created by crw on 15/8/17.
//  Copyright (c) 2015年 移动事业部. All rights reserved.
//

#import "SCPhotoHelper.h"
#import "ALActionSheetView.h"
#import "MLSelectPhotoAssets.h"
#import "MLSelectPhotoPickerAssetsViewController.h"
#import "MLSelectPhotoBrowserViewController.h"
#define AppRootViewController  ([[[[UIApplication sharedApplication] delegate] window] rootViewController])
typedef enum{
    SCPhotoHelperTypeHead,
    SCPhotoHelperTypeMultiselect
}SCPhotoHelperType;

@interface SCPhotoHelper(){
    NSUInteger                sourceType;
    NSUInteger                _helpType;
}
@property (nonatomic, strong) ALActionSheetView *sheet;
@property (nonatomic ,strong) NSMutableArray    *assets;
@end

@implementation SCPhotoHelper

- (NSMutableArray *)assets{
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}

+(SCPhotoHelper *)sharedInstance{
    static SCPhotoHelper   *helper = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        helper = [[self alloc] init];
    });
    return helper;
}

- (void)chooseHeadPicture:(SCPhotoHelperHeadComplete)headCompleteBlock{
    if (self.assets) {
        [self.assets removeAllObjects];
    }
    _headCompleteBlock = headCompleteBlock;
    _helpType          = SCPhotoHelperTypeHead;
    [self.sheet show];
}

- (void)choosePicture:(SCPhotoHelperComplete)completeBlock{
    if (self.assets) {
        [self.assets removeAllObjects];
    }
    _completeBlock     = completeBlock;
    _helpType          = SCPhotoHelperTypeMultiselect;
    [self.sheet show];
}

- (ALActionSheetView *)sheet{
    __weak __typeof(self) weakSelf = self;
    if (!_sheet) {
        _sheet = [ALActionSheetView showActionSheetWithTitle:@"选择图片" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"拍照",@"从手机相册选择"] handler:^(ALActionSheetView *actionSheetView, NSInteger buttonIndex) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf chooseImageWithIndex:buttonIndex];
        }];
    }
    return _sheet;
}

- (void)chooseImageWithIndex:(NSInteger)buttonIndex{
    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    switch (buttonIndex) {
        case 0: //相机
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1: //相册
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 2:
            break;
    }
    // 判断是否支持相机
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && sourceType == UIImagePickerControllerSourceTypeCamera) {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
        return;
    }
    
    if (_helpType == SCPhotoHelperTypeHead || (sourceType == UIImagePickerControllerSourceTypeCamera)) {
        // 跳转到相机或相册页面
        UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = sourceType;
        if (sourceType == UIImagePickerControllerSourceTypeCamera && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = _helpType == SCPhotoHelperTypeHead;
        UIViewController *vc = AppRootViewController;
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            //解决Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.
            vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [vc presentViewController:imagePickerController animated:YES completion:nil];
    }else{
        if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            // 创建控制器
            MLSelectPhotoPickerViewController *pickerVc = [[MLSelectPhotoPickerViewController alloc] init];
            // 默认显示相册里面的内容SavePhotos
            pickerVc.status = PickerViewShowStatusCameraRoll;
            pickerVc.minCount = _maxCount == 0 ?9:_maxCount;
            [pickerVc showPickerVc:AppRootViewController];
            __weak typeof(self) weakSelf = self;
            pickerVc.callBack = ^(NSArray *assets){
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.assets addObjectsFromArray:assets];
                if (strongSelf.completeBlock) {
                    strongSelf.completeBlock(strongSelf.assets);
                }
            };
        }
    }
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]){
        if (_helpType == SCPhotoHelperTypeHead) {//选择头像
            if (_headCompleteBlock) {
                UIImage* image = [self fixOrientation:[info objectForKey:UIImagePickerControllerEditedImage]];
                NSData *data = UIImageJPEGRepresentation(image, 0.6);
                _headCompleteBlock([UIImage imageWithData:data]);
            }
        }else{
            if (_completeBlock) {
                UIImage* image = [self fixOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];
                NSData *data = UIImageJPEGRepresentation(image, 0.6);
                _completeBlock(@[[UIImage imageWithData:data]]);
            }
        }
    }
}

#pragma mark - 调整拍照取回的图片方向
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
