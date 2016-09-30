//
//  BKLMacros.h
//  BlocksKitLight
//
//  Includes code by Michael Ash. <https://github.com/mikeash>.
//

#import "BKLDefines.h"
#import "NSArray+BlocksKitLight.h"
#import "NSSet+BlocksKitLight.h"
#import "NSDictionary+BlocksKitLight.h"
#import "NSIndexSet+BlocksKitLight.h"

#ifndef __BLOCKSKITLIGHT_MACROS__
#define __BLOCKSKITLIGHT_MACROS__

#define __BKL_EACH_WRAPPER(...) (^{ __block CFMutableDictionaryRef BKL_eachTable = nil; \
		(void)BKL_eachTable; \
		__typeof__(__VA_ARGS__) BKL_retval = __VA_ARGS__; \
		if(BKL_eachTable) \
			CFRelease(BKL_eachTable); \
		return BKL_retval; \
	}())

#define __BKL_EACH_WRAPPER_VOID(...) (^{ __block CFMutableDictionaryRef BKL_eachTable = nil; \
		(void)BKL_eachTable; \
		__VA_ARGS__; \
		if(BKL_eachTable) \
			CFRelease(BKL_eachTable); \
	}())

#define BKL_EACH(collection, ...) __BKL_EACH_WRAPPER_VOID([collection bkl_each:^(id obj) { __VA_ARGS__ }])
#define BKL_MAP(collection, ...) __BKL_EACH_WRAPPER([collection bkl_map:^id(id obj) { return (__VA_ARGS__); }])
#define BKL_SELECT(collection, ...) __BKL_EACH_WRAPPER([collection bkl_select: ^BOOL (id obj) { return (__VA_ARGS__) != 0; }])
#define BKL_REJECT(collection, ...) __BKL_EACH_WRAPPER([collection bkl_select: ^BOOL (id obj) { return (__VA_ARGS__) == 0; }])
#define BKL_MATCH(collection, ...) __BKL_EACH_WRAPPER([collection bkl_match: ^BOOL (id obj) { return (__VA_ARGS__) != 0; }])
#define BKL_REDUCE(collection, initial, ...) __BKL_EACH_WRAPPER([collection bkl_reduce: (initial) withBlock: ^id (id a, id b) { return (__VA_ARGS__); }])

// BKL_APPLY is not wrapped, because we don't guarantee that the order matches the current collection during parallel execution.
#define BKL_APPLY(collection, ...) [collection bkl_apply:^(id obj) { __VA_ARGS__ }]

static inline id BKLNextHelper(NSArray *array, CFMutableDictionaryRef *eachTablePtr) {

    if (!*eachTablePtr) {
        CFDictionaryKeyCallBacks keycb = kCFTypeDictionaryKeyCallBacks;
        keycb.equal = NULL;
        keycb.hash = NULL;
        *eachTablePtr = CFDictionaryCreateMutable(NULL, 0, &keycb, &kCFTypeDictionaryValueCallBacks);
    }

    NSEnumerator *enumerator = (__bridge id)CFDictionaryGetValue(*eachTablePtr, (__bridge CFArrayRef)array);
    if (!enumerator) {
        enumerator = [array objectEnumerator];
        CFDictionarySetValue(*eachTablePtr, (__bridge CFArrayRef)array, (__bridge void *)enumerator);
    }
    return [enumerator nextObject];
}

#define BKL_NEXT(array) BKLNextHelper(array, &BKL_eachTable)

#ifndef EACH
#define EACH BKL_EACH
#endif

#ifndef APPLY
#define APPLY BKL_APPLY
#endif

#ifndef MAP
#define MAP BKL_MAP
#endif

#ifndef SELECT
#define SELECT BKL_SELECT
#endif

#ifndef REJECT
#define REJECT BKL_REJECT
#endif

#ifndef MATCH
#define MATCH BKL_MATCH
#endif

#ifndef REDUCE
#define REDUCE BKL_REDUCE
#endif

#ifndef NEXT
#define NEXT BKL_NEXT
#endif

#endif
