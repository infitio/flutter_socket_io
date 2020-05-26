import UIKit
import Flutter
import adhara_socket_io

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    AdharaSocketIoPlugin.register(with: self.registrar(forPlugin: "AdharaSocketIoPlugin") )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
