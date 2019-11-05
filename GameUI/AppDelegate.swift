//
//  AppDelegate.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import UIKit
import Foundation
import MetricKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate
{
    /// The main UIWindow.
    var window: UIWindow?
    
    var StartupShortcut: UIApplicationShortcutItem? = nil
    
    /// Application launch tasks. Capture launch tasks from the home screen menu.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        print("Fouris launched: \(MessageHelper.MakeTimeStamp(FromDate: Date()))")
        
        //Set the running environment.
        #if targetEnvironment(simulator)
        UserDefaults.standard.set(true, forKey: "RunningOnSimulator")
        print("Running on simulator.")
        #else
        #if targetEnvironment(macCatalyst)
        UserDefaults.standard.set(false, forKey: "RunningOnSimulator")
        print("Running on Mac.")
        #else
        UserDefaults.standard.set(false, forKey: "RunningOnSimulator")
        print("Running on iOS.")
        #endif
        #endif
        #if RELEASE
        print("Release version.")
        Versioning.IsReleaseBuild = true
        #endif
        #if DEBUG
        print("Debug version.")
        Versioning.IsReleaseBuild = false
        #endif
        
        UIApplication.shared.isIdleTimerDisabled = true
        if let ShortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem
        {
            StartupShortcut = ShortcutItem
        }
        MXMetricManager.shared.add(self)
        return true
    }
    
    /// Alternatively, a shortcut item may be passed in through this delegate method if the app was
    /// still in memory when the Home screen quick action was used. Again, store it for processing.
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    {
        StartupShortcut = shortcutItem
    }
    
    /// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions
    /// (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    /// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    func applicationWillResignActive(_ application: UIApplication)
    {
        if let GameView = self.window?.rootViewController as? MainViewController
        {
            if !GameView.MakingVideo
            {
                GameView.ForcePause()
            }
        }
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "AppDelegate", KVPs: [("Message","Fouris resigned active.")], LogFileName: &NotUsed)
        let _ = ActivityLog.SaveLog()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    /// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your
    /// application to its current state in case it is terminated later. If your application supports background execution, this method is called
    /// instead of applicationWillTerminate: when the user quits.
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "AppDelegate", KVPs: [("Message","Fouris entered background.")], LogFileName: &NotUsed)
        let _ = ActivityLog.SaveLog()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    /// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    func applicationWillEnterForeground(_ application: UIApplication)
    {
        UIApplication.shared.isIdleTimerDisabled = true
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "AppDelegate", KVPs: [("Message","Fouris entered background.")], LogFileName: &NotUsed)
    }
    
    /// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background,
    /// optionally refresh the user interface. Process any short cut commands.
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        if let ShortcutItem = StartupShortcut
        {
            print("Encountered short cut item \(ShortcutItem.type)")
            let Message = "\(ShortcutItem.type) triggered."
            let Alert = UIAlertController(title: "Quick Action", message: Message, preferredStyle: .alert)
            Alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            window?.rootViewController?.present(Alert, animated: true, completion: nil)
            StartupShortcut = nil
        }
        UIApplication.shared.isIdleTimerDisabled = true
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "AppDelegate", KVPs: [("Message","Fouris became active.")], LogFileName: &NotUsed)
    }
    
    /// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    func applicationWillTerminate(_ application: UIApplication)
    {
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "AppDelegate", KVPs: [("Message","Fouris terminated.")], LogFileName: &NotUsed)
        let _ = ActivityLog.SaveLog()
        UIApplication.shared.isIdleTimerDisabled = false
        MXMetricManager.shared.remove(self)
    }
}

extension AppDelegate: MXMetricManagerSubscriber
{
    /// Handle received metrics payloads. Not currently implemented.
    public func didReceive(_ payloads: [MXMetricPayload])
    {
        #if false
        for Payload in payloads
        {
            let url = URL(string: "")!
            var Request = URLRequest(url: url)
            Request.httpMethod = "POST"
            Request.httpBody = Payload.jsonRepresentation()
            let Task = URLSession.shared.dataTask(with: Request)
            Task.priority = URLSessionTask.lowPriority
            Task.resume()
        }
        #endif
    }
}

/// Host platforms where Fouris may find itself running.
enum HostPlatforms: String, CaseIterable
{
    /// Running on a Mac under Catalyst.
    case Catalyst = "Catalyst"
    /// Running on an iOS/iPadOS device.
    case iOS = "iOS"
    /// Running on a simulator.
    case Simulator = "Simulator"
}
