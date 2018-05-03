//
//  AllMatchListViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 14/06/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class AllMatchListViewController: UIViewController,GADBannerViewDelegate {
    
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblMessage:UILabel!
    @IBOutlet weak var segment:UISegmentedControl!
    var arrMatchList = [MatchClass]()
    

    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(sender:)))
//        segment.selectedSegmentIndex = 0
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        self.tblView?.backgroundColor = Util.setTableViewBGColor()
        tblView?.separatorColor = Util.setTableViewBGColor()
        
        segment.tintColor = Util.setNavigationBarColor()
        segment.backgroundColor = Util.setMainViewBGColor()
        
        let attr = NSDictionary(object: UIFont(name:kFONTBTN, size: 15.0)!, forKey: NSFontAttributeName as NSCopying)
        
        segment.setTitleTextAttributes(attr as? [AnyHashable: Any], for: UIControlState())
        
        lblMessage.font = Util.setLableMessageFont()
        lblMessage.textColor = Util.setNavigationBarColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arrMatchList.removeAll()
        self.segmentValChange()
        
    }
    
    @IBAction func segmentValChange() {
        if segment.selectedSegmentIndex == 0 {
            arrMatchList = ModelManager.getInstance().getAllActiveMatch("SELECT * FROM MatchTBL WHERE isActive = \(1) AND isTest = \(0) ORDER BY MatchID DESC")
        }
        else{
            arrMatchList = ModelManager.getInstance().getAllActiveMatch("SELECT * FROM MatchTBL WHERE isActive = \(1) AND isTest = \(1) ORDER BY MatchID DESC")
        }
        
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
        
        let lblName = cell.viewWithTag(11) as! UILabel
        let lblDate = cell.viewWithTag(12) as! UILabel
        
        lblName.textColor = Util.setNavigationTitleColor()
        lblDate.textColor = Util.setMainViewBGColor()
        lblName.font = Util.setCellMainTitleFont()
        lblDate.font = Util.setCellMainTitleFont()
        lblName.backgroundColor = .clear
        lblDate.backgroundColor = .clear
        
//        let objMatch:MatchClass!
        
        
        let objMatch = arrMatchList[indexPath.row]
        
        
//        lblName.text = objMatch.team1 + " vs " + objMatch.team2 +""
        
        var strMatchType:String!
        
        if objMatch.isTest == 1 {
            strMatchType = "Test"
        }
        else{
            strMatchType = "ODI"
        }
        
        strMatchType = ""
        
        let dicWhite = [
            NSBaselineOffsetAttributeName: NSNumber(value: 0 as Float),
            NSFontAttributeName:Util.setCellMainTitleFont(),
            NSForegroundColorAttributeName:UIColor.white
            
        ]
        
        let dicBlack = [
            NSBaselineOffsetAttributeName: NSNumber(value: 0 as Float),
            NSFontAttributeName:Util.setCellMainTitleFont(),
            NSForegroundColorAttributeName:Util.setNavigationBarColor()
            
        ]
        let attributedStringForSoda = NSMutableAttributedString(string: objMatch.team1 + " VS " + objMatch.team2 + " ",
                                                                attributes:dicWhite)
        
        let attributedStringForObject = NSMutableAttributedString(string: strMatchType,attributes:dicBlack)
        
        
        
        attributedStringForSoda.append(attributedStringForObject)
        
        
        
        
        
        lblName.attributedText = attributedStringForSoda
        
        
        lblDate.text = objMatch.matchDate as String

        
       /* if segment.selectedSegmentIndex == 0 {
            let object = arrMatchList[(indexPath as NSIndexPath).row]
        
            lblName.text = object.team1 + " vs " + object.team2
            
           
            lblDate.text = object.matchDate as String
            
            //cell.textLabel!.text = object.team1 + " vs " + object.team2 + "         " + object.matchDate as String
        }
        else{
            let object = arrMatchList[(indexPath as NSIndexPath).row]
            
            //cell.textLabel!.text = object.team1 + " vs " + object.team2 + "         " + object.matchDate as String
            
            
            
            lblName.text = object.team1 + " vs " + object.team2
            
            
            lblDate.text = object.matchDate as String
        }*/
       
        
        return cell
    }
    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//    
//    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String?
//    {
//        return "CLOSE"
//    }
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            
//        
//        let objectMatch = arrMatchList[indexPath.row] as! MatchClass
//        objectMatch.isActiveMatch = 0
//        
//        let strQuery = String(format: "UPDATE MatchTBL SET isActiveMatch='%d'  WHERE MatchID ='%d'", arguments: [objectMatch.isActiveMatch,objectMatch.matchID])
//        
//        let isUpdated = ModelManager.getInstance().updateRecord(strQuery)
//        
//        if isUpdated{
//            Util.invokeAlertMethod("", strBody: "Session Closed successfully.", delegate: nil)
//        }
//        else
//        {
//            Util.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
//        }
//            
//        if segment.selectedSegmentIndex == 0 {
//            self.getAllActiveODIList()
//        }else{
//            self.getAllActiveTestList()
//        }
//        
//            
//            
//            
//            
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        let objMatch  = arrMatchList[indexPath.row]
        
        
       
        
       if objMatch.isTest == 0 {
            let storyBoard:UIStoryboard = UIStoryboard(name: "Match", bundle: nil)
            
            let matchVC = storyBoard.instantiateViewController(withIdentifier: "MatchViewController") as! MatchViewController
            matchVC.objMatch = objMatch
            self.navigationController?.pushViewController(matchVC, animated: true)
            
            
        }else{
         
            let storyBoard:UIStoryboard = UIStoryboard(name: "Match", bundle: nil)
            
            let matchVC = storyBoard.instantiateViewController(withIdentifier: "TestMatchViewController") as! TestMatchViewController
            matchVC.isReanOnly = 0
            matchVC.objMatch = objMatch
            self.navigationController?.pushViewController(matchVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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




