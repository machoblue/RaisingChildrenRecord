//
//  AppDelegate.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import Firebase

import RealmSwift

import Shared

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var babyDao: BabyDao?
    
    var recordDao: RecordDao?
    var recordDaoRemote: RecordDao?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("*** AppDelegate.application.didFinishLaunchingWithOptoins ***")

        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-2062076007725970~5164800220")
        
        if Auth.auth().currentUser == nil {
            if UserDefaults.standard.object(forKey: UserDefaults.Keys.IsSignInSkipped.rawValue) as? Bool ?? false { // Once skipped, never show signInScreen
                // do nothing
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let signInViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                signInViewController.onSignedIn = { result in
                    FirebaseUtils.shared.observeRemote()
                    
                    let viewController = storyboard.instantiateViewController(withIdentifier: "UITabBarController")
                    self.window?.rootViewController = viewController
                    self.window?.makeKeyAndVisible()
                }
                signInViewController.onSkipped = { result in
                    let viewController = storyboard.instantiateViewController(withIdentifier: "UITabBarController")
                    self.window?.rootViewController = viewController
                    self.window?.makeKeyAndVisible()
                }
                
                self.window?.rootViewController = signInViewController
                self.window?.makeKeyAndVisible()
            }
            
        } else {
            FirebaseUtils.shared.observeRemote()
        }
        
        self.babyDao = BabyDaoFactory.shared.createBabyDao(.Local)
        let babies = self.babyDao?.findAll()
        if (babies?.count == 0) {
            babyDao?.insertOrUpdate(BabyModel(id: UUID().description, name: "赤ちゃん", born: Date(), female: false))
        }
        
        self.recordDao = RecordDaoFactory.shared.createRecordDao(.Local)
        self.recordDaoRemote = RecordDaoFactory.shared.createRecordDao(.Remote)
        
        restoreRecords() // To receive records from IntentHandler

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
        print("*** AppDelegate.applicationWillEnterForeground ***")
        restoreRecords() // To receive records from IntentHandler
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    // MARK: - Utility
    func restoreRecords() {
        let recordDataManager = RecordDataManager()
        let records = recordDataManager.records
        for record in records {
            recordDao?.insertOrUpdate(record)
            recordDaoRemote?.insertOrUpdate(record)
        }
        
        recordDataManager.clear()
    }
    
}

