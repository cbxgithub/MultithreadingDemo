//
//  ViewController.m
//  MultithreadingDemo
//
//  Created by 贺廷濬 on 2017/11/4.
//  Copyright © 2017年 cbx. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()

@property (nonatomic, assign) NSInteger tickets;
@property (nonatomic, strong) NSLock *lock;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始有20张票
    self.tickets = 20;
    //初始化锁
    self.lock = [[NSLock alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //NSThread简单使用
    //    [self NSThreadTest];
    //使用NSThread实现卖票系统
    //    [self sellingTicketsWithNSThread];
    
    //使用NSLock实现卖票系统
    //    [self sellingTicketsWithNSLock];

    //GCD简单使用 串行队列/并发队列、同步执行/异步执行
//    [self GCDTest1];
    //GCD全局队列和主队列
//    [self GCDTest2];
    //GCD Group
//    [self GCDGroup];
//    [self GCDGroup1];
    //GCD 一次执行
//    [self GCDOnce];
 
    //NSOperation的演示代码
    //NSOperation简单使用
//    [self NSOperationTest];
    //NSOperation简化代码
//    [self NSOperationTest1];
    //常用代码
//    [self NSOperationTest2];
    //线程同步
//    [self NSOperationTest3];
    //线程同步
    [self NSOperationTest4];
}

# pragma mark - NSOperation

- (void)NSOperationTest4{
    NSOperationQueue *queue = [NSOperationQueue new];
    
    [queue addOperationWithBlock:^{
        NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"同步信息1");
        }];
        NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"同步信息2");
        }];
        NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
            [NSThread sleepForTimeInterval:.5];
            NSLog(@"同步信息3");
        }];
        
        [queue addOperations:@[op1,op2,op3] waitUntilFinished:YES];
        
        NSLog(@"更新UI");
    }];
    
}

- (void)NSOperationTest3{
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"同步信息1");
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"同步信息2");
    }];
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:.5];
        NSLog(@"同步信息3");
    }];
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"更新UI");
    }];
    
    [op4 addDependency:op1];
    [op4 addDependency:op2];
    [op4 addDependency:op3];

    NSOperationQueue *queue = [NSOperationQueue new];
    
    [queue addOperations:@[op1,op2,op3,op4] waitUntilFinished:NO];
}

- (void)NSOperationTest2 {
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];

    [operationQueue addOperationWithBlock:^{
        NSLog(@"子线程处理耗时操作%@", [NSThread currentThread]);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"主线程更新UI%@", [NSThread currentThread]);
        }];
    }];
}


- (void)NSOperationTest1 {
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];

    [operationQueue addOperationWithBlock:^{
        NSLog(@"1%@",[NSThread currentThread]);
    }];
    [operationQueue addOperationWithBlock:^{
        NSLog(@"2%@",[NSThread currentThread]);
    }];
}

- (void)NSOperationTest{
    //NSBlockOperation
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"blockOperation%@",[NSThread currentThread]);
    }];
    //NSInvocationOperation
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationMethod) object:nil];
    
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];

    [operationQueue addOperation:blockOperation];
    [operationQueue addOperation:invocationOperation];
}

- (void)invocationMethod{
    NSLog(@"invocationOperation%@",[NSThread currentThread]);
}
# pragma mark - GCD

//GCD 一次执行
- (void)GCDOnce{
    for (int i = 0; i < 10; i++) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"你猜我会执行几次？");
        });
    }
}

//GCD调度组
- (void)GCDGroup{
    //创建一个调度组
    dispatch_group_t group = dispatch_group_create();
    //获取全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //为队列添加任务，并且和给定的调度组关联
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"同步信息1");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"同步信息2");
    });
    
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:.5];
        NSLog(@"同步信息3");
    });

    //所有任务执行完毕通知
    dispatch_group_notify(group, queue, ^{
        NSLog(@"全部都完了");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"更新UI");
        });
    });
}

- (void)GCDGroup1{
    //创建一个调度组
    dispatch_group_t group = dispatch_group_create();
    //获取全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //手动添加一个任务到该调度组
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"同步信息1");
        //该任务执行完毕从调度组移除
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"同步信息2");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:.5];
        NSLog(@"同步信息3");
        dispatch_group_leave(group);
    });

    //等待所有任务执行完毕 参数：1.对应的调度组 2.超时时间
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    //所有任务执行完毕才会来这里
    dispatch_async(queue, ^{
        NSLog(@"全部都完了");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"更新UI");
        });
    });
}

