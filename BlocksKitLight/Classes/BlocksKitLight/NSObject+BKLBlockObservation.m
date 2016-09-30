//
//  NSObject+BKLBlockObservation.m
//  BlocksKitLight
//

#import "NSObject+BKLBlockObservation.h"
@import ObjectiveC.runtime;
@import ObjectiveC.message;
#import "NSArray+BlocksKitLight.h"
#import "NSDictionary+BlocksKitLight.h"
#import "NSSet+BlocksKitLight.h"
#import "NSObject+BKLAssociatedObjects.h"

typedef NS_ENUM(int, BKLObserverContext) {
	BKLObserverContextKey,
	BKLObserverContextKeyWithChange,
	BKLObserverContextManyKeys,
	BKLObserverContextManyKeysWithChange
};

@interface _BKObserver : NSObject {
	BOOL _isObserving;
}

@property (nonatomic, readonly, unsafe_unretained) id observee;
@property (nonatomic, readonly) NSMutableArray *keyPaths;
@property (nonatomic, readonly) id task;
@property (nonatomic, readonly) BKLObserverContext context;

- (id)initWithObservee:(id)observee keyPaths:(NSArray *)keyPaths context:(BKLObserverContext)context task:(id)task;

@end

static void *BKLObserverBlocksKey = &BKLObserverBlocksKey;
static void *BKLBlockObservationContext = &BKLBlockObservationContext;

@implementation _BKObserver

- (id)initWithObservee:(id)observee keyPaths:(NSArray *)keyPaths context:(BKLObserverContext)context task:(id)task
{
	if ((self = [super init])) {
		_observee = observee;
		_keyPaths = [keyPaths mutableCopy];
		_context = context;
		_task = [task copy];
	}
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context != BKLBlockObservationContext) return;

	@synchronized(self) {
		switch (self.context) {
			case BKLObserverContextKey: {
				void (^task)(id) = self.task;
				task(object);
				break;
			}
			case BKLObserverContextKeyWithChange: {
				void (^task)(id, NSDictionary *) = self.task;
				task(object, change);
				break;
			}
			case BKLObserverContextManyKeys: {
				void (^task)(id, NSString *) = self.task;
				task(object, keyPath);
				break;
			}
			case BKLObserverContextManyKeysWithChange: {
				void (^task)(id, NSString *, NSDictionary *) = self.task;
				task(object, keyPath, change);
				break;
			}
		}
	}
}

- (void)startObservingWithOptions:(NSKeyValueObservingOptions)options
{
	@synchronized(self) {
		if (_isObserving) return;

		[self.keyPaths bkl_each:^(NSString *keyPath) {
			[self.observee addObserver:self forKeyPath:keyPath options:options context:BKLBlockObservationContext];
		}];

		_isObserving = YES;
	}
}

- (void)stopObservingKeyPath:(NSString *)keyPath
{
	NSParameterAssert(keyPath);

	@synchronized (self) {
		if (!_isObserving) return;
		if (![self.keyPaths containsObject:keyPath]) return;

		NSObject *observee = self.observee;
		if (!observee) return;

		[self.keyPaths removeObject: keyPath];
		keyPath = [keyPath copy];

		if (!self.keyPaths.count) {
			_task = nil;
			_observee = nil;
			_keyPaths = nil;
		}

		[observee removeObserver:self forKeyPath:keyPath context:BKLBlockObservationContext];
	}
}

- (void)_stopObservingLocked
{
	if (!_isObserving) return;

	_task = nil;

	NSObject *observee = self.observee;
	NSArray *keyPaths = [self.keyPaths copy];

	_observee = nil;
	_keyPaths = nil;

	[keyPaths bkl_each:^(NSString *keyPath) {
		[observee removeObserver:self forKeyPath:keyPath context:BKLBlockObservationContext];
	}];
}

- (void)stopObserving
{
	if (_observee == nil) return;

	@synchronized (self) {
		[self _stopObservingLocked];
	}
}

- (void)dealloc
{
	if (self.keyPaths) {
		[self _stopObservingLocked];
	}
}

@end

static const NSUInteger BKKeyValueObservingOptionWantsChangeDictionary = 0x1000;

@implementation NSObject (BKLBlockObservation)

- (NSString *)bkl_addObserverForKeyPath:(NSString *)keyPath task:(void (^)(id target))task
{
	NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
	[self bkl_addObserverForKeyPaths:@[ keyPath ] identifier:token options:0 context:BKLObserverContextKey task:task];
	return token;
}

- (NSString *)bkl_addObserverForKeyPaths:(NSArray *)keyPaths task:(void (^)(id obj, NSString *keyPath))task
{
	NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
	[self bkl_addObserverForKeyPaths:keyPaths identifier:token options:0 context:BKLObserverContextManyKeys task:task];
	return token;
}

- (NSString *)bkl_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options task:(void (^)(id obj, NSDictionary *change))task
{
	NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
	options = options | BKKeyValueObservingOptionWantsChangeDictionary;
	[self bkl_addObserverForKeyPath:keyPath identifier:token options:options task:task];
	return token;
}

- (NSString *)bkl_addObserverForKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options task:(void (^)(id obj, NSString *keyPath, NSDictionary *change))task
{
	NSString *token = [[NSProcessInfo processInfo] globallyUniqueString];
	options = options | BKKeyValueObservingOptionWantsChangeDictionary;
	[self bkl_addObserverForKeyPaths:keyPaths identifier:token options:options task:task];
	return token;
}

