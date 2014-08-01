#import "ParamShowWindowController.h"

@implementation ParamShowWindowController

- (id)init
{
	return [super initWithWindowNibName:@"ParamShowWindowController"];
}

- (void)awakeFromNib
{
    [self.window setBackgroundColor:[NSColor darkGrayColor]];
}

-(void)jsonReceived:(NSString *)jsonStr
{
    NSData* jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* err = nil;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
    if (jsonDict)
    {
        NSString* bankName = [jsonDict objectForKey:@"name"];
        NSArray* paramNames = [jsonDict objectForKey:@"params"];
        
        if (bankName && paramNames)
        {
            [self updateDisplayWith:bankName andParameters:paramNames];
        }
    }
}

- (void)updateDisplayWith:(NSString*)bankName andParameters:(NSArray*)paramNames
{
    _bankName.stringValue = bankName;
    
    _param1.stringValue = paramNames[0][@"name"];
    _param2.stringValue = paramNames[1][@"name"];
    _param3.stringValue = paramNames[2][@"name"];
    _param4.stringValue = paramNames[3][@"name"];
    _param5.stringValue = paramNames[4][@"name"];
    _param6.stringValue = paramNames[5][@"name"];
    _param7.stringValue = paramNames[6][@"name"];
    _param8.stringValue = paramNames[7][@"name"];
}

@end
