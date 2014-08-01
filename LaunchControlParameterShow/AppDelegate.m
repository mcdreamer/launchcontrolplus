#import "AppDelegate.h"
#import "Server.h"
#import "ParamShowWindowController.h"

@interface AppDelegate() {
    Server* _server;
    ParamShowWindowController* _windowController;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _server = [[Server alloc] init];
    if ([_server start])
    {
        _windowController = [[ParamShowWindowController alloc] init];
        [_windowController showWindow:self];
        
        [_server setConnectionDelegate:_windowController];
    }
    else
    {
        NSAlert* alert = [[NSAlert alloc] init];
        alert.messageText = @"Failed to start server";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
        [[NSApplication sharedApplication] terminate:self];
    }
}

@end
