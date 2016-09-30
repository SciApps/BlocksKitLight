//
//  NSIndexSet+BlocksKitLight.m
//  BlocksKitLight
//

#import "NSIndexSet+BlocksKitLight.h"

@implementation NSIndexSet (BlocksKitLight)

- (void)bkl_each:(void (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		block(idx);
	}];
}

- (void)bkl_apply:(void (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	[self enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL *stop) {
		block(idx);
	}];
}

- (NSUInteger)bkl_match:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	return [self indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return block(idx);
	}];
}

- (NSIndexSet *)bkl_select:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSIndexSet *list = [self indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
		return block(idx);
	}];

	return list;
}

- (NSIndexSet *)bkl_reject:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);
	return [self bkl_select:^BOOL(NSUInteger idx) {
		return !block(idx);
	}];
}

- (NSIndexSet *)bkl_map:(NSUInteger (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSMutableIndexSet *list = [NSMutableIndexSet indexSet];

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[list addIndex:block(idx)];
	}];

	return list;
}

- (NSArray *)bkl_mapIndex:(id (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		id value = block(idx) ?: [NSNull null];
		[result addObject:value];
	}];

	return result;
}

- (BOOL)bkl_any:(BOOL (^)(NSUInteger index))block {
	return [self bkl_match:block] != NSNotFound;
}

- (BOOL)bkl_none:(BOOL (^)(NSUInteger index))block {
	return [self bkl_match:block] == NSNotFound;
}

- (BOOL)bkl_all:(BOOL (^)(NSUInteger index))block {
	NSParameterAssert(block != nil);

	__block BOOL result = YES;

	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		if (!block(idx)) {
			result = NO;
			*stop = YES;
		}
	}];

	return result;
}

@end
