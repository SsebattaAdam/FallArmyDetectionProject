import Flutter
import UIKit
import GoogleMaps 

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCYM0ZLSEtBvEBXXAF2ctGWBmAqnd14r0Y") // line with API key
    GeneratedPluginRegistrant.register(with: self)  
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}