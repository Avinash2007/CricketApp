//
//  SessionListViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 12/06/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class SessionListViewController: UIViewController,GADBannerViewDelegate {
    
    //MARK: User Interface
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnPlus:UIBarButtonItem!
    @IBOutlet weak var barButtonItem:UINavigationItem!
    @IBOutlet weak var lblMessage:UILabel!
    var arrSessionList = [Session]()
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    
    // MARK: View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.isFullVersion{
            // Request a Google Ad
            adBannerView.load(GADRequest())
            self.view.addSubview(adBannerView)
        }
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        self.tblView?.backgroundColor = Util.setTableViewBGColor()
        tblView?.separatorColor = Util.setTableViewBGColor()
        
        if self.navigationController?.tabBarController?.selectedIndex == 2 {
            barButtonItem.rightBarButtonItems = []
             navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(sender:)))
        }
        
        lblMessage.font = Util.setLableMessageFont()
        lblMessage.textColor = Util.setNavigationBarColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getAllActiveSessionList()
    }
    
    func share(sender:UIView){
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let textToShare = "Check out my app"
        
        if let myWebsite = URL(string: "https://itunes.apple.com/in/app/cricket-calc/id1324171518?mt=8") {//Enter link to your app here
            let objectsToShare = [textToShare, myWebsite, image ?? #imageLiteral(resourceName: "app-logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
    func showAlert(){
        
        let alert = UIAlertController(title: kAPPNAME, message: "There is no active session.Do you want to add new session?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            (action:UIAlertAction) in
            
            let storyBoardMain:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let addSessionVC = storyBoardMain.instantiateViewController(withIdentifier: "AddSessionViewController") as! AddSessionViewController
            
            addSessionVC.isPresent = 1
            
            let navController = UINavigationController.init(rootViewController: addSessionVC)
            
            navController.navigationBar.barTintColor =  Util.setNavigationBarColor()
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                               NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 20)!
            ]
            
            self.present(navController, animated:true, completion: nil)
            
            
        })
        
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        showDetailViewController(alert, sender: self)
    }
    
    func gotoSecondTab()
    {
        
        let alert = UIAlertController(title: kAPPNAME, message: "You can add soda using Session Tab.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action:UIAlertAction) in
            self.navigationController?.tabBarController?.selectedIndex = 2
            
        }))
        
        showDetailViewController(alert, sender: self)

        
    }
    
    // MARK: Database Method
    
    func getAllActiveSessionList()
    {
        arrSessionList = ModelManager.getInstance().getAllActiveSessionList("SELECT * FROM SessionTBL WHERE isActive = \(1) ORDER BY SessionID DESC")
       
        tblView.reloadData()
        
        if self.navigationController?.accessibilityLabel == "2"{
            print("2nd")
        }
        else{
            print("0th")

//            if !((UserDefaults.standard.object(forKey: "FRESHCOPY") != nil)){
//                
//                if self.arrSessionList.count == 1 {
//                    
//                    Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.gotoSecondTab), userInfo: nil, repeats: false)
//                    
//                    UserDefaults.standard.set(false, forKey: "FRESHCOPY")
//                    UserDefaults.standard.synchronize()
//
//                }
//            }
            
       }
        
        
        if self.navigationController?.accessibilityLabel == "2"
        {
            
            if arrSessionList.count == 0
            {
              //  Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.showAlert), userInfo: nil, repeats: false)
                lblMessage.text = "Add new Session from Add Info Tab"
                lblMessage.numberOfLines = 2
                lblMessage.isHidden = false
                tblView.isHidden = true

            }
            else
            {
                lblMessage.isHidden = true
                tblView.isHidden = false

            }
            
        }
        else
        {
            
            if arrSessionList.count == 0 {
                lblMessage.isHidden = false
                tblView.isHidden = true
            }
            else{
                lblMessage.isHidden = true
                tblView.isHidden = false
            }
            
        }

        
        
    }
    
    @IBAction func addMatch(_ sender:AnyObject){
        
        let sessionVC = self.storyboard?.instantiateViewController(withIdentifier: "AddSessionViewController") as! AddSessionViewController
        self.navigationController?.pushViewController(sessionVC, animated: true)
        
    }
    
    
   
    // MARK: TableView
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSessionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Util.setCellBackgroundColor()
        
        let object = arrSessionList[(indexPath as NSIndexPath).row]
        
        cell.textLabel!.textColor = Util.setNavigationTitleColor()
        cell.textLabel?.backgroundColor = .clear
        cell.detailTextLabel?.backgroundColor = .clear
        cell.detailTextLabel?.textColor = Util.setMainViewBGColor()
        
        cell.textLabel!.font = Util.setCellMainTitleFont()
        cell.detailTextLabel?.font = Util.setCellMainTitleFont()
        
        
        cell.textLabel!.text = object.sessionName + " " + object.teamName as String
        cell.detailTextLabel?.text = object.sessionDate

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
        
        if self.navigationController?.accessibilityLabel == "2" {
            return false
        }

        return true
     }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
     if editingStyle == .delete {
     
        let objSession = arrSessionList[(indexPath as NSIndexPath).row]
        
        let alert = UIAlertController(title: kAPPNAME, message: "All Session Soda of this Session will be Deleted. Are you sure to DELETE Session?", preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        
        let actionDelete = UIAlertAction(title: "Delete", style: .destructive, handler: {
            (action: UIAlertAction) in
            
            let isDeleteAllSoda = ModelManager.getInstance().updateRecord("DELETE FROM SessionSodaTBL WHERE SessionID = \(objSession.sessionID)")
            
            if isDeleteAllSoda{
                
                let isDeleteSession = ModelManager.getInstance().deleteSession(objSession)
                
                if isDeleteSession{
                    
                    self.arrSessionList.remove(at: indexPath.row)
//                    self.arrSessionList.remove(objSession)
                    tableView.deleteRows(at: [indexPath as IndexPath], with: .left)
                    
                    
                    let deleteAlert = UIAlertController(title: kAPPNAME, message: "Session Deleted Successfully.", preferredStyle: .alert)
                    let actionOK = UIAlertAction(title: "OK", style: .default, handler: nil)
                    deleteAlert.addAction(actionOK)
                    
                    self.showDetailViewController(deleteAlert, sender: self)
                   
                    let appDel = UIApplication.shared.delegate as! AppDelegate
                    appDel.isDeletedSession = true
                    
                    
                    if self.arrSessionList.count == 0 {
                        self.lblMessage.alpha = 0.0
                        UIView.animate(withDuration: 0.5, animations:{
                            self.lblMessage.alpha = 1.0
                        })
                        
                        self.lblMessage.isHidden = false
                        self.tblView.isHidden = true
                    }
                    else{
                        self.lblMessage.isHidden = true
                        self.tblView.isHidden = false
                    }
                    
                }
            }
            
        })
        alert.addAction(actionDelete)
        
        showDetailViewController(alert, sender: self)
        
        
     
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
     }
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        
        if self.navigationController?.accessibilityLabel == "2" {
            
           let storyBoard:UIStoryboard = UIStoryboard(name: "Session", bundle: nil)
            
            let sessionSodaVC = storyBoard.instantiateViewController(withIdentifier: "SessionSodaViewController") as! SessionSodaViewController
            sessionSodaVC.objSession = arrSessionList[(indexPath as NSIndexPath).row]
            self.navigationController?.pushViewController(sessionSodaVC, animated: true)
        }
        else{
            let sessionVC = self.storyboard?.instantiateViewController(withIdentifier: "AddSessionViewController") as! AddSessionViewController
            sessionVC.objSession = arrSessionList[(indexPath as NSIndexPath).row]
            
            self.navigationController?.pushViewController(sessionVC, animated: true)
        }
        
        
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
//        tblView?.tableHeaderView?.frame = bannerView.frame
//        tblView?.tableHeaderView = bannerView
        tblView.frame = CGRect(x: tblView.frame.origin.x, y: tblView.frame.origin.y, width: tblView.frame.size.width, height: tblView.frame.size.height - bannerView.frame.size.height)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }

    
}
