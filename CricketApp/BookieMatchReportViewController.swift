//
//  BookieMatchReportViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 21/07/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class BookieMatchReportViewController: UIViewController,GADBannerViewDelegate {
    
    @IBOutlet weak var tblView:UITableView!
    
    var arrMatchSodaList:NSMutableArray!
    var objMatchReport:MatchResport!
    var bookieID:Int32 = Int32()
    
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
        lblTitle.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
        lblTitle.textAlignment = .center
        lblTitle.font = Util.setCustomNavigationMainTitleFont()
        lblTitle.textColor = .white
        lblTitle.text = "Winner Team"
        
        
        let lblSubTitle = UILabel()
        lblSubTitle.frame = CGRect(x: 10, y: 20, width: 100, height: 20)
        lblSubTitle.textAlignment = .center
        lblSubTitle.font = Util.setCustomNavigationSubTitleFont()
        lblSubTitle.textColor = Util.setMainViewBGColor()
        
        if objMatchReport.winnerTeam == "Team1"
        {
            lblSubTitle.text = objMatchReport.team1
        }
        else
        {
            lblSubTitle.text = objMatchReport.team2
        }
        
        
        
        let viewForNav = UIView()
        viewForNav.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        viewForNav.backgroundColor = .clear
        viewForNav.addSubview(lblTitle)
        viewForNav.addSubview(lblSubTitle)
        
        self.navigationItem.titleView = viewForNav

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllMatchSodaForABookie()
    }
    
    //MARK: Get Values From DB
    
    func getAllMatchSodaForABookie()
    {
        arrMatchSodaList = ModelManager.getInstance().getAllMatchSodaList("SELECT * FROM MatchSodaTBL WHERE MatchID = \(objMatchReport.matchID) AND BookieID = \(bookieID) ORDER BY MatchSodaID DESC")
    }
    
    //MARK: TableView Delegate Methods
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return arrMatchSodaList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Util.setCellBackgroundColor()
        
        let object = arrMatchSodaList[(indexPath as NSIndexPath).row] as! MatchSoda
        
        let strSodo:String
        
        if object.win == 1 {
            strSodo = "L"
        }
        else{
            strSodo = "K"
        }
        
        
        let lblTeam = cell.viewWithTag(11) as! UILabel
        let lblAmout = cell.viewWithTag(12) as! UILabel
        let lblDate = cell.viewWithTag(13) as! UILabel
        
        lblTeam.font = Util.setCellMainTitleFont()
        lblAmout.font = Util.setCellMainTitleFont()
        lblDate.font = Util.setCellMainTitleFont()
        
        lblTeam.textColor = Util.setNavigationTitleColor()
        lblDate.textColor = Util.setNavigationTitleColor()
        lblAmout.textColor = Util.setNavigationTitleColor()
        
        
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
        
        
        
        
        if object.teamCode == "Team1" {
            
            let attributedStringForSoda = NSMutableAttributedString(string: strSodo + "  ",
                                                                    attributes:dicBlack)
            
            let attributedStringForObject = NSMutableAttributedString(string: objMatchReport.team1,attributes:dicWhite)
            
            
            
            attributedStringForSoda.append(attributedStringForObject)
            
            lblTeam.attributedText = attributedStringForSoda
        }
        else{
            let attributedStringForSoda = NSMutableAttributedString(string: strSodo + "  ",
                                                                    attributes:dicBlack)
            
            let attributedStringForObject = NSMutableAttributedString(string: objMatchReport.team2,attributes:dicWhite)
            
            
            
            attributedStringForSoda.append(attributedStringForObject)
            
            lblTeam.attributedText = attributedStringForSoda
        }
        
        
        
        lblAmout.text = String(format: "%.1f",object.amount) + " * " + String(format: "%.2f",object.bhav)
        
        
        lblDate.text = object.matchSodaDate as String
        

        

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
