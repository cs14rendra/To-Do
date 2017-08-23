//
//  AppDelegate.swift
//  Happy Days
//
//  Created by surendra kumar on 7/7/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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

    
    func scheduleNotification(at date: Date, task : String){
        let calender = Calendar(identifier: .gregorian)
        let component = calender.dateComponents(in: .current, from: date)
        let newComponent = DateComponents(calendar: calender, timeZone: .current, month: component.month, day: component.day, hour: component.hour, minute: component.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponent, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Task:"
        content.body = task
        content.categoryIdentifier = "TODO:SURI"
        content.sound = UNNotificationSound.default()
     
        
        let request = UNNotificationRequest(identifier: task, content: content, trigger: trigger)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().add(request) { error in
            print(error?.localizedDescription ??  "No error")
            
        }
        
    }


}

