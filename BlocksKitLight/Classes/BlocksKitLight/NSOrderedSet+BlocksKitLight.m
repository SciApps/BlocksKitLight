//
//  NSOrderedSet+BlocksKitLight.m
//  BlocksKitLight
//

#import "NSOrderedSet+BlocksKitLight.h"

@implementation NSOrderedSet (BlocksKitLight)

- (void)bkl_each:(void (^)(id obj))block
{
	NSParameterAssert(block != nil);

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		block(obj);
	}];
}

- (void)bkl_apply:(void (^)(id obj))block
{
	NSParameterAssert(block != nil);

	[self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		block(obj);
	}];
}

- (id)bkl_match:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);

	NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return block(obj);
	}];

	if (index == NSNotFound) return nil;
	return self[index];
}

- (NSOrderedSet *)bkl_select:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);

	NSArray *objects = [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return block(obj);
	}]];

	if (!objects.count) return [[self class] orderedSet];
	return [[self class] orderedSetWithArray:objects];
}

- (NSOrderedSet *)bkl_reject:(BOOL (^)(id obj))block
{
	NSParameterAssert(block != nil);
	return [self bkl_select:^BOOL(id obj) {
		return !block(obj);
	}];
}

- (NSOrderedSet *)bkl_map:(id (^)(id obj))block
{
	NSParameterAssert(block != nil);

	NSMutableOrderedSet *result = [NSMutableOrderedSet orderedSetWithCapacity:self.count];

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		id value = block(obj) ?: [NSNull null];
		[result addObject:value];
	}];

	return result;
}

- (id)bkl_reduce:(id)initial withBlock:(id (^)(id sum, id obj))block
{
	NSParameterAssert(block != nil);

	__block id result = initial;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (!block(obj)) {
			result = NO;
			*stop = YES;
		}
	}];

	return result;
}

- (BOOL)bkl_corresponds:(NSOrderedSet *)list withBlock:(BOOL (^)(id obj1, id obj2))block
{
	NSParameterAssert(block != nil);

	__block BOOL result = NO;

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		if (idx < list.count) {
			id obj2 = list[idx];
			result = block(obj, obj2);
		} else {
			result = NO;
		}
		*stop = !result;
	}];

	return result;
}

@end
