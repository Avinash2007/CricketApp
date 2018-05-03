//
//  Util.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 18/05/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit

class Util: NSObject {
    
    
    
    class func getPath(_ fileName: String) -> String{
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let  fileURL = documentsURL.appendingPathComponent(fileName)
        
        return fileURL.path
        
    }
    
    class func copyFile(_ fileName: NSString){
        
        let dbPath: String = getPath(fileName as String)
        
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: dbPath) {
            
            let documentURL = Bundle.main.resourceURL
            
            let fromPath = documentURL!.appendingPathComponent(fileName as String)
            
            var error :NSError?
            
            do{
               try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            }catch let error1 as NSError{
                error = error1
            }
            
            let alert: UIAlertView = UIAlertView()
            
            if(error != nil){
                alert.title = "Error Occured"
                alert.message = error?.localizedDescription
            }
            else{
                alert.title = "Successfully Copied"
                alert.message = "Your database copy successfully"
            }
            
            alert.delegate = nil
            alert.addButton(withTitle: "Ok")
            alert.show()
        }
        
    }
    
    class func setFontOnLable(_ myView:UIView)
    {
        for view in myView.subviews as [UIView]
        {
            if let lblTemp = view as? UILabel {
                
                lblTemp.font = UIFont(name: kFONTNAMEFORLABLE, size: 17)
                lblTemp.textColor = Util.setNavigationBarColor()
            }
            
            else if let txtTemp = view as? UITextField{
                txtTemp.font = UIFont(name: kFONTNAMEFORLABLE, size: 17)
                txtTemp.textColor = Util.setNavigationBarColor()

            }
            else if let mySwitch = view as? UISwitch{
                mySwitch.onTintColor = Util.setNavigationBarColor()
            }
            else if let segment = view as? UISegmentedControl{
            
                segment.tintColor = Util.setNavigationBarColor()
                segment.backgroundColor = Util.setMainViewBGColor()
                
                let attr = NSDictionary(object: UIFont(name:kFONTBTN, size: 15.0)!, forKey: NSFontAttributeName as NSCopying)
                
                segment.setTitleTextAttributes(attr as? [AnyHashable: Any], for: UIControlState())
            }
            
        }
    }
    
    class func setCornerRadius(_ myView:UIView)
    {
        for view in myView.subviews as [UIView]
        {
            if let btnTemp = view as? UIButton {
                
                btnTemp.titleLabel!.font = UIFont(name:kFONTBTN,size: 17.0)
//                btnTemp.setTitleColor(UIColor.white, for: UIControlState())
                btnTemp.setTitleColor(self.setNavigationBarColor(), for: UIControlState())
//                btnTemp.backgroundColor = Util.setNavigationBarColor()
                btnTemp.backgroundColor = .clear
                btnTemp.layer.borderWidth = 1.0
                btnTemp.layer.borderColor = self.setNavigationBarColor().cgColor
                
                btnTemp.layer.cornerRadius = 7
                
            }
            else if let txtTemp = view as? UITextField{
                txtTemp.layer.borderWidth = 1.0
                txtTemp.layer.borderColor = self.setNavigationBarColor().cgColor
                txtTemp.layer.cornerRadius = 3.0
            }
        }
    }

    
    class func setBackgroundColor(_ tempView:UIView)
    {
        tempView.backgroundColor = Util.setMainViewBGColor()
    }
    
