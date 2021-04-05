import Flutter
import UIKit
import SocketIO


public class AdharaSocketIoStreamHandler: NSObject, FlutterStreamHandler {
    
    var adharaSocket: AdharaSocket?
    var eventName: String?
    var stopListening = false
    let plugin: SwiftAdharaSocketIoPlugin
    var listenerId: UUID?;
    
    init(_ _plugin: SwiftAdharaSocketIoPlugin){
        plugin = _plugin
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        let args = arguments as! [String: AnyObject]
        let socketIndex = args["id"] as! Int
        eventName = (args["eventName"] as! String)
        let _eventName = eventName ?? ""
        if (plugin.instances[socketIndex] != nil) {
            adharaSocket = plugin.instances[socketIndex]
            adharaSocket?.log("registering listener for event", _eventName)
            listenerId = (adharaSocket?.socket.on(_eventName) {data, ack in
                self.adharaSocket?.log("incoming message", _eventName, data, ack)
                events(data);
            })!
        } else {
            events(FlutterError(code: "403", message: "Instance not found", details: nil)) // in case of errors
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        adharaSocket?.log("Cancelling listener for", eventName ?? "-")
        adharaSocket?.socket.off(id: listenerId!)
        return nil
    }
}
