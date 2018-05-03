//
//  AppDelegate.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 16/05/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isDeletedSession:Bool = false
    var isUpdatedSession:Bool = false
    
    var isDeleteODIMatch:Bool = false
    var isUpdateODIMatch:Bool = false
    
    var isDeleteTestMatch:Bool = false
    var isUpdateTestMatch:Bool = false
    var isFullVersion:Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        FIRApp.configure()
        IQKeyboardManager.sharedManager().enable = true
         Util.copyFile("CKTDB.sqlite")
       print(Util.getPath("CKTDB.sqlite"))
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8789417071125074~1904335854")

        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
 
        
        if !(UserDefaults.standard.bool(forKey: kFIRSTLAUNCH)){
        
            UserDefaults.standard.set("SRI", forKey: kUSERNAME)
            UserDefaults.standard.synchronize()
                       
            
            for i in 0..<2
            {
                let objBookie = Bookie()
                
                if i == 0{
                    objBookie.bookieName = "SELF"
                }
                else
                {
                    objBookie.bookieName = "SRI"
                }
                
                objBookie.bookieDate = Util.stringFromDate(Date())
                
                
                objBookie.bookiePhone = ""
                objBookie.bookieEmail = ""
                objBookie.city = ""
                objBookie.sessionCommission = 0.0
                objBookie.ODICommission = 0.0
                objBookie.testCommission = 0.0
                
                let isInserted = ModelManager.getInstance().addBookieData(objBookie)
                if isInserted {
                print(isInserted)
                
                }

            }
            UserDefaults.standard.set(true, forKey: kFIRSTLAUNCH)
        }
           
        
        let tabbarController = self.window?.rootViewController as! UITabBarController
        
        let storyBoardMatch:UIStoryboard = UIStoryboard(name: "Match", bundle: nil)
        
        let storyBoardSession:UIStoryboard = UIStoryboard(name: "Session", bundle: nil)
        
        let storyBoardReport:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
        
        let storyBoardSettings:UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        
        let storyBoardMain:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let navControlMatch = storyBoardMatch.instantiateInitialViewController() as! UINavigationController
        
        let navControlSession = storyBoardSession.instantiateInitialViewController() as! UINavigationController
        
        let navControlReport = storyBoardReport.instantiateInitialViewController() as! UINavigationController
        
       let navControlSettings = storyBoardSettings.instantiateInitialViewController() as! UINavigationController
        
        
        UIApplication.shared.statusBarStyle = .lightContent

        navControlSession.viewControllers = [storyBoardMain.instantiateViewController(withIdentifier: "SessionListViewController") as! SessionListViewController]
        navControlSession.accessibilityLabel = "2"
        
        tabbarController.addChildViewController(navControlMatch);
        tabbarController.addChildViewController(navControlSession);
        tabbarController.addChildViewController(navControlReport);
        tabbarController.addChildViewController(navControlSettings);
        
        tabbarController.tabBar.barTintColor = Util.setTabBarColor()
        
        Util.setAllNavigationBarColor(tabbarController)
        
        
        Util.setFontAndColorOnTabBar()
        
        
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Normal)
//        
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Util.setNavigationBarColor()], forState:.Selected)
        
        //        let arrBookieList = ModelManager.getInstance().getAllBookieData()
        //        let tabbarController = self.window?.rootViewController as! UITabBarController
        //
        //        if arrBookieList.count == 0 {
        //
        //            tabbarController.selectedIndex = 3
        //        }
        //        else
        //        {
        tabbarController.selectedIndex = 0
        //        }
        
//                self.printFonts()
        return true
    }

    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName )
            print("Font Names = [\(names)]")
        }
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("DEVICE TOKEN = \(deviceToken)")
    }
    
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

