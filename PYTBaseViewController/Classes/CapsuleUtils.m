//
//  CapsuleUtils.m
//  Capsule
//
//  Created by rogers on 14-6-4.
//  Copyright (c) 2014年 umeox. All rights reserved.
//

#import "CapsuleUtils.h"
#import <MessageUI/MessageUI.h>
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import <sys/utsname.h>

@implementation CapsuleUtils
+ (NSString *)removePrefix:(NSString *)phone {
    if([phone length] > 6) {
        if([[phone substringToIndex:2] isEqualToString:@"+86"]){
            phone = [phone substringFromIndex:3];
        }
    }
    return  phone;
}

+ (NSString *)addCallPrefix:(NSString *)phone isStun:(BOOL)isStun {
    phone = [CapsuleUtils removePrefix:phone];
    if(isStun){
        return [@"0080" stringByAppendingString:phone];
    } else {
        return [@"0" stringByAppendingString:phone];
    }
}

+ (BOOL)isMobile:(NSString *)phone {
    NSString *phoneRegex = @"^((\\+86)|(\\(\\+86\\)))?(((13[0-9]{1})|(14[57]{1})|(15[0-9]{1})|(18[0-9]{1}))+\\d{8})$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}

+ (BOOL)isToday:(NSString *)date {
    BOOL result = NO;
    date = [date substringToIndex:10];
    NSLog(@"%@",date);
    if([date isEqual:[CapsuleUtils getNowYMD]]) {
        result = YES;
    }
    return result;
}

+ (NSDateFormatter*)getYMDDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    });
    return dateFormatter;
}

+ (NSDateFormatter*)getYYMMDDHHSSDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [dateFormatter setDateFormat:@"yyMMddHHmmss"];
    });
    return dateFormatter;
}

+ (NSDateFormatter *)getYMDHHMMSSDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return dateFormatter;
}

+ (NSDateFormatter *)getYMDHHMMDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    });
    return dateFormatter;
}

+ (NSDateFormatter *)getTimeHoursAndMinutesFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [dateFormatter setDateFormat:@"HH:mm"];
    });
    return dateFormatter;
}

+ (NSString *)getNowYMD {
   NSDate *sendDate = [NSDate date];
    NSString *result = [[CapsuleUtils getYMDDateFormatter] stringFromDate:sendDate];
    return  result;
}

+ (NSString *)getNowYMDFromDate:(NSDate *)date {
    NSString *result = [[CapsuleUtils getYMDDateFormatter] stringFromDate:date];
    return  result;
}

+ (NSString *)getYMDSinceNow:(int64_t)time {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000];
    NSString *result = [[CapsuleUtils getYMDDateFormatter] stringFromDate:date];
    return result;
}

+ (NSString *)getTimeHoursAndMinutes:(NSDate *)date {
    NSString *result = [[CapsuleUtils getTimeHoursAndMinutesFormatter] stringFromDate:date];
    return result;
}

+ (NSString *)getNowYYMMDDHHMMSS {
    NSString *result = nil;
    NSDate *senddate=[NSDate date];
    result = [[CapsuleUtils getYYMMDDHHSSDateFormatter] stringFromDate:senddate];
    return  result;
}

+ (NSString *)getNowYMDHMS {
   NSDate *senddate=[NSDate date];
    NSString *result = [[CapsuleUtils getYMDHHMMSSDateFormatter] stringFromDate:senddate];
    return  result;
}

+ (NSDate *)getDateWithDateStr:(NSString *)date {
    NSDate *result = [[CapsuleUtils getYMDHHMMSSDateFormatter] dateFromString:date];
    return result;
}

+ (float)getCurrentSliderValue:(NSDate *)date {
    float result = 0;
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *hhmm = [dateformatter stringFromDate:date];
    NSString *mm = [hhmm substringFromIndex:3];
    NSString *hh = [hhmm substringToIndex:2];
    float minute = [hh floatValue]*60+[mm floatValue];
    result =  minute/1440;
    return result;
}

