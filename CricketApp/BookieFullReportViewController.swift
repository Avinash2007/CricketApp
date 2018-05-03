//
//  BookieFullReportViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 20/07/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class BookieFullReportViewController:UIViewController,GADBannerViewDelegate  {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var segment:UISegmentedControl!
    
    var arrMatchList = [MatchClass]()
    var arrMatchReport = [MatchResport]()
    var arrSessionList = [Session]()
    var arrSessionReport = [SessionReport]()
    
    var objBookie:Bookie!
    var isRecall = false
    // MARK: Controller Methods
    
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
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        self.tblView?.backgroundColor = Util.setTableViewBGColor()
        tblView?.separatorColor = Util.setTableViewBGColor()
        
        if objBookie !=  nil {
            self.title = objBookie.bookieName + "'s Report"
        }else
        {
            
            if isRecall {
                    self.title = "Re Call"
            }
            else{
                self.title = "Profit & Loss"
            }
            
        }
        segment.selectedSegmentIndex = 0
        
        segment.tintColor = Util.setNavigationBarColor()
        segment.backgroundColor = Util.setMainViewBGColor()
        
        let attr = NSDictionary(object: UIFont(name:kFONTBTN, size: 15.0)!, forKey: NSFontAttributeName as NSCopying)
        
        segment.setTitleTextAttributes(attr as? [AnyHashable: Any], for: UIControlState())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        self.changeMatchBYSegment(segment)
    }
    
    // MARK: Database Method
    
    func getAllSessionForABookie(){
        
        if (objBookie != nil) {
            
            arrSessionReport = ModelManager.getInstance().getAccountDetailForAllSession("SELECT ATB.AccountID, STB.SessionID, STB.SessionName, STB.TeamName, STB.Run, STB.SessionDate, STB.Amount, (ATB.Amount + ATB.CommiAmount) BookieAMT FROM SessionTBL STB, AccountTBL ATB WHERE STB.SessionID IN(SELECT SessionID FROM SessionSodaTBL WHERE BookieID  = \(objBookie.bookieID)) AND STB.isActive = 0 AND STB.SessionID = ATB.SessionID  AND ATB.BookieID = \(objBookie.bookieID) AND ATB.isMatch = 0 ORDER BY STB.SessionID DESC")
            
        }
        else
        {
            
            arrSessionList = ModelManager.getInstance().getAllActiveSessionList("SELECT * FROM SessionTBL WHERE isActive = 0 ORDER BY SessionID DESC")
        }
        
        tblView.reloadData()
    }
    
    func getAllMatchForABookie(){
        
        if (objBookie != nil) {
            arrMatchReport = ModelManager.getInstance().getAccountDetailForAllMatch("SELECT ATB.AccountID,MTB.MatchID, MTB.Team1, MTB.Team2, MTB.isTest, MTB.WinnerTeam, MTB.MatchDate, ATB.Amount FROM MatchTBL MTB, AccountTBL ATB WHERE MTB.MatchID IN(SELECT MatchID FROM MatchSodaTBL WHERE BookieID = \(objBookie.bookieID)) AND MTB.isActive = 0 AND MTB.MatchID = ATB.MatchID AND ATB.BookieID = \(objBookie.bookieID) AND ATB.isMatch = 1 ORDER BY MTB.MatchID DESC")
        }
        else{
            arrMatchList = ModelManager.getInstance().getAllActiveMatch("SELECT * FROM MatchTBL WHERE isActive = 0 ORDER BY MatchID DESC")
        }
        
        tblView.reloadData()
    }
    @IBAction func changeMatchBYSegment(_ sender:UISegmentedControl)
    {
        if segment.selectedSegmentIndex == 0 {
            self.getAllSessionForABookie()
        }
        else{
            self.getAllMatchForABookie()
        }
    }
    
    // MARK: TableView
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segment.selectedSegmentIndex == 0 {
            if (objBookie != nil) {
                return arrSessionReport.count
            }
            else{
                return arrSessionList.count
            }
        }
        else
        {
            if objBookie != nil
            {
                return arrMatchReport.count
            }
            else
            {
                return arrMatchList.count
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        self.setCellAndSubViewBGColor(cell: cell)
        
        let lblTitle = cell.contentView.viewWithTag(111) as! UILabel
        let lblDate = cell.contentView.viewWithTag(112) as! UILabel
        let lblAmount = cell.contentView.viewWithTag(113) as! UILabel
        let lblRun = cell.contentView.viewWithTag(114) as! UILabel
        
        if segment.selectedSegmentIndex == 0 {
        
           
            
            if (objBookie != nil)
            {
                let object = arrSessionReport[(indexPath as NSIndexPath).row]
                
                
                lblTitle.text = object.teamName + "  " + object.sessionName
                lblDate.text = object.sessionDate
                lblAmount.text = "Amount = " + String(format: "%.3f", object.bookieAMT)
                lblRun.text = "Run = " + String(object.Run)
                
          }
            else{
                let object = arrSessionList[(indexPath as NSIndexPath).row]
                
                lblTitle.text = object.teamName + "  " + object.sessionName
                lblDate.text = object.sessionDate
                lblAmount.text = "Amount = " + String(format: "%.3f", object.Amount)
                lblRun.text = "Run = " + String(object.Run)

                
            }
           
            
        }
        else
        {
           
            if (objBookie != nil)
            {
                let object = arrMatchReport[(indexPath as NSIndexPath).row]
                
                let strMatchType:String!
                
                if object.isTest == 1 {
                    strMatchType = "Test"
                }
                else{
                    strMatchType = "ODI"
                }
                
                
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
                
                let attributedStringForSoda = NSMutableAttributedString(string: object.team1 + " VS " + object.team2 + " ",attributes:dicWhite)
                    
                let attributedStringForObject = NSMutableAttributedString(string:strMatchType,attributes:dicBlack)
                    
                    
                    
                attributedStringForSoda.append(attributedStringForObject)
                
                
                lblTitle.attributedText = attributedStringForSoda
                
                lblDate.text = object.matchDate
                if object.winnerTeam == "Team1" {
                        lblAmount.text = "Winner = " + object.team1
                }
                else{
                    lblAmount.text = "Winner = " + object.team2
                }
                
                lblRun.text = String(format: "%.3f",object.Amount)
            }
            else
            {
                let object = arrMatchList[(indexPath as NSIndexPath).row]
                
                let strMatchType:String!
                
                if object.isTest == 1 {
                    strMatchType = "Test"
                }
                else{
                    strMatchType = "ODI"
                }
                
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
                
                let attributedStringForSoda = NSMutableAttributedString(string: object.team1 + " VS " + object.team2 + " ",attributes:dicWhite)
                
                let attributedStringForObject = NSMutableAttributedString(string:strMatchType,attributes:dicBlack)
                
                
                
                attributedStringForSoda.append(attributedStringForObject)
                
                
                lblTitle.attributedText = attributedStringForSoda
                
                lblDate.text = object.matchDate
                if object.winnerTeam == "Team1" {
                    lblAmount.text = "Winner = " + object.team1
                }
                else{
                    lblAmount.text = "Winner = " + object.team2
                }
                
                lblRun.text = String(format: "%.3f",object.Amount)

            }
            
            
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        if objBookie != nil
        {
            if segment.selectedSegmentIndex == 0 {
                let storyBoard:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
                
                let bookieSessionReportVC = storyBoard.instantiateViewController(withIdentifier: "BookieSessionReportViewController") as! BookieSessionReportViewController
                
                let objSessionReport = arrSessionReport[(indexPath as NSIndexPath).row]
                
                bookieSessionReportVC.sessionID = objSessionReport.sessionID
                bookieSessionReportVC.bookieID = objBookie.bookieID
                bookieSessionReportVC.objSessionReport = objSessionReport
//                bookieSessionReportVC.title = objSessionReport.teamName + " " + objSessionReport.sessionName + "   Run = " + String(objSessionReport.Run)
                
                self.navigationController?.pushViewController(bookieSessionReportVC, animated: true)
                
                
            }
            else
            {
                
                let storyBoard:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
                
                let matchReportVC = storyBoard.instantiateViewController(withIdentifier: "BookieMatchReportViewController") as! BookieMatchReportViewController
                
                let objMatchReport = arrMatchReport[(indexPath as NSIndexPath).row]
                
                matchReportVC.bookieID = objBookie.bookieID
                matchReportVC.objMatchReport = objMatchReport
                
                let winnerTeam:String!
                
                if objMatchReport.winnerTeam == "Team1" {
                    winnerTeam = objMatchReport.team1
                }
                else{
                    winnerTeam = objMatchReport.team2
                }
                
                matchReportVC.title = objMatchReport.team1 + " VS " + objMatchReport.team2 + "    " + winnerTeam
                
                self.navigationController?.pushViewController(matchReportVC, animated: true)
            }

        }
        else
        {
            
            if isRecall{
                
                let alert: UIAlertView = UIAlertView()
                if segment.selectedSegmentIndex == 0 {
                    
                    let object = arrSessionList[(indexPath as NSIndexPath).row]
                    
                    alert.message = "Are you sure you want to Recall this session?"
                    alert.title = "Alert"
                    alert.delegate = self
                    alert.tag = Int(object.sessionID)
                    alert.addButton(withTitle: "Yes")
                    alert.addButton(withTitle: "N0")
                    alert.show()
                }
                else{
                    let object = arrMatchList[(indexPath as NSIndexPath).row]
                    alert.message = "Are you sure you want to Recall this match?"
                    alert.title = "Alert"
                    alert.delegate = self
                    alert.tag = Int(object.matchID)
                    alert.addButton(withTitle: "Yes")
                    alert.addButton(withTitle: "N0")
                    alert.show()
                }
            }
            else
            {
                
                let storyBoard:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
                
                let profitAndLossSession = storyBoard.instantiateViewController(withIdentifier: "ProfitAndLossVC") as! ProfitAndLossVC
               
                if segment.selectedSegmentIndex == 0 {
                     profitAndLossSession.objSession = arrSessionList[(indexPath as NSIndexPath).row]
                }
                else {
                    profitAndLossSession.objMatch = arrMatchList[(indexPath as NSIndexPath).row]
                }
                self.navigationController?.pushViewController(profitAndLossSession, animated: true)

            }
        
            
           
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    //MARK: Alertview Delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        
        
        if segment.selectedSegmentIndex == 0
        {
            if buttonIndex == 0
            {
                let isUpDate = ModelManager.getInstance().updateRecord("UPDATE SessionTBL SET isActive = 1 WHERE SessionID = \(alertView.tag)")
                
                if isUpDate {
                    
                    print("AlertTg = ", alertView.tag)
                    let isUpdateBookie = ModelManager.getInstance().updateRecord("UPDATE BookieTBL SET Amount = (SELECT (BT.Amount - AT.Amount) FROM BookieTBL BT, AccountTBL AT WHERE BT.BookieID = BookieTBL.BookieID AND BT.BookieID = AT.BookieID AND AT.SessionID = \(alertView.tag)), SessionCommiRS = (SELECT (BT.SessionCommiRS - AT.CommiAmount) FROM BookieTBL BT,AccountTBL AT WHERE BT.BookieID = BookieTBL.BookieID AND BT.BookieID = AT.BookieID AND AT.SessionID = \(alertView.tag)), TotalAmount = (SELECT (BT.TotalAmount - AT.Amount) FROM BookieTBL BT, AccountTBL AT WHERE BT.BookieID = BookieTBL.BookieID AND BT.BookieID = AT.BookieID AND AT.SessionID = \(alertView.tag)) WHERE BookieTBL.BookieID IN (SELECT BookieTBL.BookieID FROM BookieTBL, AccountTBL WHERE BookieTBL.BookieID = AccountTBL.BookieID AND AccountTBL.SessionID = \(alertView.tag))")
            
                        
                        if isUpdateBookie {
                            
                            let isUpdateAccount = ModelManager.getInstance().updateRecord("DELETE FROM AccountTBL WHERE SessionID = \(alertView.tag)")
                            
                            print(isUpdateAccount)
                            
                        }
                
                    
                    self.changeMatchBYSegment(segment)
                    self.navigationController?.tabBarController?.selectedIndex = 2
                }
            }
        }
        else
        {
            if buttonIndex == 0 {
                let isUpDate = ModelManager.getInstance().updateRecord("UPDATE MatchTBL SET isActive = 1 WHERE MatchID = \(alertView.tag)")
                print(isUpDate)
                if isUpDate {
                    print("AlertTg = ", alertView.tag)
                    let isUpdateBookie = ModelManager.getInstance().updateRecord("UPDATE BookieTBL SET Amount = (SELECT (BT.Amount - AT.Amount) FROM BookieTBL BT, AccountTBL AT WHERE BT.BookieID = BookieTBL.BookieID AND BT.BookieID = AT.BookieID AND AT.MatchID = \(alertView.tag)), ODICommiRS = (SELECT (BT.ODICommiRS - AT.CommiAmount) FROM BookieTBL BT,AccountTBL AT WHERE BT.BookieID = BookieTBL.BookieID AND BT.BookieID = AT.BookieID AND AT.MatchID = \(alertView.tag)), TotalAmount = (SELECT (BT.TotalAmount - AT.Amount) FROM BookieTBL BT, AccountTBL AT WHERE BT.BookieID = BookieTBL.BookieID AND BT.BookieID = AT.BookieID AND AT.MatchID = \(alertView.tag)) WHERE BookieTBL.BookieID IN (SELECT BookieTBL.BookieID FROM BookieTBL, AccountTBL WHERE BookieTBL.BookieID = AccountTBL.BookieID AND AccountTBL.MatchID = \(alertView.tag))")
                    
                    
                    if isUpdateBookie {
                        
                        let isUpdateAccount = ModelManager.getInstance().updateRecord("DELETE FROM AccountTBL WHERE MatchID = \(alertView.tag)")
                        
                        print(isUpdateAccount)
                        
                    }
                    
                    
                    self.changeMatchBYSegment(segment)
                    self.navigationController?.tabBarController?.selectedIndex = 1
                }
            }
        }
       
        
        
    }

    func setCellAndSubViewBGColor(cell:UITableViewCell)
    {
        cell.backgroundColor = Util.setCellBackgroundColor()
        
        let lblTitle = cell.contentView.viewWithTag(111) as! UILabel
        let lblDate = cell.contentView.viewWithTag(112) as! UILabel
        let lblAmount = cell.contentView.viewWithTag(113) as! UILabel
        let lblRun = cell.contentView.viewWithTag(114) as! UILabel
        
        
        lblTitle.textColor = Util.setCellMainTitleTextColor()
        lblDate.textColor = Util.setCellMainTitleTextColor()
        lblAmount.textColor = Util.setCellMainTitleTextColor()
        lblRun.textColor = Util.setCellMainTitleTextColor()
        
        lblRun.font = Util.setCellMainTitleFont()
        lblAmount.font = Util.setCellMainTitleFont()
        lblDate.font = Util.setCellMainTitleFont()
        lblTitle.font = Util.setCellMainTitleFont()
        
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
