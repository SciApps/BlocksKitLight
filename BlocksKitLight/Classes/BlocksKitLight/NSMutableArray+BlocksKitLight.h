//
//  NSMutableArray+BlocksKitLight.h
//  BlocksKitLight
//

#import "BKLDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Block extensions for NSMutableArray.

 These utilities expound upon the BlocksKit additions to the immutable
 superclass by allowing certain utilities to work on an instance of the mutable
 class, saving memory by not creating an immutable copy of the results.

 Includes code by the following:

 - [Martin Schürrer](https://github.com/MSch)
 - [Zach Waldowski](https://github.com/zwaldowski)

 @see NSArray(BlocksKitLight)
 */
@interface BKL_GENERICS(NSMutableArray, ObjectType) (BlocksKitLight)

/** Filters a mutable array to the objects matching the block.

 @param block A single-argument, BOOL-returning code block.
 @see <NSArray(BlocksKitLight)>bkl_reject:
 */
- (void)bkl_performSelect:(BOOL (^)(id ObjectType))block;

/** Filters a mutable array to all objects but the ones matching the block,
 the logical inverse to bkl_select:.

 @param block A single-argument, BOOL-returning code block.
 @see <NSArray(BlocksKitLight)>bkl_select:
 */
- (void)bkl_performReject:(BOOL (^)(id ObjectType))block;

/** Transform the objects in the array to the results of the block.

 This is sometimes referred to as a transform, mutating one of each object:
	[foo bkl_performMap:^id(id obj) {
	  return [dateTransformer dateFromString:obj];
	}];

 @param block A single-argument, object-returning code block.
 @see <NSArray(BlocksKitLight)>bkl_map:
 */
- (void)bkl_performMap:(id (^)(id ObjectType))block;

@end

NS_ASSUME_NONNULL_END
