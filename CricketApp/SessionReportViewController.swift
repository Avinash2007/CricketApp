//
//  SessionReportViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 22/07/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class SessionReportViewController: UIViewController,GADBannerViewDelegate {
    
    @IBOutlet weak var tblView:UITableView!
    
    var arrSessionList = [Session]()
    var arrFilterSessionList = [Session]()
    var objSessionReport:SessionReport!
//    var bookieID:Int32!
    var sessionBookieWiseReport:Int32 = 0
    
     let searchController = UISearchController(searchResultsController: nil)
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    //MARK: View Controller Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Session Report"
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.isFullVersion{
            // Request a Google Ad
            adBannerView.load(GADRequest())
            self.view.addSubview(adBannerView)
        }
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        self.tblView?.backgroundColor = Util.setTableViewBGColor()
        tblView?.separatorColor = Util.setTableViewBGColor()
        
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.barTintColor = Util.setSearchBarTintColor()
        searchController.searchBar.tintColor = Util.setNavigationBarColor()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllSessionSodaForABookie()
    }
    
    //MARK: Get Values From DB
    
    func getAllSessionSodaForABookie()
    {
        arrSessionList = ModelManager.getInstance().getAllActiveSessionList("SELECT * FROM SessionTBL WHERE isActive = \(0) ORDER BY SessionID DESC")
        
        if tblView.tableHeaderView == nil{
            tblView.tableHeaderView = searchController.searchBar
        }
        
        tblView.reloadData()
    }
    
    //MARK: TableView Delegate Methods
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return arrFilterSessionList.count
        }
        return arrSessionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Util.setCellBackgroundColor()
        
        let object:Session!
        if searchController.isActive && searchController.searchBar.text != "" {
            
            object = arrFilterSessionList[indexPath.row]
        }
        else
        {
            object = arrSessionList[(indexPath as NSIndexPath).row]
        }
        
        //        cell.textLabel!.text = object.teamCode + "    " + object.amount + "    " + object.bhav + "    " + strSodo
        
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
        
        
        lblTitle.text = object.teamName + "  " + object.sessionName
        lblDate.text = object.sessionDate
        lblAmount.text = "Amount = " + String(format: "%.3f", object.Amount)
        lblRun.text = "Run = " + String(object.Run)

        
//        cell.textLabel?.text = object.sessionDate + " " + object.teamName + " " + object.sessionName +  " " + String(format: "%.3f", object.Amount) + "  " + String(object.Run)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        
        let object:Session!
        if searchController.isActive && searchController.searchBar.text != "" {
            
            object = arrFilterSessionList[indexPath.row]
        }
        else
        {
            object = arrSessionList[(indexPath as NSIndexPath).row]
        }

        
        
        if sessionBookieWiseReport == 0 {
            let storyBoard:UIStoryboard = UIStoryboard(name: "Session", bundle: nil)
            
            let sessionSodaVC = storyBoard.instantiateViewController(withIdentifier: "SessionSodaViewController") as! SessionSodaViewController
            sessionSodaVC.isReadOnly = 1
            sessionSodaVC.objSession = object
            self.navigationController?.pushViewController(sessionSodaVC, animated: true)

        }
        else
        {
            let storyBoard:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
            
            let sessionBookWiseReport = storyBoard.instantiateViewController(withIdentifier: "ProfitAndLossVC") as! ProfitAndLossVC
            
            sessionBookWiseReport.objSession = object
            self.navigationController?.pushViewController(sessionBookWiseReport, animated: true)
            
        }
       
        
        tblView.deselectRow(at: indexPath, animated: true)
    }

    
    func filterContentForSearchText(_ searchText: String) {
        
        arrFilterSessionList = self.arrSessionList.filter({(objSession:Session) ->Bool in
            return objSession.sessionDate.lowercased().contains(searchText.lowercased())
        })
        tblView.reloadData()
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        tblView.frame = CGRect(x: tblView.frame.origin.x, y: tblView.frame.origin.y, width: tblView.frame.size.width, height: tblView.frame.size.height - bannerView.frame.size.height)
        //        tableView?.tableHeaderView?.frame = bannerView.frame
        //        tableView?.tableHeaderView = bannerView
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}
extension SessionReportViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension SessionReportViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}


