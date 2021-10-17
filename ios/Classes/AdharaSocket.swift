//
//  AdharaSocket.swift
//  adhara_socket_io
//
//  Created by soumya thatipamula on 19/11/18.
//
import Foundation


import Flutter
import UIKit
import SocketIO


public class AdharaSocket: NSObject, FlutterPlugin {
    
    let socket: SocketIOClient
    let channel: FlutterMethodChannel
    let manager: SocketManager
    let config: AdharaSocketIOClientConfig
    
    public func log(_ items: Any...){
        if(config.enableLogging){
            print(items)
        }
    }
    
    public init(_ channel:FlutterMethodChannel, _ config:AdharaSocketIOClientConfig) {
        manager = SocketManager(socketURL: URL(string: config.uri)!, config: [.log(true), .forceWebsockets(true), .connectParams(config.query), .path(config.path)])
        if(config.namespace == "") {
            socket = manager.defaultSocket
        } else {
            socket = manager.socket(forNamespace: config.namespace ?? "/")
        }
        self.channel = channel
        self.config = config
    }
    
    public static func getInstance(_ registrar: FlutterPluginRegistrar, _ config:AdharaSocketIOClientConfig) ->  AdharaSocket{
        let channel = FlutterMethodChannel(
            name: AdharaSocketIoMethodChannelNames.socketMethodChannel+String(config.adharaId),
            binaryMessenger: registrar.messenger()
        )
        let instance = AdharaSocket(channel, config)
        instance.log("initializing with URI", config.uri)
        registrar.addMethodCallDelegate(instance, channel: channel)
        return instance
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var arguments: [String: AnyObject]
        if(call.arguments != nil){
            arguments = call.arguments as! [String: AnyObject]
        }else{
            arguments = [String: AnyObject]()
        }
        switch call.method{
        case AdharaSocketIoPlatformMethod.connect:
            socket.connect()
            result(nil)
        case AdharaSocketIoPlatformMethod.emit:
            let eventName: String = arguments["eventName"] as! String
            let data: [Any] = arguments["arguments"] as! [Any]
            let reqId: String? = arguments["reqId"] as? String
            self.log("emitting", data, "to", eventName);
            if (reqId == nil) {
                socket.emit(eventName, with: data)
            } else {
                socket.emitWithAck(eventName, with: data).timingOut(after: 0) { data in
                    self.channel.invokeMethod(AdharaSocketIoPlatformMethod.incomingAck, arguments: [
                        "args": data,
                        "reqId": reqId as Any
                    ]);
                }
            }
            result(nil)
        case AdharaSocketIoPlatformMethod.isConnected:
            self.log("connected")
            result(socket.status == .connected)
        default:
            result(FlutterError(code: "404", message: "No such method", details: nil))
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        //        Do nothing...
    }
    
}

public class AdharaSocketIOClientConfig: NSObject{
    
    let adharaId:Int
    let uri:String
    public var namespace:String?
    public var query:[String:String]
    public var path:String
    public var enableLogging:Bool
    
    init(_ adharaId:Int, uri:String, namespace:String, path:String) {
        self.adharaId = adharaId
        self.uri = uri
        self.namespace = namespace
        self.query = [String:String]()
        self.path = path
        self.enableLogging = false
    }
    
}
