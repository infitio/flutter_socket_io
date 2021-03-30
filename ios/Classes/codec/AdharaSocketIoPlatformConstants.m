//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

#import "AdharaSocketIoPlatformConstants.h"


@implementation AdharaSocketIoPlatformMethod
NSString *const AdharaSocketIoPlatformMethod_newInstance= @"newInstance";
NSString *const AdharaSocketIoPlatformMethod_clearInstance= @"clearInstance";
NSString *const AdharaSocketIoPlatformMethod_connect= @"connect";
NSString *const AdharaSocketIoPlatformMethod_emit= @"emit";
NSString *const AdharaSocketIoPlatformMethod_isConnected= @"isConnected";
NSString *const AdharaSocketIoPlatformMethod_incomingAck= @"incomingAck";
@end

@implementation TxEventTypes
NSString *const TxEventTypes_connect = @"connect";
NSString *const TxEventTypes_disconnect = @"disconnect";
NSString *const TxEventTypes_connectError = @"connectError";
NSString *const TxEventTypes_connectTimeout = @"connectTimeout";
NSString *const TxEventTypes_error = @"error";
NSString *const TxEventTypes_connecting = @"connecting";
NSString *const TxEventTypes_reconnect = @"reconnect";
NSString *const TxEventTypes_reconnectError = @"reconnectError";
NSString *const TxEventTypes_reconnectFailed = @"reconnectFailed";
NSString *const TxEventTypes_reconnecting = @"reconnecting";
NSString *const TxEventTypes_ping = @"ping";
NSString *const TxEventTypes_pong = @"pong";
@end

@implementation TxTransportModes
NSString *const TxTransportModes_websocket = @"websocket";
NSString *const TxTransportModes_polling = @"polling";
@end
