//
//  NSSet+BlocksKitLight.m
//  BlocksKitLight
//

#import "NSSet+BlocksKitLight.h"

@implementation NSSet (BlocksKitLight)

- (void)bkl_each:(void (^)(id obj))block
{
	NSParameterAssert(block != nil);

	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		block(obj);
	}];
}

- (void)bkl_apply:(void (^)(id obj))block
{
	NSParameterAssert(block != nil);

	[self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, BOOL *stop) {
		block(obj);
	}];
}

- (id)bkl_match:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);

	return [[self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		if (block(obj)) {
			*stop = YES;
			return YES;
		}

		return NO;
	}] anyObject];
}

- (NSSet *)bkl_select:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);

	return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		return block(obj);
	}];
}

- (NSSet *)bkl_reject:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);

	return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
		return !block(obj);
	}];
}

- (NSSet *)bkl_map:(id (^)(id obj))block
{
	NSParameterAssert(block != nil);

	NSMutableSet *result = [NSMutableSet setWithCapacity:self.count];

	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		id value = block(obj) ?:[NSNull null];
		[result addObject:value];
	}];

	return result;
}

- (id)bkl_reduce:(id)initial withBlock:(id (^)(id sum, id obj))block
{
	NSParameterAssert(block != nil);

	__block id result = initial;

	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		result = block(result, obj);
	}];

	return result;
}

- (BOOL)bkl_any:(BOOL (^)(id obj))block
{
	return [self bkl_match:block] != nil;
}

- (BOOL)bkl_none:(BOOL (^)(id obj))block
{
	return [self bkl_match:block] == nil;
}

- (BOOL)bkl_all:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);

	__block BOOL result = YES;

	[self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		if (!block(obj)) {
			result = NO;
			*stop = YES;
		}
	}];

	return result;
}

@end
