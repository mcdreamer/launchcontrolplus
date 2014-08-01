#import <Foundation/Foundation.h>
#import "ConnectionDelegate.h"

@interface Server : NSObject<NSStreamDelegate>

- (bool)start;
- (void)stop;

- (void)setConnectionDelegate:(id<ConnectionDelegate>)delegate;

@end
