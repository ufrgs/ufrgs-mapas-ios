//
//  AppDelegate.swift
//  ufrgsmapas
//
//  Created by Theodoro L. Mota on 12/23/15.
//  Copyright © 2015 UFRGS. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func applicationDidFinishLaunching(_ application: UIApplication) {
    
        let key = "didShowOnboarding"
        
        // show onboarding if app is being opened for the first time

        if UserDefaults.standard.object(forKey: key) == nil {
        
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let onboarding = storyboard.instantiateViewController(withIdentifier: "onboardingController") as! OnboardingController
            
            self.window?.rootViewController = onboarding
            self.window?.makeKeyAndVisible()
            
            UserDefaults.standard.set(true, forKey: key)
        
        }
    
    }
    
}

