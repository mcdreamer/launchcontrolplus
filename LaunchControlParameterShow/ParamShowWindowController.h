#import <Cocoa/Cocoa.h>
#import "ConnectionDelegate.h"

@interface ParamShowWindowController : NSWindowController<ConnectionDelegate>

- (void)jsonReceived:(NSString *)jsonStr;

@property (weak) IBOutlet NSTextField *bankName;
@property (weak) IBOutlet NSTextField *param1;
@property (weak) IBOutlet NSTextField *param2;
@property (weak) IBOutlet NSTextField *param3;
@property (weak) IBOutlet NSTextField *param4;
@property (weak) IBOutlet NSTextField *param5;
@property (weak) IBOutlet NSTextField *param6;
@property (weak) IBOutlet NSTextField *param7;
@property (weak) IBOutlet NSTextField *param8;

@end
