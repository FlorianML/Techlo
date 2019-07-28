//
//  AppDelegate.swift
//  Techlo
//
//  Created by Florian on 11/6/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import NotificationBannerSwift
import IQKeyboardManagerSwift
import GooglePlaces
import Stripe
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let googlePlacesAPIKey = "YOUR_API_KEY"
    let stripeKey = "YOUR_API_KEY"
    var fcmToken: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        GMSPlacesClient.provideAPIKey(googlePlacesAPIKey)

        STPPaymentConfiguration.shared().publishableKey = stripeKey
        
        attemptRegisteringForNotifications(application: application)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = ColorModel.returnWhite()
        window?.layer.backgroundColor = ColorModel.returnWhite().cgColor
        
        let navController = UINavigationController(rootViewController: StartupController()) 
        navController.navigationBar.tintColor = ColorModel.returnNavyDark()
        window?.rootViewController = navController
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        self.fcmToken = fcmToken
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        handleUserInfo(userInfo: userInfo)
    }
    
    private func attemptRegisteringForNotifications(application: UIApplication) {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if let err = error {
                print("Failed to request auth: ", err)
                return
            }
            
            if granted {
                print("Auth granted")
                UserDefaults.standard.set(true, forKey: "notif")
            } else {
                print("Auth denied")
            }
        }
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let stripeHandled = Stripe.handleURLCallback(with: url)
        
        if (stripeHandled) {
            return true
        }
        else {
            let FBCheck = FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
            
            let googleCheck = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,annotation: [:])
            
            switch (FBCheck, googleCheck) {
            case (true, true):
                print("can open both facebook and google URLs")
                return true
            case (false, true):
                print("can open google but not facebook URLs")
                return true
            case (true, false):
                print("can open facebook but cannot open google URLs")
                return true
            default:
                print("Cannot open facebook or google URLs")
                return false
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        UIApplication.shared.applicationIconBadgeNumber = 0
//        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
//            rootViewController.popToRootViewController(animated: true)
//        }
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
        UIApplication.shared.applicationIconBadgeNumber = 0
//        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
//            rootViewController.popToRootViewController(animated: true)
//        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func revealErrorAlert(title: String, subtitle: String) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .danger)
        banner.duration = 4.0
        banner.show()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let stripeHandled = Stripe.handleURLCallback(with: url)
                
                if (stripeHandled) {
                    return true
                }
                else {
                    // This was not a stripe url, do whatever url handling your app
                    // normally does, if any.
                }
            }
            
        }
        return false
    }
    
    func handleUserInfo(userInfo: [AnyHashable: Any]) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("userInfo: ", userInfo)

        if let appointmentId = userInfo["appointmentId"] as? String, let uid = userInfo["userId"] as? String {
            let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(appointmentId)
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let appointment = Appointment(dictionary: dictionary)
                
                let appointmentDetailsController = AppointmentDetailsController()
                appointmentDetailsController.appointment = appointment
                self.presentViewControllerFromAppDelegate(controller: appointmentDetailsController)
            }
            
        } else if let noteId = userInfo["noteId"] as? String, let uid = userInfo["userId"] as? String {
            let ref = Database.database().reference().child(FirebaseKey.note.rawValue).child(uid).child(noteId)
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let note = Note(dictionary: dictionary)
                
                let noteController = FullNoteController()
                noteController.note = note
                self.presentViewControllerFromAppDelegate(controller: noteController)
            }
        
        } else if let chargeResponseStatus = userInfo["response"] as? String {
            print("GOT THE CHARGE RESPONSE")
            if chargeResponseStatus == "succeeded" {
                print("CHARGE SUCCEEDED")
            } else {
                print("CHARGE DID NOT SUCCEED: ", chargeResponseStatus)
            }

        }
    }
    
    func presentViewControllerFromAppDelegate(controller: UIViewController) {
        if let navController = window?.rootViewController as? UINavigationController {
            navController.pushViewController(controller, animated: true)
        }
    }

}