//dateA为进度条时间 dateB为比较点时间
+ (int)MinDateA:(NSString *)dateA andDateB:(NSString *)dateB {
    int result = 0;
    NSString *date = dateA;
    NSString *DateAm = [date substringFromIndex:3];
    NSString *DateAh = [date substringToIndex:2];
    
    int minuteA = [DateAh intValue]*60 +[DateAm intValue];
    
    date = [dateB substringFromIndex:11];
    date = [date substringToIndex:5];
    NSString *DateBm = [date substringFromIndex:3];
    NSString *DateBh = [date substringToIndex:2];
    
    int minuteB = [DateBh intValue]*60 + [DateBm intValue];
    result = minuteA - minuteB;
    NSLog(@"minuteA%d---->minuteB%d",minuteA,minuteB);
    return result;
}

+ (void)initViewControllerTitle:(UIViewController *)viewController text:(NSString *)text {
    UIView *mTitleView = [[UIView alloc] init];
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_title_arrow_icon"]];
    titleImage.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *title = [[UILabel alloc]init];
    title.text = text;
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentLeft;
    [mTitleView addSubview:title];
    [mTitleView addSubview:titleImage];
    [viewController.navigationItem setTitleView:mTitleView];
}

+ (NSString *)getMinute:(int)value {
    //slider int值格式化成分钟 12:00:00;
    NSString* result = nil;
    int hours = value / 60;
    if (hours < 10) {
        result = [NSString stringWithFormat:@"%@%d",@"0",hours];
    } else {
        result = [NSString stringWithFormat:@"%d",hours];
    }
    int min = value % 60;
    if (min < 10) {
        result = [NSString stringWithFormat:@"%@%@%@%d",result,@":",@"0",min];
    } else {
        result = [NSString stringWithFormat:@"%@%@%d",result,@":",min];
    }
    result = [NSString stringWithFormat:@"%@%@",result,@":00"];
    NSLog(@"%@",result);
    
    return result;
}

+ (NSString*)getHHmm:(int)value {
    NSString *result = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
    [formatter setDateFormat:@"HH:mm"];
    NSDate *date = [formatter dateFromString:[CapsuleUtils getMinute:value]];
    result = [formatter stringFromDate:date];
    return result;
}

