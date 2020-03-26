//
//  RootViewController.m
//  KidFit-K3
//
//  Created by WZY on 15/12/16.
//  Copyright (c) 2015年 UMEOX. All rights reserved.
//

#import "RootViewController.h"
#import "CapsuleUtils.h"
//#import "IQKeyboardManager.h"
#import <ContactsUI/ContactsUI.h>
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>

@interface RootViewController () <CALayerDelegate,
                                  CNContactPickerDelegate,
                                  UIGestureRecognizerDelegate,
                                  UINavigationControllerDelegate,
                                  UIImagePickerControllerDelegate>
@end

@implementation RootViewController
{
    //相机或相册
    NSInteger _pictureType;
    CFAbsoluteTime startTime;
    
    void (^_takePhotoBlock)(UIImage *image);
    void (^_getSinglePicBlock)(UIImage *image);
    
    NSArray *_checkFunc_fieldArray;
    void (^_checkFuncBlock)(BOOL status);
    
    void (^_actionSheetBlock)(NSString *title);
    void (^_getContactNameAndPhoneNumber)(NSString *contactName,NSString *contactPhoneNumber);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    startTime = CFAbsoluteTimeGetCurrent();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"%@页面停留了%f秒",self.class,endTime);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    if (@available(iOS 11.0, *)) {
        settingTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
     self.edgesForExtendedLayout = UIRectEdgeNone;
     */
}

- (void)showRemindAlertViewWithTitle:(NSString *)remindTitle content:(NSString *)remindContent confirmText:(NSString *)confirm confirmBlock:(void (^)(NSInteger))confirmBlock {
    [CapsuleUtils creatActionAlertWithTitle:remindTitle msg:remindContent okTitle:confirm cancelTitle:nil okSel:^(UIAlertAction *action) {
        if (confirmBlock) {
            confirmBlock(1);
        }
    } cancelSel:^(UIAlertAction *action) {

    }];
}

- (void)showAlertViewWithTitle:(NSString *)remindTitle content:(NSString *)remindContent buttons:(NSArray *)buttonTitles confirmBlock:(void (^)(NSString * buttonTitle))confirmBlock {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:remindTitle message:remindContent preferredStyle:UIAlertControllerStyleAlert];
   
    for(NSString *title in buttonTitles) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (confirmBlock) {
                confirmBlock(title);
            }
        }];
        [alertVc addAction:cancelAction];
    }
    
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil];
//    [alertVc addAction:cancelAction];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}

#pragma mark - 相机拍照
- (void)takePhotoSuccessBlock:(void (^)(UIImage *))takePhotoBlock {
    _takePhotoBlock = takePhotoBlock;
    _pictureType = 1;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied ||
        authStatus == AVAuthorizationStatusRestricted) {
        [self showRemindAlertViewWithTitle:nil content:@"Camera is not available" confirmText:NSLocalizedString(@"infoDone", nil) confirmBlock:nil];
        
    } else {
        UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
        photoPicker.delegate = self;
        photoPicker.allowsEditing = YES;
        photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:photoPicker animated:YES completion:nil];
    }
}

#pragma mark - 相册
- (void)getSinglePictureSuccessBlock:(void (^)(UIImage *))getSinglePicBlock {
    _pictureType = 2;
    _getSinglePicBlock = getSinglePicBlock;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if(_pictureType == 1) {
        UIImage *selectedImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        [CapsuleUtils saveTempImageInSandBox:selectedImage];
        if(_takePhotoBlock) {
            _takePhotoBlock(selectedImage);
        }
        
    } else if (_pictureType == 2) {
        UIImage *selectedImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        [CapsuleUtils saveTempImageInSandBox:selectedImage];
        if(_getSinglePicBlock) {
            _getSinglePicBlock(selectedImage);
        }
    }
}

- (void)checkInputFiledWithFieldArray:(NSArray *)fieldArray andBlock:(void (^)(BOOL))statusBlock {
    _checkFunc_fieldArray = fieldArray;
    _checkFuncBlock = statusBlock;
    for(UITextField *field in fieldArray) {
        [field addTarget:self action:@selector(checkFuncFieldChange) forControlEvents:UIControlEventEditingChanged];
    }
}

#pragma mark - CheckFunction
- (void)checkFuncFieldChange {
    for(UITextField *textField in _checkFunc_fieldArray) {
        if(textField.text.length == 0) {
            _checkFuncBlock(NO);
            return;
        }
    }
    _checkFuncBlock(YES);
}

- (void)addTextFieldResignFirstResponseFunction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignResponse)];
    [self.view addGestureRecognizer:tap];
}

- (void)resignResponse {
    [self.view endEditing:YES];
}

