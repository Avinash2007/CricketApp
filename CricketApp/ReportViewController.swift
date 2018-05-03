//
//  ReportViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 16/07/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox
import GoogleMobileAds

class ReportViewController: UIViewController,GADBannerViewDelegate {
    
    var arrList:NSArray!
    @IBOutlet weak var tableView:UITableView?
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        //        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.isFullVersion{
            // Request a Google Ad
            adBannerView.load(GADRequest())
            //            self.view.addSubview(adBannerView)
        }
        
        arrList = ["PARTY","MATCH ","SESSION","PROFIT & LOSS"]
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        self.tableView?.backgroundColor = Util.setTableViewBGColor()
        tableView?.separatorColor = Util.setTableViewBGColor()
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share(sender:)))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(sender:)))
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
    
    // MARK: Tableview Methods
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = Util.setCellBackgroundColor()
        cell.textLabel!.text = arrList[(indexPath as NSIndexPath).row]  as? String
        cell.textLabel?.font = Util.setCellMainTitleFont()
        cell.textLabel?.textColor = Util.setCellMainTitleTextColor()
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        //        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            print((indexPath as NSIndexPath).row)
            
            let storyBoardReport:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
            
            let bookieReportVC = storyBoardReport.instantiateViewController(withIdentifier: "BookieReportViewController") as! BookieReportViewController
            bookieReportVC.isHawala = false
            self.navigationController?.pushViewController(bookieReportVC, animated: true)
            
            break
        case 1:
            print((indexPath as NSIndexPath).row)
            
            let storyBoardReport:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
            
            let matchReportVC = storyBoardReport.instantiateViewController(withIdentifier: "MatchReportViewController") as! MatchReportViewController
            
            self.navigationController?.pushViewController(matchReportVC, animated: true)
            
        case 2:
            print((indexPath as NSIndexPath).row)
            
            let storyBoardReport:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
            
            let sessionReportVC = storyBoardReport.instantiateViewController(withIdentifier: "SessionReportViewController") as! SessionReportViewController
            self.navigationController?.pushViewController(sessionReportVC, animated: true)
            
            
        case 3:
            print((indexPath as NSIndexPath).row)
            let storyBoard:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
            
            let bookieFullReportVC = storyBoard.instantiateViewController(withIdentifier: "BookieFullReportViewController") as! BookieFullReportViewController
            
            self.navigationController?.pushViewController(bookieFullReportVC, animated: true)
          
        
            
        default: break
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - GADBannerViewDelegate methods
    
    
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        tableView?.tableHeaderView?.frame = bannerView.frame
        tableView?.tableHeaderView = bannerView
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}
