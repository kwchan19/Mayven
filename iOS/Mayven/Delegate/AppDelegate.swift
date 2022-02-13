//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-24.
//

import UIKit
import CoreData
import Firebase
import UserNotifications
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import SDWebImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var name: String?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        Messaging.messaging().delegate = self
        
        SDImageCache.shared.config.maxDiskSize = 1000000 * 100 // 20 MB

        // Setting memory cache
        SDImageCache.shared.config.maxMemoryCost = 30 * 1024 * 1024
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true

        let db = Firestore.firestore()
        db.settings = settings

        requestPermission()
        
        userData = retrieveUserData()
        
        
        if(userData.isEmpty) {
            firebaseLogout()
        }

//        GADMobileAds.configure(withApplicationID: "ca-app-pub-3819604632178532~1647369766")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
     //   GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "9a4e31b32d4d07d1b995c8fc5c78ee1f" ]; // Sample device ID*/
    //
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

        application.registerForRemoteNotifications()
        
        let user = Auth.auth().currentUser
        if user?.uid == nil || user?.isEmailVerified == false {
        //Show Login Screen
            let mainTabBarController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
            
            window?.rootViewController = mainTabBarController
        }
        else {
        //Show content
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            
            window?.rootViewController = mainTabBarController
        }

        return true
    }
    

    // MARK: UISceneSession Lifecycle

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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        //UIApplication.shared.applicationIconBadgeNumber += 1
        
        // A. get the dict info from the notification
      /*  let userInfo = notification.request.content.userInfo

        // B. safely unwrap it
        guard let userInfoDict = userInfo as? [String: Any] else { return }

        // C. in this example a message notification came through. At this point I'm not doing anything with the message, I just want to make sure that it exists
        guard let _ = userInfoDict["message"] as? String else { return }

        // D. access the "badgeCount" from UserDefaults that you registered in step 1 above
        if var badgeCount = UserDefaults.standard.value(forKey: "badgeCount") as? Int {

            // E. increase the badgeCount by 1 since one notification came through
            badgeCount += 1

            // F. update UserDefaults with the updated badgeCount
            UserDefaults.standard.setValue(badgeCount, forKey: "badgeCount")

            // G. update the application with the current badgeCount so that it will appear on the app icon
            UIApplication.shared.applicationIconBadgeNumber = badgeCount
        }
        */
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
        
    //    UIApplication.shared.applicationIconBadgeNumber += 1

        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                       fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }
        
        let state = application.applicationState
            switch state {
                
            case .inactive:
                print("Inactive")
                
            case .background:
                print("Background")
                // update badge count here
                application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
                
            case .active:
                print("Active")

            }

        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }
      // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

      // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
      // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
      // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")

        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ChatApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            }
            catch let error as NSError {
                print("Error: \(error), \(error.userInfo)")
            }
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    print(userInfo)

    completionHandler()
  }
}

extension AppDelegate : MessagingDelegate {
  // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
     //   print("Firebase registration token: \(String(describing: fcmToken))")
        
            let dataDict:[String: String] = ["token": fcmToken ]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
  }
  // [END refresh_token]
}

func requestPermission() {
    if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                // Tracking authorization dialog was shown
                // and we are authorized
                print("Authorized")
                
                // Now that we are authorized we can get the IDFA
            case .denied:
                // Tracking authorization dialog was
                // shown and permission is denied
                print("Denied")
            case .notDetermined:
                // Tracking authorization dialog has not been shown
                print("Not Determined")
            case .restricted:
                print("Restricted")
            @unknown default:
                print("Unknown")
            }
        }
    }
}