//    class func fireAlert(strTitle:String, strBody:String)->UIAlertController{
//        
//        let alert = UIAlertController(title: strTitle, message: strBody, preferredStyle: .alert)
//        
//        
//    }
    
    class func invokeAlertMethod(_ strTitle: NSString, strBody: NSString, delegate: AnyObject?) {
        let alert: UIAlertView = UIAlertView()
        alert.message = strBody as String
        alert.title = strTitle as String
        alert.delegate = delegate
        alert.addButton(withTitle: "Ok")
        alert.show()
    }
    
    class func stringFromDate(_ dt:Date) -> String
    {
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        
        return dateFormatter.string(from: dt)
    }
    
    class func stringFromDateWithTime(_ dt:Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        return dateFormatter.string(from: dt)
    }
    
    
    class func timeAsStringFromDate(_ dt:Date) -> String
    {
//        let dateString = "Thu, 22 Oct 2015 07:45:17 +0000"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        //        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let dateObj = dateFormatter.string(from: dt)
//        print(dateObj)

        return dateObj
    }
    
    class func setNavigationBarColor() ->UIColor{
//        return UIColor.init(red: 48.0/255.0, green: 78.0/255.0, blue: 98.0/255.0, alpha: 1.0)
        return UIColor.init(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
    }
    
    class func setNavigationTitleColor() ->UIColor{
        return UIColor.white
    }
    
    class func setNavigationFont() -> UIFont{
        return UIFont(name: "Helvetica", size: 18.0)!
    }
    
    class func setCustomNavigationMainTitleFont() -> UIFont{
        return UIFont(name: "HelveticaNeue-Medium", size: 20.0)!
    }
    
    class func setCustomNavigationSubTitleFont() -> UIFont{
        return UIFont(name: "HelveticaNeue-Medium", size: 18.0)!
    }

    
    class func setTabBarColor() -> UIColor{
//        return UIColor.init(red: 34.0/255.0, green: 96.0/255.0, blue: 114.0/255.0, alpha:1.0)
         return UIColor.init(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
    }
    
    class func setCellBackgroundColor() -> UIColor{
        //return UIColor.init(red: 125.0/255.0, green: 155.0/255.0, blue: 168.0/255.0, alpha: 1.0)
        return UIColor.init(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 0.5)
    }
    
    
    class func setColorForDisableButton() -> UIColor{
        
        return UIColor.init(red: 133.0/255.0, green: 164.0/255.0, blue: 189.0/255.0, alpha: 1.0)
    }
    
    class func setSearchBarTintColor() -> UIColor{
        return UIColor.init(red: 152.0/255.0, green: 179.0/255.0, blue: 202.0/255.0, alpha: 1.0)
    }
    
    class func setCellMainTitleTextColor() -> UIColor{
        return UIColor.white
    }
    
    class func setCellSubTitleTextColor() -> UIColor{
        return UIColor.init(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 0.9)
    }
    
    class func setMainViewBGColor() -> UIColor{
//        return UIColor.init(red: 236.0/255.0, green: 236.0/255.0, blue: 236.0/255.0, alpha: 1.0)
        return .white
    }
    
    class func setTableViewBGColor() -> UIColor{
        return self.setMainViewBGColor()
    }
    
    class func setCellMainTitleFont() -> UIFont{
        return UIFont(name: "Thonburi-Light", size: 15.0)!
    }
    
    class func setCellSubTitleFont() -> UIFont{
        return UIFont(name: "Thonburi-Light", size: 12.0)!
    }
    
    class func setLableMessageFont() -> UIFont{
        return UIFont(name: "Thonburi-Light", size: 20.0)!
    }
    
    class func setAllNavigationBarColor(_ tabBarController:UITabBarController){
        
        for navController in tabBarController.viewControllers as! [UINavigationController]{
            
            navController.navigationBar.barTintColor =  Util.setNavigationBarColor()
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                               NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!
            ]
//            navController.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Helvetica-Bold", size: 20)!]

        }
    }
    
    class func setFontAndColorOnTabBar(){
        
        let colorNormal : UIColor = UIColor.white
        let colorSelected : UIColor = UIColor.init(red: 255.0/255.0, green: 255/255.0, blue: 255.0/255.0, alpha: 0.4)

        let titleFontAll : UIFont = UIFont(name: "HelveticaNeue-Medium", size: 12.0)!
        let titleFontSelected : UIFont = UIFont(name: "HelveticaNeue-Bold", size: 12.0)!
        
        let attributesNormal = [
            NSForegroundColorAttributeName : colorNormal,
            NSFontAttributeName : titleFontAll
        ]
        
        let attributesSelected = [
            NSForegroundColorAttributeName : colorSelected,
            NSFontAttributeName : titleFontSelected
        ]
        
        UITabBarItem.appearance().setTitleTextAttributes(attributesNormal, for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes(attributesSelected, for: .selected)
    }
    
    
    
    
    class func setBarButtonFont() ->UIFont{
        return UIFont(name: "HelveticaNeue-Medium", size: 15.0)!
    }
    
    class func setLableTitleOnTableHeader(myView:UIView){
        
        for view in myView.subviews as [UIView]
        {
            if let lblTemp = view as? UILabel {
                lblTemp.textColor = setNavigationBarColor()
                lblTemp.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)!
            }
        }
    }
    
    class func getBannerAdsID()->String {
        return "ca-app-pub-8789417071125074/2590731561"
    }
    
    class func getInterstitialID()-> String {
        return "ca-app-pub-8789417071125074/2811235170"
    }
}
