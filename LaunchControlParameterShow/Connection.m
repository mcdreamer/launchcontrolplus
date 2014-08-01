#import "Connection.h"

NSString * ConnectionDidCloseNotification = @"ConnectionDidCloseNotification";

@interface Connection() <NSStreamDelegate> {
    id<ConnectionDelegate> _delegate;
}
@end

@implementation Connection

- (id)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    self = [super init];
    if (self != nil) {
        self->_inputStream = inputStream;
        self->_outputStream = outputStream;
    }
    return self;
}

- (BOOL)open {
    [self.inputStream  setDelegate:self];
    [self.outputStream setDelegate:self];
    [self.inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream  open];
    [self.outputStream open];
    return YES;
}

- (void)close {
    [self.inputStream  setDelegate:nil];
    [self.outputStream setDelegate:nil];
    [self.inputStream  close];
    [self.outputStream close];
    [self.inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] postNotificationName:ConnectionDidCloseNotification object:self];
}

- (void)setDelegate:(id<ConnectionDelegate>)delegate
{
    _delegate = delegate;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
    assert(aStream == self.inputStream || aStream == self.outputStream);
    #pragma unused(aStream)
    
    switch(streamEvent) {
        case NSStreamEventHasBytesAvailable: {
            uint8_t buffer[2048];
            NSInteger actuallyRead = [self.inputStream read:(uint8_t *)buffer maxLength:sizeof(buffer)];
            if (actuallyRead > 0) {
                
                NSString* data = [[NSString alloc] initWithBytes:buffer length:actuallyRead encoding:NSUTF8StringEncoding];
                
                NSLog(@"Received json: %@", data);
                
                if (_delegate)
                {
                    [_delegate jsonReceived:data];
                }
                
            } else {
                // A non-positive value from -read:maxLength: indicates either end of file (0) or 
                // an error (-1).  In either case we just wait for the corresponding stream event 
                // to come through.
            }
        } break;
        case NSStreamEventEndEncountered:
        case NSStreamEventErrorOccurred: {
            [self close];
        } break;
        case NSStreamEventHasSpaceAvailable:
        case NSStreamEventOpenCompleted:
        default: {
            // do nothing
        } break;
    }
}

@end
