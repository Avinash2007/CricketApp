//
//  ODIViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 09/06/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class ODIViewController: UIViewController,GADBannerViewDelegate,GADInterstitialDelegate {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnPlus:UIBarButtonItem!
    @IBOutlet weak var barButtonItem:UINavigationItem!
    @IBOutlet weak var lblMessage:UILabel!
    var arrMatchList = [MatchClass]()
    
    var isTest:Bool = Bool()
    
    
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    // MARK: Controller Methods
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
        
        if self.navigationController?.tabBarController?.selectedIndex == 1 {
            barButtonItem.rightBarButtonItems = []
        }
        
        lblMessage.font = Util.setLableMessageFont()
        lblMessage.textColor = Util.setNavigationBarColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isTest == true {
                self.getAllActiveMatchTestList()
        }
        else{
            
            
            self.getAllActiveMatchODIList()
        }
       
        
    }
    
    // MARK: Database Method
    
    func getAllActiveMatchODIList(){
        arrMatchList = ModelManager.getInstance().getAllActiveMatch("SELECT * FROM MatchTBL WHERE isActive = \(1) AND isTest = \(0) ORDER BY MatchID DESC")
        
        if arrMatchList.count == 0 {
            lblMessage.isHidden = false
            tblView.isHidden = true
        }
        else{
            lblMessage.isHidden = true
            tblView.isHidden = false
        }

        tblView.reloadData()
    }
    
    func getAllActiveMatchTestList(){
        arrMatchList = ModelManager.getInstance().getAllActiveMatch("SELECT * FROM MatchTBL WHERE isActive = \(1) AND isTest = \(1) ORDER BY MatchID DESC")
        
        if arrMatchList.count == 0 {
            lblMessage.isHidden = false
            tblView.isHidden = true
        }
        else{
            lblMessage.isHidden = true
            tblView.isHidden = false
        }
        tblView.reloadData()
    }

    
    @IBAction func addMatch(_ sender:AnyObject){
        
        
        let odiDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ODIDetailViewController") as! ODIDetailViewController
        odiDetailVC.isTest = isTest
        self.navigationController?.pushViewController(odiDetailVC, animated: true)
        
    }
    
    // MARK: TableView
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMatchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Util.setCellBackgroundColor()
        
        let object = arrMatchList[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = object.team1 + " vs " + object.team2 as String
        cell.textLabel?.textColor = Util.setNavigationTitleColor()
        cell.textLabel?.font = Util.setCellMainTitleFont()
        cell.detailTextLabel?.textColor = Util.setMainViewBGColor()
        cell.detailTextLabel?.font = Util.setCellMainTitleFont()
        cell.textLabel?.backgroundColor = .clear
        cell.detailTextLabel?.backgroundColor = .clear
        
        
        cell.detailTextLabel?.text = object.matchDate
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
             let objMatch = arrMatchList[(indexPath as NSIndexPath).row]
            
            let alert = UIAlertController(title: kAPPNAME, message: "All Match Soda of this Match will be Deleted. Are you sure to DELETE Match?", preferredStyle: .alert)
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(actionCancel)
            
            let actionDelete = UIAlertAction(title: "Delete", style: .destructive, handler: {
                (action: UIAlertAction) in
                
                let isDeleteAllSoda = ModelManager.getInstance().updateRecord("DELETE FROM MatchSodaTBL WHERE MatchID = \(objMatch.matchID)")
                
                if isDeleteAllSoda{
                    
                    let isDeleteMatch = ModelManager.getInstance().deleteMatchData(objMatch)
                    
                    if isDeleteMatch{
                        
                        self.arrMatchList.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath as IndexPath], with: .left)
                        
                        
                        let deleteAlert = UIAlertController(title: kAPPNAME, message: "Match Deleted Successfully.", preferredStyle: .alert)
                        let actionOK = UIAlertAction(title: "OK", style: .default, handler: nil)
                        deleteAlert.addAction(actionOK)
                        
                        self.showDetailViewController(deleteAlert, sender: self)
                        
                        let appDel = UIApplication.shared.delegate as! AppDelegate
                        
                        if self.isTest == true
                        {
                            appDel.isDeleteTestMatch = true
                        }
                        else
                        {
                            appDel.isDeleteODIMatch = true
                        }
                        
                        
                        
                        if self.arrMatchList.count == 0 {
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
            

            
            
           
            
//            let isDeleted = ModelManager.getInstance().deleteMatchData(objMatch)
//            
//            if isDeleted {
//                Util.invokeAlertMethod("", strBody: "Record Deleted successfully.", delegate: nil)
//            } else {
//                Util.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
//            }
//            self.getAllActiveMatchODIList()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
       
//        if self.navigationController?.tabBarController?.selectedIndex == 0 {
            let odiDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "ODIDetailViewController") as! ODIDetailViewController
            odiDetailVC.objMatch = arrMatchList[(indexPath as NSIndexPath).row]
            odiDetailVC.isTest = isTest
            self.navigationController?.pushViewController(odiDetailVC, animated: true)
//        }
//        else if self.navigationController?.tabBarController?.selectedIndex == 1 {
//            
//            let storyBoard:UIStoryboard = UIStoryboard(name: "Match", bundle: nil)
//            
//            let matchVC = storyBoard.instantiateViewController(withIdentifier: "MatchViewController") as! MatchViewController
//            matchVC.objMatch = arrMatchList[(indexPath as NSIndexPath).row]
//            self.navigationController?.pushViewController(matchVC, animated: true)
//            
//            
//        }
        
        
    }
    // MARK: - GADBannerViewDelegate methods
    
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
