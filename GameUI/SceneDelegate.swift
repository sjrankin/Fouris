//
//  SceneDelegate.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import UIKit

/// Handles window-scoped lifecycle events (replaces the pre-scene `UIApplicationDelegate` callbacks).
class SceneDelegate: UIResponder, UIWindowSceneDelegate
{
    /// The window created from the main storyboard named in Info.plist.
    var window: UIWindow?
    
    /// Home screen quick action waiting to be shown when the scene becomes active.
    var StartupShortcut: UIApplicationShortcutItem? = nil
    
    /// Called when the scene is created. Captures any quick action used to launch the app.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        StartupShortcut = connectionOptions.shortcutItem
    }
    
    /// A quick action may arrive here if the app was still in memory. Store it for processing.
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void)
    {
        StartupShortcut = shortcutItem
        completionHandler(true)
    }
    
    /// The scene is about to become inactive. Games should pause here.
    func sceneWillResignActive(_ scene: UIScene)
    {
        if let GameView = window?.rootViewController as? MainViewController
        {
            if !GameView.MakingVideo
            {
                GameView.ForcePause()
            }
        }
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "SceneDelegate", KVPs: [("Message","Fouris resigned active.")], LogFileName: &NotUsed)
        let _ = ActivityLog.SaveLog()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    /// The scene moved to the background. Save the activity log.
    func sceneDidEnterBackground(_ scene: UIScene)
    {
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "SceneDelegate", KVPs: [("Message","Fouris entered background.")], LogFileName: &NotUsed)
        let _ = ActivityLog.SaveLog()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    /// The scene is returning from the background.
    func sceneWillEnterForeground(_ scene: UIScene)
    {
        UIApplication.shared.isIdleTimerDisabled = true
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "System", Source: "SceneDelegate", KVPs: [("Message","Fouris entered foreground.")], LogFileName: &NotUsed)
    }
    
    /// The scene is active. Process any pending quick action.
    func sceneDidBecomeActive(_ scene: UIScene)
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
        ActivityLog.AddEntry(Title: "System", Source: "SceneDelegate", KVPs: [("Message","Fouris became active.")], LogFileName: &NotUsed)
    }
}