#pragma mark - 缓存管理
+ (NSString *)getCacheDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)getCacheDir:(NSString *)name up:(NSString *)parent {
    NSString *dir = [parent stringByAppendingPathComponent:name];
    BOOL isExists = [[NSFileManager defaultManager]fileExistsAtPath:dir];
    if (!isExists) {
        [[NSFileManager defaultManager]createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return dir;
}

//暂缓数据
+ (NSString *)cacheData:(NSData *)data dir:(NSString *)up name:(NSString *)name {
    NSString *file = [[CapsuleUtils getCacheDir:up up:[CapsuleUtils getCacheDir]] stringByAppendingPathComponent:[CapsuleUtils getNameEncoded:name]];
    [data writeToFile:file atomically:YES];
    return file;
}

+ (NSData *)getCacheData:(NSString *)up name:(NSString *)name {
    NSString *path = [[CapsuleUtils getCacheDir:up up:[CapsuleUtils getCacheDir]] stringByAppendingPathComponent:[CapsuleUtils getNameEncoded:name]];
    
    NSFileManager *file = [NSFileManager defaultManager];
    if (![file fileExistsAtPath:path]) {
        return nil;
    } else {
        return [NSData dataWithContentsOfFile:path];
    }
}

+ (NSString *)getCacheVoiceUrl:(NSString *)url {
    NSString *file = [[CapsuleUtils getCacheDir:DIR_VOICE_CACHE up:[CapsuleUtils getCacheDir]] stringByAppendingPathComponent:[CapsuleUtils getNameEncoded:url]];
    return file;
}

// 语音暂存路径
+ (NSString *)cacheUploadVoice {
    NSString *file = [[CapsuleUtils getCacheDir:DIR_VOICE_CACHE up:[CapsuleUtils getCacheDir]] stringByAppendingPathComponent:[CapsuleUtils getNameEncoded:[[NSDate date] description]]];
    return file;
}

// 暂存语音
+ (NSString *)cacheDownloadAudio:(NSData *)data to:(NSString *)url {
    NSString *file=[[CapsuleUtils getCacheDir:DIR_VOICE_CACHE up:[CapsuleUtils getCacheDir]] stringByAppendingPathComponent:[CapsuleUtils getNameEncoded:url]];
    [data writeToFile:file atomically:YES];
    return file;
}

+ (NSString *)getNameEncoded:(NSString *)name {
    // maybe crash
    if (!name) {
        return @"";
    }
    const char *str = [name UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}

// 删除文件
+ (void)deleteCacheFile:(NSString *)dir {
    DLog("%@",dir);
    BOOL res = [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    if (!res) {
        DLog(@"deleteCacheFile error");
    }
}

#pragma mark 用户设定
+ (NSString *)getSystemName {
    return [[UIDevice currentDevice] systemName];
}

+ (int)getVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleVersion"];
    return [[version stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
}

+ (NSString *)getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)md5StringFromString:(NSString*)string {
    if (string ==nil || 0 == [string length])
        return nil;
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(value, (CC_LONG)strlen(value) , outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc]initWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [outputString appendFormat:@"%02x",outputBuffer[i]];
    }
    return outputString;
}

// 用户数据
+ (void)setUserData:(NSDictionary *)data{
    if(data) {
        NSUserDefaults *userDe = [NSUserDefaults standardUserDefaults];
        [userDe setObject:data forKey:USER_DATA_CACHE];
        [userDe synchronize];
    }
}

+ (NSDictionary *)getUserData {
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    return [userD objectForKey:USER_DATA_CACHE];
}

+ (NSString *)getUserData:(NSString *)key {
    NSDictionary *dict = [CapsuleUtils getUserData];
    if (dict) {
        if ([key isEqual:@"memberId"]||
            [key isEqual:@"password"]||
            [key isEqual:@"avatar"]  ||
            [key isEqual:@"username"]) {
            return [dict objectForKey:key];
        }
        return nil;
    } else {
        return nil;
    }
}

// 更新用户数据
+ (void)updateUserData:(id)value forKey:(NSString *)key {
    NSDictionary *dict = [CapsuleUtils getUserData];
    if (dict) {
        NSMutableDictionary *user = [NSMutableDictionary dictionaryWithDictionary:dict];
        if ([key isEqual:@"memberId"]||
            [key isEqual:@"password"]||
            [key isEqual:@"avatar"]  ||
            [key isEqual:@"username"]) {
            [user setObject:value forKey:key];
        }
        [CapsuleUtils setUserData:user];
    }
}

// 退出登录
+ (void)logout{
    NSUserDefaults *userDe = [NSUserDefaults standardUserDefaults];
    [userDe removeObjectForKey:USER_DATA_CACHE];
}

// 是否登录
+ (BOOL)isLogin {
    NSDictionary *dict = [CapsuleUtils getUserData];
    if (dict) {
        return YES;
    } else {
        return NO;
    }
}

//最后请求时间
+ (void)setLastTime:(NSString*)theDate {
    NSUserDefaults *userDe = [NSUserDefaults standardUserDefaults];
    [userDe setObject:theDate forKey:@"lastTime"];
    [userDe synchronize];
}

+ (NSString*)getLastTime {
    NSUserDefaults *userDe = [NSUserDefaults standardUserDefaults];
    return [userDe objectForKey:@"lastTime"];
}

+(BOOL)validateString:(NSString*)string {
    if ([string isEqual:[NSNull null]]) {
        return NO;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if (!string) {
        return NO;
    }
    if ([string isEqualToString:@"<null>"]) {
        return NO;
    }
    if ([string length]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)intervalSinceNow:(NSString*)theDate {
    if (!theDate || ![theDate length]) {
        return @"";
    }
    NSString *result = @"";
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *fromdate=[format dateFromString:theDate];
    NSString *fromDateSt = [NSString stringWithFormat:@"%@ 00:00:00",[CapsuleUtils getNowYMDFromDate:fromdate]];
    NSString *localDateSt = [NSString stringWithFormat:@"%@ 00:00:00",[CapsuleUtils getNowYMD]];
    
    NSDate *date = [format dateFromString:fromDateSt];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    fromdate = [date  dateByAddingTimeInterval: interval];
    
    NSDate *lDate = [format dateFromString:localDateSt];
    interval = [zone secondsFromGMTForDate:lDate];
    NSDate *toDate = [lDate dateByAddingTimeInterval:interval];
    NSDateComponents *components = [gregorian components:unitFlags fromDate:fromdate toDate:toDate options:0];
    NSInteger months = [components month];
    NSInteger days = [components day];//年[components year]
    
    if (months == 0&& days == 0) {
        theDate = [[theDate substringFromIndex:11] substringToIndex:5];
        result = [result stringByAppendingFormat:@"%@ %@",NSLocalizedString(@"today", nil),theDate];
        
    } else if (months==0 && days==1) {
        theDate = [[theDate substringFromIndex:11]substringToIndex:5];
        result = [result stringByAppendingFormat:@"%@ %@",NSLocalizedString(@"yesterday", nil),theDate];
        
    } else {
        //月份
        result = [[theDate substringFromIndex:5]substringToIndex:11];
    }
    return result;
}

#pragma mark 正则表达匹配手机、邮箱、IMEI
//手机号码检查
+ (BOOL)validateMobileWithString:(NSString*)strMobile {
    NSString *mobileRegex = @"^(1)\\d{10}$";
    NSPredicate *mobilTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    return [mobilTest evaluateWithObject:strMobile];
}

//邮箱检查
+ (BOOL)validateEmailWithString:(NSString*)email {
    NSString *emailRegex = @"([A-Z0-9a-z._%+-]+@[A-Za-z0-9-.]+\\.[A-Za-z]{2,4})";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//设备imei号
+ (BOOL)validateImeiWithString:(NSString*)imei {
    NSString *imeiRegex = @"(^\\d{15}$)";
    NSPredicate *imeiTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",imeiRegex];
    return [imeiTest evaluateWithObject:imei];
}

//获得当前系统语言
+ (NSString *)getCurrentLanguage {
    NSArray *languages = [NSLocale preferredLanguages];
    if ([languages count]) {
        NSLog(@"%@",[languages objectAtIndex:0]);
        return [languages objectAtIndex:0];
    }
    return nil;
}

+ (BOOL)compareTime:(NSString*)time1 andTime2:(NSString*)time2 {
    BOOL result = NO;
    NSTimeInterval start = 0;
    NSTimeInterval end   = 0;
    NSArray *startArray = [time1 componentsSeparatedByString:@":"];
    NSArray *endArray = [time2 componentsSeparatedByString:@":"];
    switch ([startArray count])
    {
        case 1:
        {
            start = [[startArray objectAtIndex:0]intValue]*60*60;
        }
            break;
        case 2:
        {
            start = [[startArray objectAtIndex:0]intValue]*60*60 + [[startArray objectAtIndex:1]intValue]*60;
        }
            break;
        case 3:
        {
            start = [[startArray objectAtIndex:0]intValue]*60*60 + [[startArray objectAtIndex:1]intValue]*60 + [[startArray objectAtIndex:2]intValue];
        }
            
            break;
        default:
            break;
    }
    switch ([endArray count])
    {
        case 1:
        {
            end = [[endArray objectAtIndex:0]intValue]*60*60;
        }
            break;
        case 2:
        {
            end = [[endArray objectAtIndex:0]intValue]*60*60 + [[startArray objectAtIndex:1]intValue]*60;
        }
            break;
        case 3:
        {
            end = [[startArray objectAtIndex:0]intValue]*60*60 + [[startArray objectAtIndex:1]intValue]*60 + [[startArray objectAtIndex:2]intValue];
        }
            break;
        default:
            break;
    }
    if (start >= end) {
        result = YES;
    }
    return result;
}

+ (NSString*)separator:(NSString*)week {
    BOOL result = NO;
    NSString *aweek = NSLocalizedString(@"week", nil);
    for (int i = 1; i <= 7; i++) {
        if ([self range:week :i]) {
            NSString *name = [NSString stringWithFormat:@"week%d",i];
            aweek = [aweek stringByAppendingFormat:@"%@",NSLocalizedString(name, nil)];
            result = YES;
        }
    }
    if (!result) {
        return @"";
    }
    return aweek;
}

+ (BOOL)range:(NSString*)string :(NSInteger)digit {
    if (digit <= [string length]) {
        NSRange rang = NSMakeRange(digit - 1, 1);
        return [[string substringWithRange:rang]boolValue];
    }
    return NO;
}

+ (NSInteger)getMax:(NSArray*)arr {
    NSInteger max= 0;
    for (int i = 0; i < arr.count; i++)
        max =  max >= [[arr objectAtIndex:i] integerValue]?max:[[arr objectAtIndex:i] integerValue];
    return max;
}

+ (NSString *)getDeptWith:(NSString*)date {
    NSString *dept = date;
    NSDate *deptt = [[CapsuleUtils getYMDHHMMSSDateFormatter] dateFromString:date];
    NSTimeInterval interval = [deptt timeIntervalSinceDate:[NSDate date]];
    if (interval/(7*24*3600)) {
        deptt = [[NSDate date]dateByAddingTimeInterval:-(7*24*3600)];
        dept = [[CapsuleUtils getYMDHHMMSSDateFormatter] stringFromDate:deptt];
    }
    return dept;
}

+ (NSMutableArray*)sort:(NSMutableArray*)arr andOtherArray:(NSArray*)otherArr {
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:arr];
    for (int i = 0; i < [otherArr count]; i++) {
        id bean = [otherArr objectAtIndex:i];
        [array addObject:bean];
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]initWithKey:@"date" ascending:NO];
    NSArray *descs = [NSArray arrayWithObject:descriptor];
    NSArray *result = [array sortedArrayUsingDescriptors:descs];
    NSMutableArray *resultArray = [NSMutableArray arrayWithArray:result];
    return resultArray;
}

+ (NSString *)getValidateString:(id)value {
    if ([value respondsToSelector:@selector(isEqualToString:)]) {
        if ([value isEqualToString:@"<null>"]) {
            return @"";
        }
        return value;
    }
    return @"";
}

// 压缩图片
+ (UIImage *)drawImageFromImage:(UIImage *)originImage {
    UIImage *image = nil;
    UIGraphicsBeginImageContext(CGSizeMake(170, 170));
    [originImage drawInRect:CGRectMake(0, 0, 170, 170)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 时间差
+ (NSInteger)timeIntervalSinceNow:(NSDate *)date {
    return [self secIntervalSinceNow:[date timeIntervalSinceNow]];
}

+ (NSInteger)secIntervalSinceNow:(NSTimeInterval)time {
    return  (NSInteger)fabs(time/(24*60*60));
}

#pragma mark - 包大小转换工具类（将包大小转换成合适单位）
+ (NSString *)getDataSizeString:(int) nSize {
    NSString *string = nil;
    if (nSize < 1024) {
        string = [NSString stringWithFormat:@"%dB", nSize];
        
    } else if (nSize < 1048576) {
        string = [NSString stringWithFormat:@"%dK", (nSize/1024)];
        
    } else if (nSize<1073741824) {
        if ((nSize%1048576) == 0 ) {
            string = [NSString stringWithFormat:@"%dM", nSize/1048576];
            
        } else {
            int decimal = 0; //小数
            NSString *decimalStr = nil;
            decimal = (nSize%1048576);
            decimal /= 1024;
            
            if (decimal < 10) {
                decimalStr = [NSString stringWithFormat:@"%d", 0];
            } else if (decimal >= 10 && decimal < 100) {
                int i = decimal / 10;
                if (i >= 5) {
                    decimalStr = [NSString stringWithFormat:@"%d", 1];
                } else {
                    decimalStr = [NSString stringWithFormat:@"%d", 0];
                }
                
            } else if (decimal >= 100 && decimal < 1024) {
                int i = decimal / 100;
                if (i >= 5) {
                    decimal = i + 1;
                    
                    if (decimal >= 10) {
                        decimal = 9;
                    }
                    decimalStr = [NSString stringWithFormat:@"%d", decimal];
                } else {
                    decimalStr = [NSString stringWithFormat:@"%d", i];
                }
            }
            
            if (decimalStr == nil || [decimalStr isEqualToString:@""]) {
                string = [NSString stringWithFormat:@"%dMss", nSize/1048576];
            } else {
                string = [NSString stringWithFormat:@"%d.%@M", nSize/1048576, decimalStr];
            }
        }
    // >1G
    } else {
        string = [NSString stringWithFormat:@"%dG", nSize/1073741824];
    }
    return string;
}

#pragma mark - 将字符串中的一些特殊字符用'p'代替
/*
    复制iPhone通讯录中的联系人电话号码时,首位会出现一个删除不了的字符,可用此方法
 */
+ (NSString *)replacePhoneNumCharacter:(NSString *)phoneNumber {
    NSMutableString *aString = [NSMutableString stringWithString:phoneNumber];
    for (NSUInteger i = 0; i < phoneNumber.length; i++) {
        unichar character = [aString characterAtIndex:i];
        if (character > 57 || character < 48) {
            [aString replaceCharactersInRange:NSMakeRange(i, 1) withString:@"p"];
        }
    }
    return aString;
}

+ (NSString *)getIdentifierName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
}

// 获取属性名称以及对应属性值描述
+ (void)printPropertysWithClass:(id)object {
    unsigned int count;
    objc_property_t *propertys = class_copyPropertyList([object class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertys[i];
        
        NSLog(@"properName:%s, \t\tvalue:%@", property_getName(property), [object valueForKey:[NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding]]);
    }
    free(propertys);
}

// 获取手机型号
+ (NSString *)getiPhoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"])  return@"iPhone 2G";
    if([platform isEqualToString:@"iPhone1,2"])  return@"iPhone 3G";
    if([platform isEqualToString:@"iPhone2,1"])  return@"iPhone 3GS";
    if([platform isEqualToString:@"iPhone3,1"])  return@"iPhone 4";
    if([platform isEqualToString:@"iPhone3,2"])  return@"iPhone 4";
    if([platform isEqualToString:@"iPhone3,3"])  return@"iPhone 4";
    if([platform isEqualToString:@"iPhone4,1"])  return@"iPhone 4S";
    if([platform isEqualToString:@"iPhone5,1"])  return@"iPhone 5";
    if([platform isEqualToString:@"iPhone5,2"])  return@"iPhone 5";
    if([platform isEqualToString:@"iPhone5,3"])  return@"iPhone 5c";
    if([platform isEqualToString:@"iPhone5,4"])  return@"iPhone 5c";
    if([platform isEqualToString:@"iPhone6,1"])  return@"iPhone 5s";
    if([platform isEqualToString:@"iPhone6,2"])  return@"iPhone 5s";
    if([platform isEqualToString:@"iPhone7,1"])  return@"iPhone 6 Plus";
    if([platform isEqualToString:@"iPhone7,2"])  return@"iPhone 6";
    if([platform isEqualToString:@"iPhone8,1"])  return@"iPhone 6s";
    if([platform isEqualToString:@"iPhone8,2"])  return@"iPhone 6s Plus";
    if([platform isEqualToString:@"iPhone8,4"])  return@"iPhone SE";
    if([platform isEqualToString:@"iPhone9,1"])  return@"iPhone 7";
    if([platform isEqualToString:@"iPhone9,3"])  return@"iPhone 7";
    if([platform isEqualToString:@"iPhone9,2"])  return@"iPhone 7 Plus";
    if([platform isEqualToString:@"iPhone9,4"])  return@"iPhone 7 Plus";
    if([platform isEqualToString:@"iPhone10,1"]) return@"iPhone 8";
    if([platform isEqualToString:@"iPhone10,4"]) return@"iPhone 8";
    if([platform isEqualToString:@"iPhone10,2"]) return@"iPhone 8 Plus";
    if([platform isEqualToString:@"iPhone10,5"]) return@"iPhone 8 Plus";
    if([platform isEqualToString:@"iPhone10,3"]) return@"iPhone X";
    if([platform isEqualToString:@"iPhone10,6"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if([platform isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
    if([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    if([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    NSLog(@"NOTE: Unknown device type: %@", platform);
    return platform;
}

+ (UIImage *)createImageWithColor:(UIColor *)color imageSize:(CGSize)imgSize {
    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = image.CGImage;
    CGImageRef newImgRef = CGImageCreateWithImageInRect(imageRef, CGRectMake(0, 0, imgSize.width, imgSize.height));
    UIImage *newImage = [[UIImage alloc] initWithCGImage:newImgRef];
    
    return newImage;
}

+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize {
    /*
     下面方法：
     第一个参数表示区域大小。
     第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。
     第三个参数就是屏幕密度了。
     */
    UIGraphicsBeginImageContextWithOptions(reSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - 字符串自适应长宽
+ (CGSize)countTextSizeWithContent:(NSString *)content andFont:(UIFont *)font andMaxSize:(CGSize)maxSize {
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGSize textSize = [content boundingRectWithSize:maxSize
                                            options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:attributes
                                            context:nil].size;
    return textSize;
}

+ (CGSize)countAttributeTextSizeWithContent:(NSAttributedString *)content andMaxSize:(CGSize)maxSize {
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize textSize = [content boundingRectWithSize:maxSize options:options context:nil].size;
    
    return textSize;
}

//截取部分图像
+ (UIImage*)getSubImage:(CGRect)rect image:(UIImage *)image {
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CGImageRelease(subImageRef);
    return smallImage;
}

// 图片压缩
+ (UIImage*)imageCompressImage:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth {
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = (targetWidth / width) * height;
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0,0,targetWidth, targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 临时保存图片
+ (NSString *)saveTempImageInSandBox:(UIImage *)image {
    NSMutableString *mStr = [[NSMutableString alloc] initWithString:NSTemporaryDirectory()];
    [mStr appendString:@"tempHeadImg.jpg"];
    NSLog(@"%@",mStr);
    
    NSData *imgData;
    CGFloat compress = 1.0f;
    
    while (1) {
        imgData = UIImageJPEGRepresentation(image, compress);
        if((imgData.length/1024)>1024) {
            compress = compress*0.8;
        } else {
            break;
        }
    }
    
    BOOL createFile = [[NSFileManager defaultManager] createFileAtPath:mStr contents:imgData attributes:nil];
    if(createFile) {
        NSLog(@"保存临时图片成功,路径:%@",mStr);
    } else {
        NSLog(@"保存临时图片失败");
    }
    return mStr;
}

#pragma mark - json转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - json转数组
+ (NSArray *)getArrayWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    if (jsonObject != nil && error == nil){
        return jsonObject;
    } else {
        NSLog(@"json解析失败");
        return nil;
    }
}

#pragma mark - 数组转json
+ (NSString *)getJsonStringWithArray:(NSArray *)array{
    if (array.count > 0) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        jsonStr = [jsonStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        return jsonStr;
    }
    return @"";
}

#pragma mark - 系统弹框
+ (void)creatSimpleAlert:(NSString *)title msg:(NSString *)msg {
    [self creatActionAlertWithTitle:title msg:msg okTitle:nil cancelTitle:nil okSel:nil cancelSel:nil];
}

+ (void)creatActionAlertWithTitle:(NSString *)title msg:(NSString *)msg okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle okSel:(void (^)(UIAlertAction *action))okSel cancelSel:(void (^)(UIAlertAction *action))cancelSel {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    if (!okTitle.length) {
        okTitle = NSLocalizedString(@"ok", nil);
    }
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:okSel];
    [alertVc addAction:okAction];
    
    if (cancelTitle.length) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelSel];
        [alertVc addAction:cancelAction];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVc animated:YES completion:nil];
}

#pragma mark - 导航栏颜色修改
/**
 设置导航栏背景颜色及状态栏字体颜色

 @param color 设置的颜色
 @param isBlack 是否将状态栏字体设置为黑色
 */
+ (void)setNavigationControllerBackColor:(UIColor *)color isSetStatusBarTextColorToBlack:(BOOL)isBlack {
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        nav.navigationBar.barTintColor = color;
    } else {
        NSLog(@"setNavigationControllerBackColor fail");
    }
    
    if (isBlack) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
}

/**
 设置导航栏标题颜色

 @param color 设置的颜色
 */
+ (void)setNavigationControllerTitleColor:(UIColor *)color {
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:color}];
    } else {
        NSLog(@"setNavigationControllerTitleColor fail");
    }
}

/**
 设置导航栏按钮背景颜色

 @param color 设置的颜色
 */
+ (void)setNavigationControllerBarItemBackColor:(UIColor *)color {
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        [nav.navigationBar setTintColor:color];
    } else {
        NSLog(@"setNavigationControllerBarItemBackColor fail");
    }
}

/**
设置导航栏背景图片

@param image 背景image
*/
+ (void)setNavigationControllerBackgroundImage:(UIImage *)image {
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    } else {
        NSLog(@"setNavigationControllerBackgroundImage fail");
    }
}

#pragma mark - 渐变色
/**
 渐变色

 @param colorArrs 颜色数组
 @param view 添加渐变色的view
 @param isHorizontal 是否水平显示
 */
+ (void)makeGradientLayerColor:(NSArray *)colorArrs view:(UIView *)view isHorizontal:(BOOL)isHorizontal {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;

    gradientLayer.colors = colorArrs;
    gradientLayer.startPoint = CGPointMake(0, 0);
    if (isHorizontal) {
        gradientLayer.endPoint = CGPointMake(0, 1);
    } else {
        gradientLayer.endPoint = CGPointMake(1, 0);
    }
    NSMutableArray *locations = [NSMutableArray new];
    [locations addObject:@(0)];
    if (colorArrs.count>2) {
        for (CGFloat i = 1.0; i<colorArrs.count-1; i++) {
            [locations addObject:@(i/(colorArrs.count-1))];
        }
    }
    [locations addObject:@(1)];
    
    gradientLayer.locations = locations;
    [view.layer addSublayer:gradientLayer];
}

#pragma mark - 暗黑模式
+ (void)setBackGroundColorWithView:(UIView *)view darkColor:(UIColor *)darkColor lightColor:(UIColor *)lightColor {
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return lightColor;
            } else {
                return darkColor;
            }
        }];
        view.backgroundColor = dyColor;
    } else {
        view.backgroundColor = lightColor;
    }
}

+ (UIColor *)setColorDarkColor:(UIColor *)darkColor lightColor:(UIColor *)lightColor {
    if (@available(iOS 13.0, *)) {
        if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return darkColor;
        } else {
            return lightColor;
        }
    } else {
        return lightColor;
    }
}

#pragma mark - 获取相对于屏幕的位置
+ (CGRect)getFrameFromWindow:(UIView *)view {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [view convertRect:view.bounds toView:window];
    return rect;
}

#pragma mark - 生成二维码
+ (UIImage *)generateQRCodeWithString:(NSString *)string Size:(CGFloat)size {
    //创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //过滤器恢复默认
    [filter setDefaults];
    //给过滤器添加数据<字符串长度893>
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:data forKey:@"inputMessage"];
    //获取二维码过滤器生成二维码
    CIImage *image = [filter outputImage];
    UIImage *img = [self createNonInterpolatedUIImageFromCIImage:image WithSize:size];
    return img;
}
+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image WithSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    //创建bitmap
    size_t width = CGRectGetWidth(extent)*scale;
    size_t height = CGRectGetHeight(extent)*scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //保存图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - 批量字符串替换
/*
    array:          源字符串中需要替换的字符串数组
    sourceSting:    源字符串
    targetString:   替换的新字符串
 */
+ (void)replaceString:(NSArray <NSString *> *)array targetString:(NSString *)targetString sourceSting:(NSMutableString *)sourceSting {
    for (NSInteger i = 0; i<array.count; i++) {
        [sourceSting replaceOccurrencesOfString:[array objectAtIndex:i] withString:targetString options:NSCaseInsensitiveSearch range:NSMakeRange(0, sourceSting.length)];
    }
}

#pragma mark - 时间戳时间转换
/*
    将时间戳转换成指定格式的字符串
 */
+ (NSString *)changeTimeToString:(long)modifyDate {
    // 毫秒要除以1000,秒就不用
    int64_t time = modifyDate/1000;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)time];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}

#pragma mark - 打电话
+ (void)callWithPhoneNumber:(NSString *)phoneNumber {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber] options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:nil];
    }
}

@end
