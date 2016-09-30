//
//  NSSet+BlocksKitLight.h
//  BlocksKitLight
//

#import "BKLDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Block extensions for NSSet.

 Both inspired by and resembling Smalltalk syntax, these utilities allows for
 iteration of a set in a logical way that saves quite a bit of boilerplate code
 for filtering or finding objects or an object.

 Includes code by the following:

- [Michael Ash](https://github.com/mikeash)
- [Corey Floyd](https://github.com/coreyfloyd)
- [Aleks Nesterow](https://github.com/nesterow)
- [Zach Waldowski](https://github.com/zwaldowski)

 @see NSArray(BlocksKitLight)
 @see NSDictionary(BlocksKitLight)
 */
@interface BKL_GENERICS(NSSet, ObjectType) (BlocksKitLight)

/** Loops through a set and executes the given block with each object.

 @param block A single-argument, void-returning code block.
 */
- (void)bkl_each:(void (^)(ObjectType obj))block;

/** Enumerates through a set concurrently and executes
 the given block once for each object.

 Enumeration will occur on appropriate background queues. This
 will have a noticeable speed increase, especially on dual-core
 devices, but you *must* be aware of the thread safety of the
 objects you message from within the block.

 @param block A single-argument, void-returning code block.
 */
- (void)bkl_apply:(void (^)(ObjectType obj))block;

/** Loops through a set to find the object matching the block.

 bkl_match: is functionally identical to bkl_select:, but will stop and return
 on the first match.

 @param block A single-argument, BOOL-returning code block.
 @return Returns the object if found, `nil` otherwise.
 @see bkl_select:
 */
- (nullable id)bkl_match:(BOOL (^)(ObjectType obj))block;

/** Loops through a set to find the objects matching the block.

 @param block A single-argument, BOOL-returning code block.
 @return Returns a set of the objects found.
 @see bkl_match:
 */
- (NSSet *)bkl_select:(BOOL (^)(ObjectType obj))block;

/** Loops through a set to find the objects not matching the block.

 This selector performs *literally* the exact same function as select, but in reverse.

 This is useful, as one may expect, for removing objects from a set:
	 NSSet *new = [reusableWebViews bkl_reject:^BOOL(id obj) {
	   return ([obj isLoading]);
	 }];

 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of all objects not found.
 */
- (NSSet *)bkl_reject:(BOOL (^)(ObjectType obj))block;

/** Call the block once for each object and create a set of the return values.

 This is sometimes referred to as a transform, mutating one of each object:
	 NSSet *new = [mimeTypes bkl_map:^id(id obj) {
	   return [@"x-company-" stringByAppendingString:obj]);
	 }];

 @param block A single-argument, object-returning code block.
 @return Returns a set of the objects returned by the block.
 */
- (NSSet *)bkl_map:(id (^)(ObjectType obj))block;

/** Arbitrarily accumulate objects using a block.

 The concept of this selector is difficult to illustrate in words. The sum can
 be any NSObject, including (but not limited to) a string, number, or value.

 You can also do something like summing the count of an item:
	 NSUInteger numberOfBodyParts = [[bodyList bkl_reduce:nil withBlock:^id(id sum, id obj) {
	   return @([sum integerValue] + obj.numberOfAppendages);
	 }] unsignedIntegerValue];

 @param initial The value of the reduction at its start.
 @param block A block that takes the current sum and the next object to return the new sum.
 @return An accumulated value.
 */
- (nullable id)bkl_reduce:(nullable id)initial withBlock:(__nullable id (^)(__nullable id sum, ObjectType obj))block;

/** Loops through a set to find whether any object matches the block.

 This method is similar to the Scala list `exists`. It is functionally
 identical to bkl_match: but returns a `BOOL` instead. It is not recommended
 to use bkl_any: as a check condition before executing bkl_match:, since it would
 require two loops through the array.

 @param block A single-argument, BOOL-returning code block.
 @return YES for the first time the block returns YES for an object, NO otherwise.
 */
- (BOOL)bkl_any:(BOOL (^)(ObjectType obj))block;

/** Loops through a set to find whether no objects match the block.

 This selector performs *literally* the exact same function as bkl_all: but in reverse.

 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns NO for all objects in the set, NO otherwise.
 */
- (BOOL)bkl_none:(BOOL (^)(ObjectType obj))block;

/** Loops through a set to find whether all objects match the block.

 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all objects in the set, NO otherwise.
 */
- (BOOL)bkl_all:(BOOL (^)(ObjectType obj))block;

@end

NS_ASSUME_NONNULL_END
