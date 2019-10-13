//
//  AppDelegate.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        #if targetEnvironment(simulator)
        UserDefaults.standard.set(true, forKey: "RunningOnSimulator")
        #else
        UserDefaults.standard.set(false, forKey: "RunningOnSimulator")
        #endif
        print("Fouris launched: \(MessageHelper.MakeTimeStamp(FromDate: Date()))")
        if UserDefaults.standard.bool(forKey: "RunningOnSimulator")
        {
            print("Running on simulator.")
        }
        UIApplication.shared.isIdleTimerDisabled = true
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if let GameView = self.window?.rootViewController as? MainViewController
        {
            if !GameView.MakingVideo
            {
                GameView.ForcePause()
            }
        }
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "AppDelegate", KVPs: [("Message","Fouris resigned active.")], LogFileName: &NotUsed)
        ActivityLog.SaveLog()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "AppDelegate", KVPs: [("Message","Fouris entered background.")], LogFileName: &NotUsed)
        ActivityLog.SaveLog()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.isIdleTimerDisabled = true
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "AppDelegate", KVPs: [("Message","Fouris entered background.")], LogFileName: &NotUsed)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.isIdleTimerDisabled = true
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "AppDelegate", KVPs: [("Message","Fouris became active.")], LogFileName: &NotUsed)
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "AppDelegate", KVPs: [("Message","Fouris terminated.")], LogFileName: &NotUsed)
        ActivityLog.SaveLog()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

