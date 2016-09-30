//
//  NSMutableDictionary+BlocksKitLight.m
//  BlocksKitLight
//

#import "NSMutableDictionary+BlocksKitLight.h"

@implementation NSMutableDictionary (BlocksKitLight)

- (void)bkl_performSelect:(BOOL (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	NSArray *keys = [[self keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id key, id obj, BOOL *stop) {
		return !block(key, obj);
	}] allObjects];

	[self removeObjectsForKeys:keys];
}

- (void)bkl_performReject:(BOOL (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);
	[self bkl_performSelect:^BOOL(id key, id obj) {
		return !block(key, obj);
	}];
}

- (void)bkl_performMap:(id (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	NSMutableDictionary *new = [self mutableCopy];

	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		id value = block(key, obj) ?: [NSNull null];
		if ([value isEqual:obj]) return;
		new[key] = value;
	}];

	[self setDictionary:new];
}

@end
