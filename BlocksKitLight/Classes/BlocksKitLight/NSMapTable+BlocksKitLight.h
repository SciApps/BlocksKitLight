//
//  NSMapTable+BlocksKitLight.m
//  BlocksKitLight
//

#import "BKLDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKL_GENERICS(NSMapTable, KeyType, ObjectType) (BlocksKitLight)

/** Loops through the maptable and executes the given block using each item.

 @param block A block that performs an action using a key/value pair.
 */
- (void)bkl_each:(void (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find the first key/value pair matching the block.

 bkl_match: is functionally identical to bkl_select:, but will stop and return
 the value on the first match.

 @param block A BOOL-returning code block for a key/value pair.
 @return The value of the first pair found;
 */
- (nullable id)bkl_match:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find the key/value pairs matching the block.

 @param block A BOOL-returning code block for a key/value pair.
 @return Returns a maptable of the objects found.
 */
- (NSMapTable *)bkl_select:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find the key/value pairs not matching the block.

 This selector performs *literally* the exact same function as bkl_select: but in reverse.

 This is useful, as one may expect, for filtering objects.
 NSMapTable *strings = [userData bkl_reject:^BOOL(id key, id value) {
   return ([obj isKindOfClass:[NSString class]]);
 }];

 @param block A BOOL-returning code block for a key/value pair.
 @return Returns a maptable of all objects not found.
 */
- (NSMapTable *)bkl_reject:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Call the block once for each object and create a maptable with the same keys
 and a new set of values.

 @param block A block that returns a new value for a key/value pair.
 @return Returns a maptable of the objects returned by the block.
 */
- (NSMapTable *)bkl_map:(id (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find whether any key/value pair matches the block.

 This method is similar to the Scala list `exists`. It is functionally
 identical to bkl_match: but returns a `BOOL` instead. It is not recommended
 to use bkl_any: as a check condition before executing bkl_match:, since it would
 require two loops through the maptable.

 @param block A two-argument, BOOL-returning code block.
 @return YES for the first time the block returns YES for a key/value pair, NO otherwise.
 */
- (BOOL)bkl_any:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find whether no key/value pairs match the block.

 This selector performs *literally* the exact same function as bkl_all: but in reverse.

 @param block A two-argument, BOOL-returning code block.
 @return YES if the block returns NO for all key/value pairs in the maptable, NO otherwise.
 */
- (BOOL)bkl_none:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Loops through a maptable to find whether all key/value pairs match the block.

 @param block A two-argument, BOOL-returning code block.
 @return YES if the block returns YES for all key/value pairs in the maptable, NO otherwise.
 */
- (BOOL)bkl_all:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Filters a mutable dictionary to the key/value pairs matching the block.

 @param block A BOOL-returning code block for a key/value pair.
 @see <NSMapTable(BlocksKitLight)>bkl_reject:
 */
- (void)bkl_performSelect:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Filters a mutable dictionary to the key/value pairs not matching the block,
 the logical inverse to bkl_select:.

 @param block A BOOL-returning code block for a key/value pair.
 @see <NSMapTable(BlocksKitLight)>bkl_select:
 */
- (void)bkl_performReject:(BOOL (^)(KeyType key, ObjectType obj))block;

/** Transform each value of the dictionary to a new value, as returned by the
 block.

 @param block A block that returns a new value for a given key/value pair.
 @see <NSMapTable(BlocksKitLight)>bkl_map:
 */
- (void)bkl_performMap:(id (^)(KeyType key, ObjectType obj))block;

@end

NS_ASSUME_NONNULL_END
