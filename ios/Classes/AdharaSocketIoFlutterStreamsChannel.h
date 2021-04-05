//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//
//  Original work on StreamsChannel by loup-v
//  at https://github.com/loup-v/streams_channel
//  Had to copy the file and rename classes due to some XCode errors >_<

#import <Flutter/Flutter.h>

//typedef FlutterMessageHandler (^FlutterStreamsHandlerFactory)();

@interface AdharaSocketIoFlutterStreamsChannel : NSObject

+ (nonnull instancetype)streamsChannelWithName:(NSString* _Nonnull)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger;

+ (nonnull instancetype)streamsChannelWithName:(NSString* _Nonnull)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                               codec:(NSObject<FlutterMethodCodec>* _Nonnull)codec;

- (nonnull instancetype)initWithName:(NSString* _Nonnull)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger
                       codec:(NSObject<FlutterMethodCodec>* _Nonnull)codec;

- (void)setStreamHandlerFactory:(NSObject<FlutterStreamHandler>* _Nullable (^ _Nonnull)(id _Nonnull))factory;

@end

