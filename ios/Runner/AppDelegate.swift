import UIKit
import Flutter
import Firebase
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    registerForPushNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
   override func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
    }

   override func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Failed to register: \(error)")
    }

    func registerForPushNotifications() {
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current()
                  .requestAuthorization(options: [.alert, .sound, .badge]) {
                    [weak self] granted, error in
                    guard let self = self else { return }
                    print("Permission granted: \(granted)")
                    
                    guard granted else { return }
                    self.getNotificationSettings()
                }
            } else {
                // Fallback on earlier versions
            }
    }
    
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
               print("Notification settings: \(settings)")
               guard settings.authorizationStatus == .authorized else { return }
               DispatchQueue.main.async {
                 UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback on earlier versions
        }
     }
    
}
