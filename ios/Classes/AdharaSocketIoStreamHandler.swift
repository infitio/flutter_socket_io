import Flutter
import UIKit
import SocketIO


public class AdharaSocketIoStreamHandler: NSObject, FlutterStreamHandler {
    
    var adharaSocket: AdharaSocket?
    var eventName: String?
    var stopListening = false
    let plugin: SwiftAdharaSocketIoPlugin
    
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
            adharaSocket?.socket.disconnect()
            adharaSocket?.socket.on(_eventName) {data, ack in
                self.adharaSocket?.log("incoming:::", _eventName, data, ack)
                events(data);
            }
            adharaSocket?.eventListenerCount[_eventName] = (adharaSocket?.eventListenerCount[_eventName] ?? 0) + 1
        } else {
            events(FlutterError(code: "403", message: "Instance not found", details: nil)) // in case of errors
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("eventName", eventName ?? "noevent")
        let count = adharaSocket?.eventListenerCount[eventName!] ?? 0
        if(count == 1){
            adharaSocket?.socket.off(eventName!)
        }else{
            adharaSocket?.eventListenerCount[eventName!] = count - 1
        }
        return nil
    }
}
