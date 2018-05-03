//
//  ProfitAndLossVC.swift
//  CricketApp
//
//  Created by Jeet Meghanathi on 20/10/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class ProfitAndLossVC: UIViewController,GADBannerViewDelegate {
    
    @IBOutlet weak var tblView:UITableView!
    
    var arrAccount = [Account]()
    
    var objSession:Session!
    var objMatch:MatchClass!
    
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
        
        if objSession != nil {
            
            self.seHeaderForSession()
        }
        else
        {
            self.setHeaderForMatch()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if objSession != nil{
                self.getAllSessionSodaForABookie()
        }
        else
        {
            self.getAllMatchSodaForABookie()
        }
        
    }
    
    func seHeaderForSession()
    {
        let lblTitle = UILabel()
        lblTitle.frame = CGRect(x: 50, y: 0, width: 100, height: 20)
        lblTitle.textAlignment = .center
        lblTitle.font = Util.setCustomNavigationMainTitleFont()
        lblTitle.textColor = .white
        
        
        lblTitle.text = objSession.teamName
        
        
        let lblSubTitle = UILabel()
        lblSubTitle.frame = CGRect(x: 0, y: 20, width: 100, height: 20)
        lblSubTitle.textAlignment = .center
        lblSubTitle.font = Util.setCustomNavigationSubTitleFont()
        lblSubTitle.textColor = Util.setMainViewBGColor()
        lblSubTitle.text = objSession.sessionName
        
        
        let lblRun = UILabel()
        lblRun.frame = CGRect(x: 100, y: 20, width: 100, height: 20)
        lblRun.textAlignment = .center
        lblRun.font = Util.setCustomNavigationSubTitleFont()
        lblRun.textColor = Util.setMainViewBGColor()
        lblRun.text = "Run = " + String(objSession.Run)
        
        
        
        let viewForNav = UIView()
        viewForNav.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
        viewForNav.backgroundColor = .clear
        viewForNav.addSubview(lblTitle)
        viewForNav.addSubview(lblSubTitle)
        viewForNav.addSubview(lblRun)
        self.navigationItem.titleView = viewForNav

    }
    
    func setHeaderForMatch(){
        
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
        
        if objMatch.winnerTeam == "Team1"
        {
            lblSubTitle.text = objMatch.team1
        }
        else
        {
            lblSubTitle.text = objMatch.team2
        }
        
        
        
        let viewForNav = UIView()
        viewForNav.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        viewForNav.backgroundColor = .clear
        viewForNav.addSubview(lblTitle)
        viewForNav.addSubview(lblSubTitle)
        
        self.navigationItem.titleView = viewForNav
    }
    
    //MARK: Get Values From DB
    
    func getAllSessionSodaForABookie()
    {
        
        arrAccount = ModelManager.getInstance().getAccountDetail("SELECT AT.AccountID, AT.MatchID, AT.BookieID, AT.SessionID, AT.isMatch, AT.Amount, BookieTBL.BookieName, AT.CommiAmount FROM AccountTBL AT INNER JOIN BookieTBL On AT.BookieID = BookieTBL.BookieID WHERE AT.SessionID = \(objSession.sessionID) ORDER BY BookieTBL.BookieName ASC")
        
//        let objAccount:Account = Account()
//        objAccount.amount = objSession.Amount * (-1)
//        let defaults = UserDefaults.standard
//        objAccount.bookieName = defaults.string(forKey: "UserName")!
//        
//        objAccount.commiAmount = 0.0
//        
//        arrSessionList.add(objAccount)
        
        
        tblView.reloadData()
    }
    
    func getAllMatchSodaForABookie()
    {
        arrAccount = ModelManager.getInstance().getAccountDetail("SELECT AT.AccountID, AT.MatchID, AT.BookieID, AT.SessionID, AT.isMatch, AT.Amount, BookieTBL.BookieName, AT.CommiAmount FROM AccountTBL AT INNER JOIN BookieTBL On AT.BookieID = BookieTBL.BookieID WHERE AT.MatchID = \(objMatch.matchID) ORDER BY BookieTBL.BookieName ASC")
        
        
        tblView.reloadData()

    }
    
    //MARK: TableView Delegate Methods
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrAccount.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Util.setCellBackgroundColor()
        let lblLeft = cell.viewWithTag(121) as! UILabel
        let lblRight = cell.viewWithTag(122) as! UILabel
        
        lblLeft.text = ""
        lblRight.text = ""
        lblRight.textAlignment = .left
        
        
        let objAccount = arrAccount[(indexPath as NSIndexPath).row]
        
        if objAccount.bookieID == kBOOKID{
            
            if (objAccount.amount + objAccount.commiAmount) < 0 {
                
                lblRight.text =  objAccount.bookieName + " = " + String(format:"%.3f",(objAccount.amount + objAccount.commiAmount))
                
                lblRight.font = Util.setCellMainTitleFont()
            }
            else
            {
                
                
                lblLeft.text = objAccount.bookieName + " = " + String(format:"%.3f",(objAccount.amount + objAccount.commiAmount))
                lblLeft.font = Util.setCellMainTitleFont()
            }
        }
        else
        {
            if (objAccount.amount + objAccount.commiAmount) < 0 {
                
                lblRight.text =  objAccount.bookieName + " = " + String(format:"%.3f",(objAccount.amount + objAccount.commiAmount))
                
                lblRight.font = Util.setCellMainTitleFont()
            }
            else
            {
                
                
                lblLeft.text = objAccount.bookieName + " = " + String(format:"%.3f",(objAccount.amount + objAccount.commiAmount))
                lblLeft.font = Util.setCellMainTitleFont()
            }
        }
        
        
        /*if objAccount.amount < 0 {
            
            lblRight.text =  objAccount.bookieName + " = " + String(format:"%.3f",(objAccount.amount - objAccount.commiAmount))
            
            lblRight.font = Util.setCellMainTitleFont()
        }
        else
        {
            
            
            lblLeft.text = objAccount.bookieName + " = " + String(format:"%.3f",(objAccount.amount - objAccount.commiAmount))
            lblLeft.font = Util.setCellMainTitleFont()
        }
        */
        if objAccount.bookieID == kBOOKID {
//            if objAccount.amount < 0 {
                lblRight.textColor = Util.setNavigationBarColor()
//            }
//            else{
                lblLeft.textColor = Util.setNavigationBarColor()
//            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        let objAccount = arrAccount[indexPath.row]
        
        if objSession != nil {
            if objAccount.bookieID != kBOOKID {
                let storyBoard:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
                
                let bookieSessionReportVC = storyBoard.instantiateViewController(withIdentifier: "BookieSessionReportViewController") as! BookieSessionReportViewController
                
                
                
                bookieSessionReportVC.sessionID = objAccount.sessionID
                bookieSessionReportVC.bookieID = objAccount.bookieID
                
                let objSessionReport = SessionReport()
                objSessionReport.teamName = objSession.teamName
                objSessionReport.sessionName = objSession.sessionName
                objSessionReport.Run = objSession.Run
                objSessionReport.sessionID = objAccount.sessionID
                
                bookieSessionReportVC.objSessionReport = objSessionReport
                bookieSessionReportVC.title = objSession.teamName + " " + objSession.sessionName + "   Run = " + String(objSession.Run)
                
                self.navigationController?.pushViewController(bookieSessionReportVC, animated: true)
                
            }

        }
        else
        {
            
            
            if objAccount.bookieID != kBOOKID {
            
                let storyBoard:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
                
                let matchReportVC = storyBoard.instantiateViewController(withIdentifier: "BookieMatchReportViewController") as! BookieMatchReportViewController
                
                let objMatchReport = MatchResport()
                
                matchReportVC.bookieID = objAccount.bookieID
                
                objMatchReport.team1 = objMatch.team1
                objMatchReport.team2 = objMatch.team2
                objMatchReport.winnerTeam = objMatch.winnerTeam
                objMatchReport.matchID = objAccount.matchID
                
                matchReportVC.objMatchReport = objMatchReport
                
                self.navigationController?.pushViewController(matchReportVC, animated: true)

            }
        }
        
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
