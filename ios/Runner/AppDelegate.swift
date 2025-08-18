import Flutter
import UIKit
import Firebase
import GoogleMaps
import Intercom


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()

    // Provide your Google Maps API Key
    GMSServices.provideAPIKey("AIzaSyC6GK6c5IMopZIMo_F1btLZgYY4HTIuPLg")
    
    // Initialize Intercom
    Intercom.setApiKey("ios_sdk-9dd934131d451492917c16a61a9ec34824400eee", forAppId: "j3he2pue")
    Intercom.setLauncherVisible(true)
    // If you have identifying information for your user you can use `Intercom.loginUser(with:completion:)`
    Intercom.loginUnidentifiedUser()
    
    GeneratedPluginRegistrant.register(with: self)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
