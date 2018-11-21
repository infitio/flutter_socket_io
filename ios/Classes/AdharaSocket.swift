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

    public init(_ channel:FlutterMethodChannel, _ config:AdharaSocketIOClientConfig) {
        print("initializing with URI", config.uri)
        manager = SocketManager(socketURL: URL(string: config.uri)!, config: [.log(true), .connectParams(config.query)])
        socket = manager.defaultSocket
        self.channel = channel
    }

    public static func getInstance(_ registrar: FlutterPluginRegistrar, _ config:AdharaSocketIOClientConfig) ->  AdharaSocket{
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>INDEX", config.adharaId);
        let channel = FlutterMethodChannel(name: "adhara_socket_io:socket:"+String(config.adharaId), binaryMessenger: registrar.messenger())
        let instance = AdharaSocket(channel, config)
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
//        print("arguments....................................", arguments)
        switch call.method{
            case "connect":
                socket.connect()
                result(nil)
            case "on":
                let eventName: String = arguments["eventName"] as! String
                print("---------------------registering event ...", eventName)
                socket.on(eventName) {data, ack in
                    print("incoming....", eventName, data, ack)
                    self.channel.invokeMethod("incoming", arguments: [
                        "eventName": eventName,
                        "args": data
                    ]);
                }
                result(nil)
            case "off":
                let eventName: String = arguments["eventName"] as! String
                socket.off(eventName);
                result(nil)
            case "emit":
                let eventName: String = arguments["eventName"] as! String
                let data: NSArray = arguments["arguments"] as! NSArray
                socket.emit(eventName, data)
                result(nil)
            case "isConnected":
                result(socket.status == .connected)
            case "disconnect":
                socket.disconnect()
                result(nil)
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
    public var query:[String:String]
    
    init(_ adharaId:Int, uri:String) {
        self.adharaId = adharaId
        self.uri = uri
        self.query = [String:String]()
    }
    
}
