//
//  BookieSessionReportViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 21/07/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class BookieSessionReportViewController: UIViewController,GADBannerViewDelegate {
    
    @IBOutlet weak var tblView:UITableView!
    
    var arrSessionSodaList:NSMutableArray!
    var objSessionReport:SessionReport!
    var bookieID = Int32()
    var sessionID = Int32()
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        //        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    //MARK: View Controller Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.isFullVersion{
            // Request a Google Ad
            adBannerView.load(GADRequest())
            //            self.view.addSubview(adBannerView)
        }
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        self.tblView?.backgroundColor = Util.setTableViewBGColor()
        tblView?.separatorColor = Util.setTableViewBGColor()
        
        let lblTitle = UILabel()
        lblTitle.frame = CGRect(x: 50, y: 0, width: 100, height: 20)
        lblTitle.textAlignment = .center
        lblTitle.font = Util.setCustomNavigationMainTitleFont()
        lblTitle.textColor = .white
        lblTitle.text = objSessionReport.teamName
        
        
        let lblSubTitle = UILabel()
        lblSubTitle.frame = CGRect(x: 0, y: 20, width: 100, height: 20)
        lblSubTitle.textAlignment = .center
        lblSubTitle.font = Util.setCustomNavigationSubTitleFont()
        lblSubTitle.textColor = Util.setMainViewBGColor()
        lblSubTitle.text = objSessionReport.sessionName
        
        
        let lblRun = UILabel()
        lblRun.frame = CGRect(x: 100, y: 20, width: 100, height: 20)
        lblRun.textAlignment = .center
        lblRun.font = Util.setCustomNavigationSubTitleFont()
        lblRun.textColor = Util.setMainViewBGColor()
        lblRun.text = "Run = " + String(objSessionReport.Run)

        
        
        let viewForNav = UIView()
        viewForNav.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
        viewForNav.backgroundColor = .clear
        viewForNav.addSubview(lblTitle)
        viewForNav.addSubview(lblSubTitle)
        viewForNav.addSubview(lblRun)
        self.navigationItem.titleView = viewForNav

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllSessionSodaForABookie()
    }

    //MARK: Get Values From DB
    
    func getAllSessionSodaForABookie()
    {
        arrSessionSodaList = ModelManager.getInstance().getAllDetailOfSession("SELECT * FROM SessionSodaTBL WHERE SessionID = \(sessionID) AND BookieID = \(bookieID)")
        print(arrSessionSodaList.count)
    }
    
    //MARK: TableView Delegate Methods
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return arrSessionSodaList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        
        let object = arrSessionSodaList[(indexPath as NSIndexPath).row] as! SessionSoda
        
        //        cell.textLabel!.text = object.teamCode + "    " + object.amount + "    " + object.bhav + "    " + strSodo
        
        var strSodo:String
        
        if object.thay == 1 {
            strSodo = "L"
        }
        else{
            strSodo = "K"
        }
        
        //cell.textLabel!.text = object.run + " " + strSodo + "    " + object.amount + "  " + object.sessionDetailDate
        cell.backgroundColor = Util.setCellBackgroundColor()
        let lblRun = cell.viewWithTag(11) as! UILabel
        let lblAmout = cell.viewWithTag(12) as! UILabel
        let lblSessionDetailDate = cell.viewWithTag(13) as! UILabel
        
        lblRun.font = Util.setCellMainTitleFont()
        lblAmout.font = Util.setCellMainTitleFont()
        lblSessionDetailDate.font = Util.setCellMainTitleFont()
        
        lblRun.textColor = .white
        lblAmout.textColor = .white
        lblSessionDetailDate.textColor = .white
        
        lblRun.text = String(object.Run) + "  " + strSodo as String
        lblAmout.text = String(format:"%.1f", object.amount) + " * " + String(object.bhav)
        lblSessionDetailDate.text = object.sessionSodaDate as String
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tblView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - GADBannerViewDelegate methods
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        tblView?.tableHeaderView?.frame = bannerView.frame
        tblView?.tableHeaderView = bannerView
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}
