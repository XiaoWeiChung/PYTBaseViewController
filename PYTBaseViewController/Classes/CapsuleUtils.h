//
//  CapsuleUtils.h
//  Capsule
//
//  Created by rogers on 14-6-4.
//  Copyright (c) 2014年 umeox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
// iPhone 11系列手机
#define isiPhone11 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
#define isiPhone11Pro ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define isiPhone11ProMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

// 全面屏手机系列
#define isFullScreenDevice  ([[CapsuleUtils getiPhoneType] rangeOfString:@"iPhone X"].length || isiPhone11 || isiPhone11Pro || isiPhone11ProMax)

#define DIR_VOICE_CACHE                                 @"VoiceCache"

// 自定义的NSLog
#ifdef  DEBUG
#define DLog(fmt, ...) NSLog((@"%s(%d) " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...)
#endif

#pragma mark 用户数据缓存
#define USER_DATA_CACHE                                 @"user_data_cache"

@interface CapsuleUtils : NSObject
+(BOOL)isMobile:(NSString*)phone;
+(BOOL)isToday:(NSString*)date;
+(NSString*)addCallPrefix:(NSString*)phone isStun:(BOOL)isStun;

+(NSDateFormatter*)getYMDHHMMDateFormatter;
+(NSDateFormatter*)getYMDHHMMSSDateFormatter;
+(NSDateFormatter*)getYMDDateFormatter;
+(NSString*)getNowYMD;
+(NSString*)getNowYMDFromDate:(NSDate*)date;
+(NSString*)getNowYMDHMS;
+(NSString*)getNowYYMMDDHHMMSS;
+(NSString *)getTimeHoursAndMinutes:(NSDate *)date;
+(NSDate*)getDateWithDateStr:(NSString*)date;
+(NSString*)getYMDSinceNow:(int64_t)time;
+(int)MinDateA:(NSString*)dateA andDateB:(NSString*)dateB;

+(void)initViewControllerTitle:(UIViewController*)viewController text:(NSString*)text;
+(NSString*)getMinute:(int)value;
+(NSString*)getHHmm:(int)value;
+(float)getCurrentSliderValue:(NSDate*)date;

#pragma  mark - 缓存管理
+(NSString *)getCacheDir;
+(NSString *)getCacheDir:(NSString*)name up:(NSString*)parent;

//暂缓数据
+(NSString *)cacheData:(NSData *)data dir:(NSString *)up name:(NSString *)name;
+(NSData *)getCacheData:(NSString *)up name:(NSString *)name;
//语音暂存路径
+(NSString *)cacheUploadVoice;
+(NSString *)getCacheVoiceUrl:(NSString *)url;
+(NSString *)getNameEncoded:(NSString *)name;
//删除文件
+(void)deleteCacheFile:(NSString *)dir;

//用户设定
+(NSString*)getSystemName;
+(int)getVersion;
+(NSString*)getAppVersion;
+(NSString*)md5StringFromString:(NSString*)string;
//用户数据
+(void)setUserData:(NSDictionary *)data;
+(NSString*)getUserData:(NSString *)key;
+(NSDictionary *)getUserData;
+(void)updateUserData:(id)value forKey:(NSString *)key;
+(void)logout;
+(BOOL)isLogin;
+(BOOL)validateMobileWithString:(NSString*)strMobile;
+(void)setLastTime:(NSString*)theDate;
+(NSString*)getLastTime;
+(NSString*)intervalSinceNow:(NSString*)theDate;
+(BOOL)validateString:(NSString*)string;
+(BOOL)validateEmailWithString:(NSString*)email;
+(BOOL)validateImeiWithString:(NSString*)imei;
+(NSString*)getCurrentLanguage;

+(BOOL)compareTime:(NSString*)time1 andTime2:(NSString*)time2;
+(NSString*)separator:(NSString*)week;

//获得最大值
+(NSInteger)getMax:(NSArray*)arr;

