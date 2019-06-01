//
//  main.m
//  FishHookDemo
//
//  Created by 梁华建 on 2019/5/31.
//  Copyright © 2019 梁华建. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fishhook.h"
typedef struct rebinding rebinding;
static void(*orig_nslog) (NSString *format,...);
 static NSString *path = @"/Users/lianghuajian/Desktop/MessageFromNSlog.txt";
void redirect_nslog(NSString *format, ...)
{
   //1,你要处理Log的操作，我这边是把日记写入到某个目录的txt下面
   if ([[NSFileManager defaultManager] fileExistsAtPath:path])
   {
       //拿到文件的数据并拼接
       NSMutableString *mutStr = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
       [mutStr appendFormat:@"\n"];
       [mutStr appendFormat:@"%@", format];
       [mutStr writeToFile:path atomically:true encoding:NSUTF8StringEncoding error:nil];
       
   }
//这时候NSLog的地址已经被绑定到orig_nslog这个函数上面，我们可以用其执行原有NSLog方法，即打印信息到控制台
    orig_nslog(format);
    //下面方法也一样
//    va_list va;
//    va_start(va,format);
//    NSLogv(format, va);
//    va_end(va);
    
}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //创建文件夹
         [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        //清除文件信息
        [@"" writeToFile:path atomically:true encoding:NSUTF8StringEncoding error:nil];
    
        //动态捕抓到NSLog的在Mach-o的地址，每次把其地址绑定到orig_nslog，这时候NSLog方法执行会变成被我们重定向后的方法redirect_nslog，显然我们要在里面重复一下NSLog的操作，否则NSLog方法会无法打印信息到控制台
        //{"NSLog",redirect_nslog,(void*)&orig_nslog}
        rebind_symbols((rebinding [1]){{"NSLog",redirect_nslog,(void*)&orig_nslog}}, 1);
        
        NSLog(@"网络请求状态码为200");
        NSLog(@"Json数据序列化解析成功");
        NSLog(@"解析后的数据字典转模型成功");
    }
    return 0;
}