#pragma mark - 获取通讯录内容
/**
 *  当用户选中某一个联系人的时候会执行该方法
 *
 *  @param contactData 选中的联系人
 */
- (void)getContactNameAndPhoneNumber:(void (^)(NSString *, NSString *))contactData {
    _getContactNameAndPhoneNumber = contactData;
    
    // 1.创建选择联系人的界面
    if (@available(iOS 9.0, *)) {
        CNContactPickerViewController *cpvc = [[CNContactPickerViewController alloc] init];
        
        // 2.设置代理
        cpvc.delegate = self;
        
        // 3.弹出控制器
        [self presentViewController:cpvc animated:YES completion:nil];
    }
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact  API_AVAILABLE(ios(9.0)) {
    // 1.获取联系人的姓名
    NSString *lastname = contact.familyName;
    NSString *firstname = contact.givenName;
    NSString *resultName;
    if (lastname.length == 0 && firstname.length == 0) {
        resultName = contact.organizationName;
    } else {
        resultName = [NSString stringWithFormat:@"%@%@",lastname,firstname];
    }
    NSLog(@"lastname--%@ firstname--%@", lastname, firstname);
    
    NSString *phoneValue;
    // 2.获取电话号码
    for (CNLabeledValue *labelValue in contact.phoneNumbers) {
        // 3.获取电话的label/value
        NSString *phoneLabel = labelValue.label;
        CNPhoneNumber *phoneNumber = labelValue.value;
        phoneValue = phoneNumber.stringValue;
        NSLog(@"phoneLabel--%@ phoneValue--%@", phoneLabel, phoneValue);
    }
    
    if (_getContactNameAndPhoneNumber) {
        _getContactNameAndPhoneNumber(resultName,phoneValue);
    }
}

#pragma mark - actionSheet弹出
- (void)creatActionSheetWithTitle:(NSString *)title btnTitles:(NSArray <NSString *>*)btnTitles cancelTitle:(NSString *)cancelTitle btnSel:(void(^)(NSString *title))btnSel {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleActionSheet];

    for (NSString *str in btnTitles) {
        if (str.length) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (btnSel) {
                    btnSel(action.title);
                }
            }];
            [alertVc addAction:action];
        }
    }
    
    if (!cancelTitle.length) {
        cancelTitle = NSLocalizedString(@"cancel", nil);
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:cancelAction];
    [self presentViewController:alertVc animated:YES completion:nil];
}

#pragma mark - 判断是否打开推送设置
- (void)openSystemSetting {
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                NSLog(@"未选择");
                [self popNotificationAlert];
                
            } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                NSLog(@"未授权");
                [self popNotificationAlert];
                
            } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                NSLog(@"已授权");
            }
        }];
    } else {
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == 0) {
            [self popNotificationAlert];
        }
    }
}

- (void)popNotificationAlert {
    /**< 弹出框 */
    [self showAlertViewWithTitle:@"推送通知关闭" content:@"请前往【设置】-【通知】-【wherecom】打开推送服务,获取更多精彩瞬间!" buttons:@[NSLocalizedString(@"ok", nil)] confirmBlock:^(NSString *buttonTitle) {
        if ([buttonTitle isEqualToString:NSLocalizedString(@"ok", nil)]) {
            if (@available(iOS 10.0, *)) {
                [self opentNotification];
            }
        }
    }];
}

- (void)opentNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:nil];
        }
    });
}

#pragma mark - 本地推送
/**
 *   创建一个多少秒之后弹出的本地推送
 *   title: 推送标题
 *   body:推送内容
 *   sinceNowTime:延迟时间(单位:秒)
 */
- (void)setLocalPush:(NSString *)title content:(NSString *)body sinceNowTime:(NSUInteger)SinceTime {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        // 标题
        content.title = title;
        // content.subtitle = @"测试通知副标题";
        // 内容
        content.body = body;
        // 声音
        // 默认声音
        content.sound = [UNNotificationSound defaultSound];
        // 添加自定义声音
        // content.sound = [UNNotificationSound soundNamed:@"Alert_ActivityGoalAttained_Salient_Haptic.caf"];
        // 角标 （我这里测试的角标无效，暂时没找到原因）
        content.badge = @(1);
        // 多少秒后发送,可以将固定的日期转化为时间
        NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:SinceTime] timeIntervalSinceNow];
        // NSTimeInterval time = 10;
        // repeats，是否重复，如果重复的话时间必须大于60s，要不会报错
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.minute = 54;
        dateComponents.hour = 17;
        dateComponents.day = 4;
        dateComponents.month = 8;
        dateComponents.year = 2019;
//        UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        // 添加通知的标识符，可以用于移除，更新等操作
        NSString *identifier = @"noticeId";
//         UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:calendarTrigger];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            NSLog(@"成功添加推送");
        }];
    }
}

