//
// Generated code. Do not modify.
// source file can be found at bin/templates'
//

@import Foundation;

typedef NS_ENUM(UInt8, _Value) {
    type1CodecType = 128,
};


@interface AdharaSocketIoPlatformMethod : NSObject
extern NSString *const AdharaSocketIoPlatformMethod_method1;
@end

@interface TxEventTypes : NSObject
extern NSString *const TxEventTypes_connect;
extern NSString *const TxEventTypes_disconnect;
extern NSString *const TxEventTypes_connectError;
extern NSString *const TxEventTypes_connectTimeout;
extern NSString *const TxEventTypes_error;
extern NSString *const TxEventTypes_connecting;
extern NSString *const TxEventTypes_reconnect;
extern NSString *const TxEventTypes_reconnectError;
extern NSString *const TxEventTypes_reconnectFailed;
extern NSString *const TxEventTypes_reconnecting;
extern NSString *const TxEventTypes_ping;
extern NSString *const TxEventTypes_pong;
@end

@interface TxTransportModes : NSObject
extern NSString *const TxTransportModes_websocket;
extern NSString *const TxTransportModes_polling;
@end