- (void)bkl_addObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)identifier options:(NSKeyValueObservingOptions)options task:(void (^)(id obj, NSDictionary *change))task
{
	BKLObserverContext context = (options == 0) ? BKLObserverContextKey : BKLObserverContextKeyWithChange;
	options = options & (~BKKeyValueObservingOptionWantsChangeDictionary);
	[self bkl_addObserverForKeyPaths:@[keyPath] identifier:identifier options:options context:context task:task];
}

- (void)bkl_addObserverForKeyPaths:(NSArray *)keyPaths identifier:(NSString *)identifier options:(NSKeyValueObservingOptions)options task:(void (^)(id obj, NSString *keyPath, NSDictionary *change))task
{
	BKLObserverContext context = (options == 0) ? BKLObserverContextManyKeys : BKLObserverContextManyKeysWithChange;
	options = options & (~BKKeyValueObservingOptionWantsChangeDictionary);
	[self bkl_addObserverForKeyPaths:keyPaths identifier:identifier options:options context:context task:task];
}

- (void)bkl_removeObserverForKeyPath:(NSString *)keyPath identifier:(NSString *)token
{
	NSParameterAssert(keyPath.length);
	NSParameterAssert(token.length);

	NSMutableDictionary *dict;

	@synchronized (self) {
		dict = [self bkl_observerBlocks];
		if (!dict) return;
	}

	_BKObserver *observer = dict[token];
	[observer stopObservingKeyPath:keyPath];

	if (observer.keyPaths.count == 0) {
		[dict removeObjectForKey:token];
	}

	if (dict.count == 0) [self bkl_setObserverBlocks:nil];
}

- (void)bkl_removeObserversWithIdentifier:(NSString *)token
{
	NSParameterAssert(token);

	NSMutableDictionary *dict;

	@synchronized (self) {
		dict = [self bkl_observerBlocks];
		if (!dict) return;
	}

	_BKObserver *observer = dict[token];
	[observer stopObserving];

	[dict removeObjectForKey:token];

	if (dict.count == 0) [self bkl_setObserverBlocks:nil];
}

- (void)bkl_removeAllBlockObservers
{
	NSDictionary *dict;

	@synchronized (self) {
		dict = [[self bkl_observerBlocks] copy];
		[self bkl_setObserverBlocks:nil];
	}

	[dict.allValues bkl_each:^(_BKObserver *trampoline) {
		[trampoline stopObserving];
	}];
}

#pragma mark - "Private"s

+ (NSMutableSet *)bkl_observedClassesHash
{
	static dispatch_once_t onceToken;
	static NSMutableSet *swizzledClasses = nil;
	dispatch_once(&onceToken, ^{
		swizzledClasses = [[NSMutableSet alloc] init];
	});

	return swizzledClasses;
}

- (void)bkl_addObserverForKeyPaths:(NSArray *)keyPaths identifier:(NSString *)identifier options:(NSKeyValueObservingOptions)options context:(BKLObserverContext)context task:(id)task
{
	NSParameterAssert(keyPaths.count);
	NSParameterAssert(identifier.length);
	NSParameterAssert(task);

    Class classToSwizzle = self.class;
    NSMutableSet *classes = self.class.bkl_observedClassesHash;
    @synchronized (classes) {
        NSString *className = NSStringFromClass(classToSwizzle);
        if (![classes containsObject:className]) {
            SEL deallocSelector = sel_registerName("dealloc");
            
			__block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
            
			id newDealloc = ^(__unsafe_unretained id objSelf) {
                [objSelf bkl_removeAllBlockObservers];
                
                if (originalDealloc == NULL) {
                    struct objc_super superInfo = {
                        .receiver = objSelf,
                        .super_class = class_getSuperclass(classToSwizzle)
                    };
                    
                    void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
                    msgSend(&superInfo, deallocSelector);
                } else {
                    originalDealloc(objSelf, deallocSelector);
                }
            };
            
            IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
            
            if (!class_addMethod(classToSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
                // The class already contains a method implementation.
                Method deallocMethod = class_getInstanceMethod(classToSwizzle, deallocSelector);
                
                // We need to store original implementation before setting new implementation
                // in case method is called at the time of setting.
                originalDealloc = (void(*)(__unsafe_unretained id, SEL))method_getImplementation(deallocMethod);
                
                // We need to store original implementation again, in case it just changed.
                originalDealloc = (void(*)(__unsafe_unretained id, SEL))method_setImplementation(deallocMethod, newDeallocIMP);
            }
            
            [classes addObject:className];
        }
    }

	NSMutableDictionary *dict;
	_BKObserver *observer = [[_BKObserver alloc] initWithObservee:self keyPaths:keyPaths context:context task:task];
	[observer startObservingWithOptions:options];

	@synchronized (self) {
		dict = [self bkl_observerBlocks];

		if (dict == nil) {
			dict = [NSMutableDictionary dictionary];
			[self bkl_setObserverBlocks:dict];
		}
	}

	dict[identifier] = observer;
}

- (void)bkl_setObserverBlocks:(NSMutableDictionary *)dict
{
	[self bkl_associateValue:dict withKey:BKLObserverBlocksKey];
}

- (NSMutableDictionary *)bkl_observerBlocks
{
	return [self bkl_associatedValueForKey:BKLObserverBlocksKey];
}

@end