#pragma mark - 带阴影效果的圆形图片(但不支持触摸响应)
- (void)makeImageViewCircleAndShadow {
    self.circleImageView.hidden = YES;
    
    CGPoint position=CGPointMake(self.circleImageView.center.x, self.circleImageView.center.y);
    CGRect bounds=CGRectMake(0, 0, self.circleImageView.frame.size.height, self.circleImageView.frame.size.height);
    CGFloat cornerRadius=self.circleImageView.frame.size.height/2;
    CGFloat borderWidth=2;
    
    //阴影图层
    CALayer *layerShadow=[[CALayer alloc]init];
    layerShadow.bounds=bounds;
    layerShadow.position=position;
    layerShadow.cornerRadius=cornerRadius;
    layerShadow.shadowColor=[UIColor grayColor].CGColor;
    layerShadow.shadowOffset=CGSizeMake(2, 1);
    layerShadow.shadowOpacity=1;
    layerShadow.borderColor=[UIColor whiteColor].CGColor;
    layerShadow.borderWidth=borderWidth;
    [self.view.layer addSublayer:layerShadow];
    
    //容器图层
    CALayer *layer=[[CALayer alloc]init];
    layer.bounds=bounds;layer.position=position;
    layer.backgroundColor=[UIColor redColor].CGColor;
    layer.cornerRadius=cornerRadius;
    layer.masksToBounds=YES;
    layer.borderColor=[UIColor whiteColor].CGColor;
    layer.borderWidth=borderWidth;
    layer.delegate=self;
    [self.view.layer addSublayer:layer];
    
    //调用图层setNeedDisplay,否则代理方法不会被调用
    [layer setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -self.circleImageView.frame.size.height);
    //注意这个位置是相对于图层而言的不是屏幕
    CGContextDrawImage(ctx, CGRectMake(0, 0, self.circleImageView.frame.size.height, self.circleImageView.frame.size.height), self.circleImageView.image.CGImage);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

#pragma mark - 属性设置
// 滑动返回手势
- (void)setCanSlideToBack:(BOOL)canSlideToBack {
    if (canSlideToBack) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

// 是否强制暗黑模式
//- (void)setForceColor:(ForceBackgroundColoer)forceColor {
//    if (@available(iOS 13.0, *)) {
//        if (forceColor == ForceBackgroundColoerDark) {
//            self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
//
//        } else if (forceColor == ForceBackgroundColoerLight) {
//            self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
//
//        } else {
//            self.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
//        }
//    } else {
//        NSLog(@"iOS 13以下没有该属性设置");
//    }
//}

// 键盘第三方
//- (void)IQKeyboardManagerTest {
//    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
//    // 控制整个功能是否启用
//    manager.enable = YES;
//    // 控制点击背景是否收起键盘
//    manager.shouldResignOnTouchOutside = YES;
//    // 控制键盘上的工具条文字颜色是否用户自定义
//    manager.shouldToolbarUsesTextFieldTintColor = YES;
//    // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
//    manager.toolbarManageBehaviour = IQAutoToolbarBySubviews;
//    // 控制是否显示键盘上的工具条
//    manager.enableAutoToolbar = NO;
//    // 是否显示占位文字
//    manager.shouldShowToolbarPlaceholder = YES;
//    // 设置占位文字的字体
//    manager.placeholderFont = [UIFont boldSystemFontOfSize:17];
//    // 输入框距离键盘的距离
//    manager.keyboardDistanceFromTextField = 10.0f;
//}

#pragma mark - 周期函数
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
     制作一个 row行 column列 的矩阵按钮
     @param   row               行
     @param   column            列
     @param   rowPadding        行间距
     @param   columnPadding     列间距
     @param   postionX          起始位置X
     @param   postionY          起始位置Y
     @param   width             宽
     @param   height            高
*/
- (void)creatRectModelWithRow:(NSInteger)row Column:(NSInteger)column rowPadding:(NSInteger)rowPadding columnPadding:(NSInteger)columnPadding postionX:(NSInteger)postionX postionY:(NSInteger)postionY width:(NSInteger)width height:(NSInteger)height {
    NSInteger index = 1;
    for (NSInteger i = 0; i<row; i++) {
        for (NSInteger j = 0; j<column; j++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = kRandomColor;
            CGRect frame = CGRectMake(j*(width+rowPadding)+postionX, i*(height+columnPadding)+postionY, width, height);
            [btn setFrame:frame];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:[NSString stringWithFormat:@"%@",@(index)] forState:UIControlStateNormal];
            index++;
            [self.view addSubview:btn];
        }
    }
}

- (void)btnClick:(UIButton *)sender {
    NSLog(@"%@",sender.titleLabel.text);
}

@end
