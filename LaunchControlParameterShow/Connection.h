#import <Foundation/Foundation.h>
#import "ConnectionDelegate.h"

@interface Connection : NSObject

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;
- (void)setDelegate:(id<ConnectionDelegate>)delegate;

@property (nonatomic, strong, readonly ) NSInputStream *    inputStream;
@property (nonatomic, strong, readonly ) NSOutputStream *   outputStream;

- (BOOL)open;
- (void)close;

extern NSString* ConnectionDidCloseNotification;

@end
