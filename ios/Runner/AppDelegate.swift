import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    Thread.sleep(forTimeInterval: 2.0)
    GMSServices.setMetalRendererEnabled(true)
    GMSServices.provideAPIKey("AIzaSyDIBovNEZWIZSPVyRmzmBaCsInU8YgQPHc")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
