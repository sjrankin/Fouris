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

@main class AppDelegate: UIResponder, UIApplicationDelegate
{
    /// Application launch tasks.
    /// - Note: Window-related lifecycle events and Home screen quick actions are handled by `SceneDelegate`.
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
        MXMetricManager.shared.add(self)
        return true
    }
    
    /// Called when a new scene session is being created. Uses the configuration in Info.plist.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration
    {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    /// Called when the application is about to terminate. Save data if appropriate.
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
    nonisolated public func didReceive(_ payloads: [MXMetricPayload])
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
