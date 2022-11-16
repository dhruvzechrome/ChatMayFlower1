//
//  AppDelegate.swift
//  ChatMayFlower
//
//  Created by iMac on 13/10/22.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
          
        
          return Auth.auth().canHandle(url)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
//          UNUserNotificationCenter.current().delegate = self
//
//          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//          UNUserNotificationCenter.current().requestAuthorization(
//            options: authOptions,
//            completionHandler: { _, _ in }
//          )
//        } else {
//          let settings: UIUserNotificationSettings =
//            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//          application.registerUserNotificationSettings(settings)
//        }
//
//        application.registerForRemoteNotifications()
//        Messaging.messaging().delegate = self

        FirebaseApp.configure()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
     

      return UIBackgroundFetchResult.newData
    }


}
//extension AppDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//      print("Firebase registration token: \(String(describing: fcmToken))")
//
//      let dataDict: [String: String] = ["token": fcmToken ?? ""]
//      NotificationCenter.default.post(
//        name: Notification.Name("FCMToken"),
//        object: nil,
//        userInfo: dataDict
//      )
//      // TODO: If necessary send token to application server.
//      // Note: This callback is fired at each app startup and whenever a new token is generated.
//    }
//
//}
//
//
//extension AppDelegate: UNUserNotificationCenterDelegate {
//  // Receive displayed notifications for iOS 10 devices.
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//      let userInfo = notification.request.content.userInfo
//
//      Messaging.messaging().appDidReceiveMessage(userInfo)
//
//      // Change this to your preferred presentation option
//      completionHandler([[.alert, .sound]])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//      let userInfo = response.notification.request.content.userInfo
//
//      Messaging.messaging().appDidReceiveMessage(userInfo)
//
//      completionHandler()
//    }
//}
//
@IBDesignable extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
              layer.cornerRadius = newValue
              layer.masksToBounds = (newValue > 0)
        }
    }
}
//Border
@IBDesignable extension UIView {
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
        set { layer.borderColor = newValue?.cgColor }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}

class PaddingLabel: UILabel {
    
    var inset = UIEdgeInsets.zero
    
    /// Добавляет отступы
    func padding(_ top: CGFloat, _ bottom: CGFloat, _ left: CGFloat, _ right: CGFloat) {
        self.frame = CGRect(x: 0, y: 0, width: self.frame.width + left + right, height: self.frame.height + top + bottom)
        inset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += inset.top + inset.bottom
            contentSize.width += inset.left + inset.right
            return contentSize
        }
    }
}
