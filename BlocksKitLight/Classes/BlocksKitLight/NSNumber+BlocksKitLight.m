//
//  NSNumber+BlocksKitLight.m
//  BlocksKitLight
//

#import "NSNumber+BlocksKitLight.h"

@implementation NSNumber (BlocksKitLight)

- (void)bkl_times:(void (^)())block
{
  NSParameterAssert(block != nil);

  for (NSInteger idx = 0 ; idx < self.integerValue ; ++idx ) {
    block();
  }
}

@end
