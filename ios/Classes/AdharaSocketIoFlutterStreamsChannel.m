//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//
//  Original work on StreamsChannel by loup-v
//  at https://github.com/loup-v/streams_channel

#import "AdharaSocketIoFlutterStreamsChannel.h"

@interface AdharaSocketIoFlutterStreamsChannelStream : NSObject
  @property(strong, nonatomic) FlutterEventSink sink;
  @property(strong, nonatomic) NSObject<FlutterStreamHandler> *handler;
@end

@implementation AdharaSocketIoFlutterStreamsChannelStream

@end

// Inspired from: https://github.com/flutter/engine/blob/master/shell/platform/darwin/common/framework/Source/FlutterChannels.mm
@implementation AdharaSocketIoFlutterStreamsChannel {
  NSObject<FlutterBinaryMessenger>* _messenger;
  NSString* _name;
  NSObject<FlutterMethodCodec>* _codec;
}
+ (instancetype)streamsChannelWithName:(NSString* _Nonnull)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger {
  NSObject<FlutterMethodCodec>* codec = [FlutterStandardMethodCodec sharedInstance];
  return [AdharaSocketIoFlutterStreamsChannel streamsChannelWithName:name binaryMessenger:messenger codec:codec];
}

+ (instancetype)streamsChannelWithName:(NSString* _Nonnull)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                               codec:(NSObject<FlutterMethodCodec>* _Nonnull)codec {
  return [[AdharaSocketIoFlutterStreamsChannel alloc] initWithName:name binaryMessenger:messenger codec:codec];
}

- (instancetype)initWithName:(NSString* _Nonnull)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                       codec:(NSObject<FlutterMethodCodec>* _Nonnull)codec {
  self = [super init];
  NSAssert(self, @"Super init cannot be nil");
  _name = name;
  _messenger = messenger;
  _codec = codec;
  return self;
}

- (void)setStreamHandlerFactory:(NSObject<FlutterStreamHandler> *(^)(id))factory {
  if (!factory) {
    [_messenger setMessageHandlerOnChannel:_name binaryMessageHandler:nil];
    return;
  }
  
  __block NSMutableDictionary *streams = [NSMutableDictionary new];
  FlutterBinaryMessageHandler messageHandler = ^(NSData* message, FlutterBinaryReply callback) {
    FlutterMethodCall* call = [self->_codec decodeMethodCall:message];
    NSArray *methodParts = [call.method componentsSeparatedByString:@"#"];
    
    if (methodParts.count != 2) {
      callback(nil);
      return;
    }
    
    NSInteger keyValue = [methodParts.lastObject integerValue];
    if(keyValue == 0) {
      callback([self->_codec encodeErrorEnvelope:[FlutterError errorWithCode:@"error" message:[NSString stringWithFormat:@"Invalid method name: %@", call.method] details:nil]]);
      return;
    }
    
    NSNumber *key = [NSNumber numberWithInteger:keyValue];
    
    if ([methodParts.firstObject isEqualToString:@"listen"]) {
      [self listenForCall:call withStreams:streams key:key usingCallback:callback andFactory:factory];
    } else if ([methodParts.firstObject isEqualToString:@"cancel"]) {
      [self cancelForCall:call withStreams:streams key:key usingCallback:callback andFactory:factory];
    } else {
      callback(nil);
    }
  };
  
  [_messenger setMessageHandlerOnChannel:_name binaryMessageHandler:messageHandler];
}
  
  - (void)listenForCall:(FlutterMethodCall*)call withStreams:(NSMutableDictionary*)streams key:(NSNumber*)key usingCallback:(FlutterBinaryReply)callback andFactory:(NSObject<FlutterStreamHandler> *(^)(id))factory {
  AdharaSocketIoFlutterStreamsChannelStream *stream = [streams objectForKey:key];
  if(stream) {
    FlutterError* error = [stream.handler onCancelWithArguments:nil];
    if (error) {
      NSLog(@"Failed to cancel existing stream: %@. %@ (%@)", error.code, error.message,
            error.details);
    }
  }
  
  stream = [AdharaSocketIoFlutterStreamsChannelStream new];
  stream.sink = ^(id event) {
    NSString *name = [NSString stringWithFormat:@"%@#%@", self->_name, key];
    
    if (event == FlutterEndOfEventStream) {
      [self->_messenger sendOnChannel:name message:nil];
    } else if ([event isKindOfClass:[FlutterError class]]) {
      [self->_messenger sendOnChannel:name
                              message:[self->_codec encodeErrorEnvelope:(FlutterError*)event]];
    } else {
      [self->_messenger sendOnChannel:name message:[self->_codec encodeSuccessEnvelope:event]];
    }
  };
  stream.handler = factory(call.arguments);
  
  [streams setObject:stream forKey:key];
  
  FlutterError* error = [stream.handler onListenWithArguments:call.arguments eventSink:stream.sink];
  if (error) {
    callback([self->_codec encodeErrorEnvelope:error]);
  } else {
    callback([self->_codec encodeSuccessEnvelope:nil]);
  }
}
  
- (void)cancelForCall:(FlutterMethodCall*)call withStreams:(NSMutableDictionary*)streams key:(NSNumber*)key usingCallback:(FlutterBinaryReply)callback andFactory:(NSObject<FlutterStreamHandler> *(^)(id))factory {
  AdharaSocketIoFlutterStreamsChannelStream *stream = [streams objectForKey:key];
  if(!stream) {
    callback([self->_codec encodeErrorEnvelope:[FlutterError errorWithCode:@"error" message:@"No active stream to cancel" details:nil]]);
    return;
  }
  
  [streams removeObjectForKey:key];
  
  FlutterError* error = [stream.handler onCancelWithArguments:call.arguments];
  if (error) {
    callback([self->_codec encodeErrorEnvelope:error]);
  } else {
    callback([self->_codec encodeSuccessEnvelope:nil]);
  }
}

@end
