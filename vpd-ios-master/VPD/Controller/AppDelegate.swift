//
//  AppDelegate.swift
//  VPD
//
//  Created by Ikenna Udokporo on 06/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

//#import "AppDelegate.h"

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import Intercom


var notification_count = 0
var notification_array = [String]()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    
    let navigator = Navigator()
    
    
    var gcmMessageIDKey = "gcm.message_id"
    
    var deviceTokenString  = 0
   

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        

        Intercom.setApiKey("ios_sdk-03803a8c1193eea09ca8f7e8bb25f9a3347896dc", forAppId: "lsua7nw6")
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()
        
        return true
    }
    
      
      
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        
          guard let url = userActivity.webpageURL else {return false}

          guard let viewController = navigator.getDestination(for: url) else {

              application.open(url)

              return false
          }

          window?.rootViewController = viewController

          window?.makeKeyAndVisible()

          return true
      }
    
    
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
  
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //deviceTokenString = deviceToken.count

        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            let refreshedToken = result.token
            UserDefaults.standard.set(refreshedToken, forKey: "Device_id")
            UserDefaults.standard.synchronize()
            print("Remote instance ID token: \(refreshedToken)")
          }
        }
    
    }

    

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        #if DEBUG
            print(userInfo)
        #endif
        
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)
        
      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }


      completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate :  MessagingDelegate {
 
    
    //MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token>>>....................................................: \(fcmToken)")
        
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
     
    }
    
    
}


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }


    // Change this to your preferred presentation option
    completionHandler([.alert, .sound, .badge])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
   
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    completionHandler()
  }
}









