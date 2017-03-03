//
//  ViewController.m
//  GemGCDDemo
//
//  Created by GemShi on 2017/3/2.
//  Copyright © 2017年 GemShi. All rights reserved.
//

#import "ViewController.h"
#import "ImitateRequestManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createUI];
    NSLog(@"%@",[NSThread mainThread]);
    
    //信号量
//    [self semaphore];
    
    //延迟执行
//    [self delayRun];
    
    //暂停和继续队列
//    [self suspendAndResume];
    
    //同步
    
    //异步
    [self AsyncRequest];
    
    //组
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 异步请求
-(void)AsyncRequest
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start-1");
        [NSThread sleepForTimeInterval:3];
        NSLog(@"end-1");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start-2");
        [NSThread sleepForTimeInterval:3];
        NSLog(@"end-2");
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start-3");
        [NSThread sleepForTimeInterval:3];
        NSLog(@"end-3");
    });
}

#pragma mark - 暂停和继续队列
-(void)suspendAndResume
{
    /**
     dispatch_suspend函数挂起指定的DispatchQueue
     dispatch_resume函数恢复指定的DispatchQueue
     */
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:5];
        NSLog(@"After 5 seconds");
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:5];
        NSLog(@"After 5 seconds again");
    });
    NSLog(@"sleep 1 second");
    [NSThread sleepForTimeInterval:1];
    NSLog(@"suspend");
    dispatch_suspend(queue);
    NSLog(@"sleep 10 seconds");
    [NSThread sleepForTimeInterval:10];
    NSLog(@"resume");
    dispatch_resume(queue);
    /**运行结果
     1' ------sleep 1 second
     2' ------suspend
     2' ------sleep 10 seconds
     6' ------After 5 seconds
     12'------resume
     17'------After 5 seconds again
     */
}

#pragma mark - 延迟执行
-(void)delayRun
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"------dispatch_after------");
    });
    NSLog(@"%s",__func__);
}

-(void)createUI
{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(50, 100, 200, 100)];
    [button setTitle:@"信号量实际应用" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(semaClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark - 信号量的实际应用（模拟了请求回调，如果不signal，则wait后的NSLog不会执行）
-(void)semaClick
{
    __block int index = 0;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ImitateRequestManager *manager = [[ImitateRequestManager alloc]init];
    [manager ImitateRequestWith:^(BOOL statues) {
        if (statues) {
            dispatch_semaphore_signal(sema);
            index = 1;
        }else{
            dispatch_semaphore_signal(sema);
            index = 2;
        }
    } AndStatues:YES];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    //callBack之后所要执行的代码
    NSLog(@"callBack------%d",index);
}

#pragma mark - 信号量
-(void)semaphore
{
    /*
     *目的：创建一个并发控制来同步任务和有限资源访问控制。
     *dispatch_group_create创建一个信号量
     *dispatch_semaphore_wait等待信号量
     *dispatch_semaphore_signal发送信号
     */
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT);
    //通过设置信号量来控制线程的最大并发数
    dispatch_semaphore_t sema = dispatch_semaphore_create(10);
    for (int i = 0; i < 100; i++) {
        //dispatch_semaphore_wait等待信号，当信号总量少于0的时候就会一直等待，否则就可以正常的执行，并让信号总量-1
        //semaphore等于0，则会阻塞线程，直到执行了Block的dispatch_semaphore_signal才会继续执行
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_group_async(group, queue, ^{
            NSLog(@"%d",i);
            sleep(2);
            //dispatch_semaphore_signal是发送一个信号，会让信号总量加1
            dispatch_semaphore_signal(sema);
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"finish");
}

@end
