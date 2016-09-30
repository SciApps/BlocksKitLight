//
//  NSTimer+BlocksKitLight.m
//  BlocksKitLight
//

#import "NSTimer+BlocksKitLight.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

@implementation NSTimer (BlocksKitLight)

+ (instancetype)bkl_scheduleTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))block
{
    NSTimer *timer = [self bkl_timerWithTimeInterval:seconds repeats:repeats usingBlock:block];
    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    return timer;
}

+ (instancetype)bkl_timerWithTimeInterval:(NSTimeInterval)inSeconds repeats:(BOOL)repeats usingBlock:(void (^)(NSTimer *timer))block
{
    NSParameterAssert(block != nil);
    CFAbsoluteTime seconds = fmax(inSeconds, 0.0001);
    CFAbsoluteTime interval = repeats ? seconds : 0;
    CFAbsoluteTime fireDate = CFAbsoluteTimeGetCurrent() + seconds;
    return (__bridge_transfer NSTimer *)CFRunLoopTimerCreateWithHandler(NULL, fireDate, interval, 0, 0, (void(^)(CFRunLoopTimerRef))block);
}

@end

#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

@implementation NSTimer (BlocksKitLight_Deprecated)

+ (instancetype)bkl_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats
{
    return [self bkl_scheduleTimerWithTimeInterval:seconds repeats:repeats usingBlock:block];
}

+ (instancetype)bkl_timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats
{
    return [self bkl_timerWithTimeInterval:seconds repeats:repeats usingBlock:block];
}

@end

#pragma clang diagnostic pop
