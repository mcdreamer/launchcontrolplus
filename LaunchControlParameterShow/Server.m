#import "Server.h"
#import "Connection.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

static const int port = 12000;

@interface Server() {
    CFSocketRef             _ipv4socket;
    id<ConnectionDelegate>  _delegate;
}

@property NSNetService* netService;
@property NSMutableSet* connections;

@end

@implementation Server

- (id)init
{
    self = [super init];
    if (self != nil) {
        _connections = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

- (void)ConnectionDidCloseNotification:(NSNotification *)note
{
    Connection* connection = [note object];
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] removeObserver:self name:ConnectionDidCloseNotification object:connection];
    [self.connections removeObject:connection];
    
    NSLog(@"Connection closed.");
}

- (void)acceptConnection:(CFSocketNativeHandle)nativeSocketHandle
{
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
    if (readStream && writeStream)
    {
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);

        Connection* connection = [[Connection alloc] initWithInputStream:(__bridge NSInputStream *)readStream outputStream:(__bridge NSOutputStream *)writeStream];
        [connection setDelegate:_delegate];
        [self.connections addObject:connection];
        [connection open];
        [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ConnectionDidCloseNotification:) name:ConnectionDidCloseNotification object:connection];
        
        NSLog(@"Added connection.");
    }
    else
    {
        // On any failure, we need to destroy the CFSocketNativeHandle 
        // since we are not going to use it any more.
        (void) close(nativeSocketHandle);
    }
    
    if (readStream) CFRelease(readStream);
    if (writeStream) CFRelease(writeStream);
}

static void ServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    assert(type == kCFSocketAcceptCallBack);
    #pragma unused(type)
    #pragma unused(address)
    
    Server *server = (__bridge Server *)info;
    assert(socket == server->_ipv4socket);
    #pragma unused(socket)
    
    // For an accept callback, the data parameter is a pointer to a CFSocketNativeHandle.
    [server acceptConnection:*(CFSocketNativeHandle *)data];
}

- (bool)start
{
    CFSocketContext socketCtxt = {0, (__bridge void *) self, NULL, NULL, NULL};
    _ipv4socket = CFSocketCreate(kCFAllocatorDefault, AF_INET,  SOCK_STREAM, 0, kCFSocketAcceptCallBack, &ServerAcceptCallBack, &socketCtxt);

    if (NULL == _ipv4socket) {
        [self stop];
        return NO;
    }

    static const int yes = 1;
    (void) setsockopt(CFSocketGetNative(_ipv4socket), SOL_SOCKET, SO_REUSEADDR, (const void *) &yes, sizeof(yes));

    // Set up the IPv4 listening socket; port is 0, which will cause the kernel to choose a port for us.
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(port);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    if (kCFSocketSuccess != CFSocketSetAddress(_ipv4socket, (__bridge CFDataRef) [NSData dataWithBytes:&addr4 length:sizeof(addr4)])) {
        [self stop];
        return NO;
    }
    
    // Set up the run loop sources for the sockets.
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv4socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source4, kCFRunLoopCommonModes);
    CFRelease(source4);

    self.netService = [[NSNetService alloc] initWithDomain:@"local" type:@"_lcparamserver._tcp." name:@"" port:port];
    [self.netService publishWithOptions:0];

    return YES;
}

- (void)stop
{
    [self.netService stop];
    self.netService = nil;
    // Closes all the open connections.  The ConnectionDidCloseNotification notification will ensure 
    // that the connection gets removed from the self.connections set.  To avoid mututation under iteration 
    // problems, we make a copy of that set and iterate over the copy.
    for (Connection * connection in [self.connections copy]) {
        [connection close];
    }
    if (_ipv4socket != NULL) {
        CFSocketInvalidate(_ipv4socket);
        CFRelease(_ipv4socket);
        _ipv4socket = NULL;
    }
}

- (void)setConnectionDelegate:(id<ConnectionDelegate>)delegate
{
    _delegate = delegate;
}

@end
