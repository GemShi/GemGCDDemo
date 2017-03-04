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
//    [self SyncRequest];
    
    //异步
//    [self AsyncRequest];
    
    //组
//    [self dispatchGroup];
    
    //组的应用，异步请求，统一回调
//    [self groupRequest];
    
    //apply
//    [self dispatchApply];
    [self ImitateForCycle];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 批量执行
/**
 dispatch_apply函数是dispatch_sync函数和Dispatch Group的关联API,该函数按指定的次数将指定的Block追加到指定的Dispatch Queue中,并等到全部的处理执行结束
 */
-(void)dispatchApply
{
    dispatch_apply(10, dispatch_get_global_queue(0, 0), ^(size_t index) {
        NSLog(@"%zu",index);
    });
}

//模拟for循环
//在dispatch_async函数中异步执行dispatch_apply函数,模拟dispatch_sync的同步效果
-(void)ImitateForCycle
{
    NSArray *array = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j"];
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        dispatch_apply(array.count, queue, ^(size_t index) {
            NSLog(@"%zu------%@",index,[array objectAtIndex:index]);
            [NSThread sleepForTimeInterval:2];
        });
    });
}

#pragma mark - 异步请求，统一回调
-(void)groupRequest
{
    dispatch_queue_t queue = dispatch_queue_create("EnterAndLeave", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self request1:^{
        NSLog(@"request1-done");
        dispatch_group_leave(group);
    }];
    dispatch_group_enter(group);
    [self request2:^{
        NSLog(@"request2-done");
        dispatch_group_leave(group);
    }];
    dispatch_group_notify(group, queue, ^{
        NSLog(@"All task over");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",[NSThread currentThread]);
        });
    });
}

-(void)request1:(void(^)())block
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"request1-start");
        [NSThread sleepForTimeInterval:3];
        if (block) {
            block();
        }
    });
}

-(void)request2:(void(^)())block
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"request2-start");
        [NSThread sleepForTimeInterval:3];
        if (block) {
            block();
        }
    });
}

#pragma mark - 组队列
/**
 group结束的两种方式
 1.dispatch_group_wait(group,dispatch_time());
 阻塞当前线程，直到dispatch_group所有任务完成返回
 2.dispatch_group_notify(group,queue,block);
 不会阻塞当前线程，所有组执行完后会立即返回
 */
-(void)dispatchGroup
{
    //异步执行，统一回调------可以管理多个webService
    dispatch_queue_t queue = dispatch_queue_create("group", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"start-1");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"end-1");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"start-2");
        [NSThread sleepForTimeInterval:2];
        NSLog(@"end-2");
    });
    dispatch_group_async(group, queue, ^{
        //前两组暂停2秒，该组暂停5秒，所以比前两组晚3秒执行
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
        NSLog(@"dispatch_group_wait");
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"All task over");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",[NSThread currentThread]);
        });
    });
}

#pragma mark - 同步请求
-(void)SyncRequest
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start-1");
        [NSThread sleepForTimeInterval:3];
        NSLog(@"end-1");
    });
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start-2");
        [NSThread sleepForTimeInterval:3];
        NSLog(@"end-2");
    });
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start-3");
        [NSThread sleepForTimeInterval:3];
        NSLog(@"end-3");
    });
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
