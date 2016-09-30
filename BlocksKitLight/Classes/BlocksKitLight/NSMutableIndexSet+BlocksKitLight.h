//
//  NSMutableIndexSet+BlocksKitLight.h
//  BlocksKitLight
//

#import "BKLDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Block extensions for NSMutableIndexSet.

 These utilities expound upon the BlocksKit additions to the immutable
 superclass by allowing certain utilities to work on an instance of the mutable
 class, saving memory by not creating an immutable copy of the results.

 @see NSIndexSet(BlocksKitLight)
 */
@interface NSMutableIndexSet (BlocksKitLight)

/** Filters a mutable index set to the indexes matching the block.

 @param block A single-argument, BOOL-returning code block.
 @see <NSIndexSet(BlocksKitLight)>bkl_reject:
 */
- (void)bkl_performSelect:(BOOL (^)(NSUInteger index))block;

/** Filters a mutable index set to all indexes but the ones matching the block,
 the logical inverse to bkl_select:.

 @param block A single-argument, BOOL-returning code block.
 @see <NSIndexSet(BlocksKitLight)>bkl_select:
 */
- (void)bkl_performReject:(BOOL (^)(NSUInteger index))block;

/** Transform each index of the index set to a new index, as returned by the
 block.

 @param block A block that returns a new index for a index.
 @see <NSIndexSet(BlocksKitLight)>bkl_map:
 */
- (void)bkl_performMap:(NSUInteger (^)(NSUInteger index))block;


@end

NS_ASSUME_NONNULL_END
