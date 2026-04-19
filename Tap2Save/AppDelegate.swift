//
//  AppDelegate.swift
//  Tap2Save
//
//  Created by Phelippe Duarte on 18/3/2026.
//

import UIKit
import FirebaseCore
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var authHandle: AuthStateDidChangeListenerHandle?

    // Configures Firebase at launch and tracks whether a user is logged in.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        authHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let userID = user.uid
                print("User logged in: \(userID)")
            } else {
                print("No user logged in")
            }
            
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    // Returns the scene configuration used when iOS creates a new app window.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // Handles any cleanup needed after scene sessions are discarded.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
