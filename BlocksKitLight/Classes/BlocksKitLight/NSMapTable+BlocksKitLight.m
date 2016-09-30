//
//  NSMapTable+BlocksKitLight.h
//  BlocksKitLight
//

#import "NSMapTable+BlocksKitLight.h"

@implementation NSMapTable (BlocksKitLight)

- (void)bkl_enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    BOOL stop = NO;
    for(id key in self) {
        id obj = [self objectForKey:key];
        block(key, obj, &stop);
        if(stop) {
            break;
        }
    }
}

- (void)bkl_each:(void (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);

    [self bkl_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}

- (id)bkl_match:(BOOL (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);

    __block id match = nil;
    [self bkl_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(block(key, obj)) {
            match = obj;
            *stop = YES;
        }
    }];
    return match;
}

- (NSMapTable *)bkl_select:(BOOL (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self bkl_each:^(id key, id obj) {
        if(block(key, obj)) {
            [result setObject:obj forKey:key];
        }
    }];

    return result;
}

- (NSMapTable *)bkl_reject:(BOOL (^)(id key, id obj))block
{
    return [self bkl_select:^BOOL(id key, id obj) {
        return !block(key, obj);
    }];
}

- (NSMapTable *)bkl_map:(id (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self bkl_each:^(id key, id obj) {
        id value = block(key, obj);
        if (!value)
            value = [NSNull null];

        [result setObject:value forKey:key];
    }];

    return result;
}

- (BOOL)bkl_any:(BOOL (^)(id key, id obj))block
{
    return [self bkl_match:block] != nil;
}

- (BOOL)bkl_none:(BOOL (^)(id key, id obj))block
{
    return [self bkl_match:block] == nil;
}

- (BOOL)bkl_all:(BOOL (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);

    __block BOOL result = YES;

    [self bkl_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!block(key, obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

- (void)bkl_performSelect:(BOOL (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:self.count];

	[self bkl_each:^(id key, id obj) {
		if(!block(key, obj)) {
			[keys addObject:key];
		}
	}];

	for(id key in keys) {
		[self removeObjectForKey:key];
	}
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

	NSMutableDictionary *mapped = [NSMutableDictionary dictionaryWithCapacity:self.count];

	[self bkl_each:^(id key, id obj) {
		mapped[key] = block(key, obj);
	}];

	[mapped enumerateKeysAndObjectsUsingBlock:^(id key, id mappedObject, BOOL *stop) {
		[self setObject:mappedObject forKey:key];
	}];
}

@end
