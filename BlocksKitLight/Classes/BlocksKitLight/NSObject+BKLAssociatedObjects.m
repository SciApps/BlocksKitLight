//
//  NSObject+BKLAssociatedObjects.m
//  BlocksKitLight
//

#import "NSObject+BKLAssociatedObjects.h"
@import ObjectiveC.runtime;

#pragma mark - Weak support

@interface _BKWeakAssociatedObject : NSObject

@property (nonatomic, weak) id value;

@end

@implementation _BKWeakAssociatedObject

@end

@implementation NSObject (BKLAssociatedObjects)

#pragma mark - Instance Methods

- (void)bkl_associateValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)bkl_atomicallyAssociateValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (void)bkl_associateCopyOfValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)bkl_atomicallyAssociateCopyOfValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

- (void)bkl_weaklyAssociateValue:(__autoreleasing id)value withKey:(const void *)key
{
	_BKWeakAssociatedObject *assoc = objc_getAssociatedObject(self, key);
	if (!assoc) {
		assoc = [_BKWeakAssociatedObject new];
		[self bkl_associateValue:assoc withKey:key];
	}
	assoc.value = value;
}

- (id)bkl_associatedValueForKey:(const void *)key
{
	id value = objc_getAssociatedObject(self, key);
	if (value && [value isKindOfClass:[_BKWeakAssociatedObject class]]) {
		return [(_BKWeakAssociatedObject *)value value];
	}
	return value;
}

- (void)bkl_removeAllAssociatedObjects
{
	objc_removeAssociatedObjects(self);
}

#pragma mark - Class Methods

+ (void)bkl_associateValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)bkl_atomicallyAssociateValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

+ (void)bkl_associateCopyOfValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)bkl_atomicallyAssociateCopyOfValue:(id)value withKey:(const void *)key
{
	objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

+ (void)bkl_weaklyAssociateValue:(__autoreleasing id)value withKey:(const void *)key
{
	_BKWeakAssociatedObject *assoc = objc_getAssociatedObject(self, key);
	if (!assoc) {
		assoc = [_BKWeakAssociatedObject new];
		[self bkl_associateValue:assoc withKey:key];
	}
	assoc.value = value;
}

+ (id)bkl_associatedValueForKey:(const void *)key
{
	id value = objc_getAssociatedObject(self, key);
	if (value && [value isKindOfClass:[_BKWeakAssociatedObject class]]) {
		return [(_BKWeakAssociatedObject *)value value];
	}
	return value;
}

+ (void)bkl_removeAllAssociatedObjects
{
	objc_removeAssociatedObjects(self);
}

@end