+ (NSString *)getDeptWith:(NSString*)date;
//结合数据排序
+ (NSMutableArray*)sort:(NSMutableArray*)arr andOtherArray:(NSArray*)otherArr;
//得到正确的字符串
+ (NSString*)getValidateString:(id)value;
//压缩图片
+ (UIImage *)drawImageFromImage:(UIImage*)originImage;

// 时间差
+ (NSInteger)timeIntervalSinceNow:(NSDate*)date;
+ (NSInteger)secIntervalSinceNow:(NSTimeInterval)time;

//pragma mark 包大小转换工具类（将包大小转换成合适单位）
+ (NSString *)getDataSizeString:(int)nSize;

// 替换国外手机号码特殊字符
+ (NSString *)replacePhoneNumCharacter:(NSString *)phoneNumber;

+ (NSString *)getIdentifierName;

// 打印属性名称以及对应属性值描述
+ (void)printPropertysWithClass:(id)object;

// 获取手机型号
+ (NSString *)getiPhoneType;

+ (UIImage *)createImageWithColor:(UIColor *)color imageSize:(CGSize)imgSize;
+ (CGSize)countTextSizeWithContent:(NSString *)content andFont:(UIFont *)font andMaxSize:(CGSize)maxSize;
+ (CGSize)countAttributeTextSizeWithContent:(NSAttributedString *)content andMaxSize:(CGSize)maxSize;
// 截取图片
+ (UIImage *)getSubImage:(CGRect)rect image:(UIImage *)image;
// 压缩图片
+ (UIImage*)imageCompressImage:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
+ (NSString *)saveTempImageInSandBox:(UIImage *)image ;
// json字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//数组转json字符串
+ (NSString *)getJsonStringWithArray:(NSArray *)array;
//json字符串转数组
+ (NSArray *)getArrayWithJsonString:(NSString *)jsonString;

#pragma mark - 系统弹框
+ (void)creatSimpleAlert:(NSString *)title msg:(NSString *)msg;
+ (void)creatActionAlertWithTitle:(NSString *)title msg:(NSString *)msg okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle okSel:(void (^)(UIAlertAction *action))okSel cancelSel:(void (^)(UIAlertAction *action))cancelSel;

// 设置导航栏标题颜色
+ (void)setNavigationControllerTitleColor:(UIColor *)color;
// 设置导航栏按钮背景颜色
+ (void)setNavigationControllerBarItemBackColor:(UIColor *)color;
// 设置导航栏背景颜色及状态栏字体颜色
+ (void)setNavigationControllerBackColor:(UIColor *)color isSetStatusBarTextColorToBlack:(BOOL)isBlack;
// 设置导航栏背景图片
+ (void)setNavigationControllerBackgroundImage:(UIImage *)image;

// 渐变色
+ (void)makeGradientLayerColor:(NSArray *)colorArrs view:(UIView *)view isHorizontal:(BOOL)isHorizontal;

// 设置暗黑模式View颜色
+ (void)setBackGroundColorWithView:(UIView *)view darkColor:(UIColor *)darkColor lightColor:(UIColor *)lightColor;
// 设置暗黑模式颜色
+ (UIColor *)setColorDarkColor:(UIColor *)darkColor lightColor:(UIColor *)lightColor;

// 获取相对于屏幕的位置
+ (CGRect)getFrameFromWindow:(UIView *)view;

// 生产正方形的二维码
+ (UIImage *)generateQRCodeWithString:(NSString *)string Size:(CGFloat)size;

// 批量字符串替换
+ (void)replaceString:(NSArray <NSString *> *)array targetString:(NSString *)targetString sourceSting:(NSMutableString *)sourceSting;

// 时间戳时间转换
+ (NSString *)changeTimeToString:(long)modifyDate;

// 打电话
+ (void)callWithPhoneNumber:(NSString *)phoneNumber;
@end
