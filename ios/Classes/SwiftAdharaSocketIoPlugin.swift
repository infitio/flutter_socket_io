import Flutter
import UIKit
import SocketIO


public class SwiftAdharaSocketIoPlugin: NSObject, FlutterPlugin {

    var instances: [Int: AdharaSocket];
    var currentIndex: Int;
    let registrar: FlutterPluginRegistrar;

    init(_ _registrar: FlutterPluginRegistrar){
        registrar = _registrar
        instances = [Int: AdharaSocket]()
        currentIndex = 0;
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "adhara_socket_io", binaryMessenger: registrar.messenger())
        let instance = SwiftAdharaSocketIoPlugin(registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
                
        let streamsChannel = AdharaSocketIoFlutterStreamsChannel(name: "adhara_socket_io:event_streams", binaryMessenger: registrar.messenger())
        streamsChannel.setStreamHandlerFactory { (Any) -> (FlutterStreamHandler & NSObjectProtocol)? in
            return AdharaSocketIoStreamHandler(instance)
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as! [String: AnyObject]

        switch (call.method) {
            case "newInstance":
                if((arguments["clear"] as! Bool?)!){
                    for (_, adharaSocket) in instances {
                        adharaSocket.socket.disconnect()
                    }
                    instances.removeAll()
                }
                let options: AnyObject = arguments["options"] as AnyObject
                let config:AdharaSocketIOClientConfig
                    = AdharaSocketIOClientConfig(currentIndex, uri: options["uri"] as! String,
                                                 namespace: options["namespace"] as! String, path: options["path"] as! String)
                if let query: [String:String] = options["query"] as? [String:String]{
                    config.query = query
                }
                if let enableLogging: Bool = options["enableLogging"] as? Bool {
                    config.enableLogging = enableLogging
                }
                instances[currentIndex] = AdharaSocket.getInstance(registrar, config)
                result(currentIndex)
                currentIndex += 1
            case "clearInstance":
                if(arguments["id"] == nil){
                    result(FlutterError(code: "400", message: "Invalid instance identifier provided", details: nil))
                }else{
                    let socketIndex = arguments["id"] as! Int
                    if (instances[socketIndex] != nil) {
                        if((arguments["clear"] as! Bool?)!){
                            for (_, adharaSocket) in instances {
                                adharaSocket.socket.disconnect()
                            }
                            instances.removeAll()
                        }else{
                            instances[socketIndex]?.socket.disconnect()
                            instances[socketIndex] = nil
                        }
                        result(nil)
                    } else {
                        result(FlutterError(code: "403", message: "Instance not found", details: nil))
                    }
                }
            default:
                result(FlutterError(code: "404", message: "No such method", details: nil))
        }
    }

}
