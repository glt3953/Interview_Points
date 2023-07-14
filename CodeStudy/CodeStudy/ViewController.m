//
//  ViewController.m
//  CodeStudy
//
//  Created by NingXia on 2023/7/14.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self groupStudy];
//    [self barrierStudy];
    [self semaphoreStudy];
}

- (void)groupStudy {
    //Dispatch groups:调度组,用于等待一组相关任务完成。可以使用dispatch_group_notify监听组中的任务完成。
    // 执行任务组
    dispatch_group_t group = dispatch_group_create();

    // 异步线程1
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:2];  // 模拟执行任务2秒
        NSLog(@"Thread 1 executed");
    });

    // 异步线程2
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:3]; // 模拟执行任务3秒
        NSLog(@"Thread 2 executed");
    });

    // 等待任务组执行完毕并执行回调
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"All tasks completed!");
    });
}

- (void)barrierStudy {
    //Barriers:栅栏,用于将任务分段。当栅栏块中的所有任务完成后,才会继续执行后续任务。
    //队列
    dispatch_queue_t queue = dispatch_queue_create("com.demo.queue", DISPATCH_QUEUE_CONCURRENT);

    // 线程1
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:1]; // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);
        }
    });

    // 线程2
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:1];
            NSLog(@"2---%@",[NSThread currentThread]);
        }
    });

    // dispatch barrier
    dispatch_barrier_async(queue, ^{
        NSLog(@"barrier---%@",[NSThread currentThread]);
    });

    // 线程3
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:1];
            NSLog(@"3---%@",[NSThread currentThread]);
        }
    });
}

- (void)semaphoreStudy {
    //Semaphores:信号量,用于控制访问共享资源的线程数。
    // 创建信号量,初始值设为0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    // 线程1
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 等待信号量,阻塞线程1
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"Thread 1 executed");
    });

    // 线程2
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSThread sleepForTimeInterval:2]; // 延迟2秒
        NSLog(@"Thread 2 executed");
        // 发送信号量,释放线程1
        dispatch_semaphore_signal(semaphore);
    });

    // 等待所有异步任务执行完
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Done!");
    });

//    运行结果:
//    Done!
//    Thread 2 executed
//    Thread 1 executed
}

@end
