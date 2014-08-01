#import <Foundation/Foundation.h>

@protocol ConnectionDelegate<NSObject>

- (void)jsonReceived:(NSString*)jsonStr;

@end
