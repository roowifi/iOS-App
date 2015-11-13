// licensed under LGPL

#import <Foundation/Foundation.h>

#define SOCKET int

@interface LXSocket : NSObject {
	SOCKET m_socket;
}

+ (id)socket;
- (id)initWithCSocket:(SOCKET)_socket;
- (BOOL)bindToPort:(unsigned)port;
- (BOOL) IsConnected;
- (void) disconnect;
- (BOOL)connect:(NSString*)host port:(unsigned)port;
- (BOOL)listen:(unsigned)limit;
- (LXSocket*)accept;
- (BOOL)sendBytes:(const void*)bytes length:(unsigned)len;
- (void*)readBytesWithLength:(unsigned)len;
- (BOOL)sendInt:(int)n;
- (int)readInt;
- (BOOL)sendDouble:(double)n;
- (double)readDouble;
- (BOOL)sendInt64:(long long)n;
- (long long)readInt64;
- (BOOL)sendShort:(short)n;
- (short)readShort;
- (BOOL)sendLong:(long)n;
- (long)readLong;
- (BOOL)sendData:(NSData*)data;
- (NSData*)readData;
- (BOOL)sendObject:(id)object;
- (id)readObject;
- (NSString*)resolveHostName:(NSString*)hostName;
- (void)sendString:(NSString*)string;
- (NSString*)readString;

@end
