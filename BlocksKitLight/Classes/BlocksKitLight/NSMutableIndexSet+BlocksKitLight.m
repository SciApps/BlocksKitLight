//
//  NSMutableIndexSet+BlocksKitLight.m
//  BlocksKitLight
//

#import "NSMutableIndexSet+BlocksKitLight.h"

@implementation NSMutableIndexSet (BlocksKitLight)

- (void)bkl_performSelect:(BOOL (^)(NSUInteger index))block
{
	NSParameterAssert(block != nil);

	NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return !block(idx);
	}];

	if (!list.count) return;
	[self removeIndexes:list];
}

- (void)bkl_performReject:(BOOL (^)(NSUInteger index))block
{
	NSParameterAssert(block != nil);
	return [self bkl_performSelect:^BOOL(NSUInteger idx) {
		return !block(idx);
	}];
}

- (void)bkl_performMap:(NSUInteger (^)(NSUInteger index))block
{
	NSParameterAssert(block != nil);

	NSMutableIndexSet *new = [self mutableCopy];

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[new addIndex:block(idx)];
	}];

	[self removeAllIndexes];
	[self addIndexes:new];
}

@end