//全局队列和主队列
- (void)GCDTest2{
    //全局队列1.优先级或服务质量，2.保留参数，目前传0
    /*
     *  优先级和服务质量的对应关系：
     *  - DISPATCH_QUEUE_PRIORITY_HIGH:         QOS_CLASS_USER_INITIATED
     *  - DISPATCH_QUEUE_PRIORITY_DEFAULT:      QOS_CLASS_DEFAULT
     *  - DISPATCH_QUEUE_PRIORITY_LOW:          QOS_CLASS_UTILITY
     *  - DISPATCH_QUEUE_PRIORITY_BACKGROUND:   QOS_CLASS_BACKGROUND
     */
    //默认优先级的全局队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    dispatch_async(globalQueue, ^{
        
        NSLog(@"在子线程执行耗时操作！");
        dispatch_async(mainQueue, ^{
            NSLog(@"在主线程更新UI");
        });
    });

}

//串行队列/并发队列、同步执行/异步执行
- (void)GCDTest1{
    /*  创建一个队列
     *  参数：1.名字2.类型，DISPATCH_QUEUE_SERIAL（串行队列） DISPATCH_QUEUE_CONCURRENT（并发队列）
     */
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);

    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);

    /*  同步执行任务
     *  参数：1.队列2.block（任务）
     */
//    dispatch_sync(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)

    /*  异步执行任务
     *  参数：1.队列2.block（任务）
     */
//    dispatch_async(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
    
    //同步执行串行队列任务
//    for (int i = 0; i < 10; i ++) {
//        dispatch_sync(serialQueue, ^{
//            NSLog(@"%d %@",i,[NSThread currentThread]);
//        });
//    }
    //同步执行并发队列任务
//    for (int i = 0; i < 10; i ++) {
//        dispatch_sync(concurrentQueue, ^{
//            NSLog(@"%d %@",i,[NSThread currentThread]);
//        });
//    }
    //异步执行串行队列任务
//    for (int i = 0; i < 10; i ++) {
//        dispatch_async(serialQueue, ^{
//            NSLog(@"%d %@",i,[NSThread currentThread]);
//        });
//    }

    //异步执行并发队列任务
    for (int i = 0; i < 10; i ++) {
        dispatch_async(concurrentQueue, ^{
            NSLog(@"%d %@",i,[NSThread currentThread]);
        });
    }

}

- (void)GCDTest{
    
    dispatch_queue_t queue = dispatch_queue_create("gcdqueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        [NSThread sleepForTimeInterval:0.1];
        NSLog(@"登录%@",[NSThread currentThread]);
    });
    for (int i = 0; i < 10; i++) {
        NSLog(@"%d",i);
    }
    dispatch_async(queue, ^{
        NSLog(@"下载%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"支付%@",[NSThread currentThread]);
    });
    [NSThread sleepForTimeInterval:1.0];
    NSLog(@"come here");
}

# pragma mark - NSThread

- (void)NSThreadTest{
    //NSThread
    //类方法创建
    [NSThread detachNewThreadWithBlock:^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"%d",i);
            [NSThread sleepForTimeInterval:1];
        }
    }];
    //实例方法创建
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        for (int i = 97; i < 102; i++) {
            NSLog(@"%c",i);
            [NSThread sleepForTimeInterval:1];
        }
    }];
    [thread start];
    
    //设置名字
    //    [thread setName:@"myThread"];
    //    NSLog(@"%@",thread.name);
    //设置优先级，由0到1.0的浮点数指定，其中1.0是最高优先级。
    //    [thread setThreadPriority:1];
    //退出当前线程
    //    [NSThread exit];
    //睡眠 单位是秒
    //    [NSThread sleepForTimeInterval:1];
    //获取当前线程
    //    [NSThread currentThread];
    //获取主线程
    //    [NSThread mainThread];
    //判断是否在主线程
    //    [NSThread isMainThread];
}

//使用NSThread实现卖票系统
- (void)sellingTicketsWithNSThread{
    
    //创建两个线程来充当两个售票员
    [NSThread detachNewThreadWithBlock:^{
        //对卖票过程加锁
        while (true) {
            [NSThread sleepForTimeInterval:1];
//            @synchronized (self) {
                [self.lock lock];
                if (self.tickets < 1) {
                    break;
                }
                self.tickets --;
                NSLog(@"还有%ld张票",(long)self.tickets);
                [self.lock unlock];
//            }
        }
    }];
    [NSThread detachNewThreadWithBlock:^{
        //对卖票过程加锁
        while (true) {
            [NSThread sleepForTimeInterval:1];
//            @synchronized (self) {
            [self.lock lock];
                if (self.tickets < 1) {
                    break;
                }
                self.tickets --;
                NSLog(@"还有%ld张票",(long)self.tickets);
            [self.lock unlock];
//            }
        }
    }];
    
}

@end
