//
//  NSInvocation+BlocksKitLight.m
//  BlocksKitLight
//

#import "NSInvocation+BlocksKitLight.h"

@interface BKLInvocationGrabber : NSProxy

+ (BKLInvocationGrabber *)grabberWithTarget:(id)target;

@property (nonatomic, strong) id target;
@property (nonatomic, strong) NSInvocation *invocation;

@end

@implementation BKLInvocationGrabber

+ (BKLInvocationGrabber *)grabberWithTarget:(id)target {
	BKLInvocationGrabber *instance = [BKLInvocationGrabber alloc];
	instance.target = target;
	return instance;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
	return [self.target methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation {
	[invocation setTarget:self.target];
	NSParameterAssert(self.invocation == nil);
	self.invocation = invocation;
}

@end


@implementation NSInvocation (BlocksKitLight)

+ (NSInvocation *)bkl_invocationWithTarget:(id)target block:(void (^)(id target))block
{
	NSParameterAssert(block != nil);
	BKLInvocationGrabber *grabber = [BKLInvocationGrabber grabberWithTarget:target];
	block(grabber);
	return grabber.invocation;
}

@end
