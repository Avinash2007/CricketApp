//
//  MatchReportViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 22/07/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class MatchReportViewController: UIViewController,GADBannerViewDelegate {
    @IBOutlet weak var tblView:UITableView!
    
    var arrMatchList = [MatchClass]()
    var arrFilteredMatch = [MatchClass]()
    
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
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.isFullVersion{
            // Request a Google Ad
            adBannerView.load(GADRequest())
            self.view.addSubview(adBannerView)
        }
        
        self.title = "Match Report"
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        self.tblView?.backgroundColor = Util.setTableViewBGColor()
        tblView?.separatorColor = Util.setTableViewBGColor()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
         searchController.searchBar.scopeButtonTitles = ["All Match", "Test Match", "OneDay Match"]
        
        searchController.searchBar.barTintColor = Util.setSearchBarTintColor()
        searchController.searchBar.tintColor = Util.setNavigationBarColor()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllMatchSodaForABookie()
    }
    
    //MARK: Get Values From DB
    
    func getAllMatchSodaForABookie()
    {
        arrMatchList = ModelManager.getInstance().getAllActiveMatch("SELECT * FROM MatchTBL WHERE isActive = \(0) ORDER BY MatchID DESC")
    
        if tblView.tableHeaderView == nil{
            tblView.tableHeaderView = searchController.searchBar
        }
        
        tblView.reloadData()
    }
    
    //MARK: TableView Delegate Methods
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return arrFilteredMatch.count
        }
        
        return arrMatchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Util.setCellBackgroundColor()
        
        let object:MatchClass!
        if searchController.isActive && searchController.searchBar.text != "" {
            
            object = arrFilteredMatch[indexPath.row]
        }
        else
        {
            object = arrMatchList[(indexPath as NSIndexPath).row]
        }
        
        
        let strMatchType:String!
        
        if object.isTest == 1 {
            strMatchType = "Test"
        }
        else{
            strMatchType = "ODI"
        }
        
        //        cell.textLabel!.text = object.teamCode + "    " + object.amount + "    " + object.bhav + "    " + strSodo
        
        let lblTitle = cell.contentView.viewWithTag(111) as! UILabel
        let lblDate = cell.contentView.viewWithTag(112) as! UILabel
        let lblWinnerTeam = cell.contentView.viewWithTag(113) as! UILabel
        let lblAmount = cell.contentView.viewWithTag(114) as! UILabel
        
        
        lblTitle.textColor = Util.setCellMainTitleTextColor()
        lblDate.textColor = Util.setCellMainTitleTextColor()
        lblAmount.textColor = Util.setCellMainTitleTextColor()
        lblWinnerTeam.textColor = Util.setCellMainTitleTextColor()
        
        lblWinnerTeam.font = Util.setCellMainTitleFont()
        lblAmount.font = Util.setCellMainTitleFont()
        lblDate.font = Util.setCellMainTitleFont()
        lblTitle.font = Util.setCellMainTitleFont()
        
        
        
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
        let attributedStringForSoda = NSMutableAttributedString(string: object.team1 + " VS " + object.team2 + " ",
                                                                attributes:dicWhite)
        
        let attributedStringForObject = NSMutableAttributedString(string: strMatchType,attributes:dicBlack)
        
        
        
        attributedStringForSoda.append(attributedStringForObject)
        

        
        
        
        lblTitle.attributedText = attributedStringForSoda
        lblDate.text = object.matchDate
        lblAmount.text = String(format: "%.3f", object.Amount)
        
        if object.winnerTeam == "Team1"{
             lblWinnerTeam.text = "Winner = " +  object.team1
        }
        else if object.winnerTeam == "Team2" {
            lblWinnerTeam.text = "Winner = " +  object.team2
        }
        else{
            lblWinnerTeam.text = "Winner = " +  object.team3
        }
        
       
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        
        let storyBoard:UIStoryboard = UIStoryboard(name: "Match", bundle: nil)
        
        let object:MatchClass!
        if searchController.isActive && searchController.searchBar.text != "" {
            
            object = arrFilteredMatch[indexPath.row]
        }
        else
        {
            object = arrMatchList[(indexPath as NSIndexPath).row]
        }
        
        
        
        
        if object.isTest == 0
        {
            let matchVC = storyBoard.instantiateViewController(withIdentifier: "MatchViewController") as! MatchViewController
            
            matchVC.objMatch = object
            matchVC.isReanOnly = 1
            
            self.navigationController?.pushViewController(matchVC, animated: true)

        }
        else
        {
            let matchVC = storyBoard.instantiateViewController(withIdentifier: "TestMatchViewController") as! TestMatchViewController
            
            matchVC.objMatch = object
            matchVC.isReanOnly = 1
            
            self.navigationController?.pushViewController(matchVC, animated: true)
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        arrFilteredMatch = self.arrMatchList.filter({(objMatch:MatchClass) ->Bool in
            
            var isTest:Int32 = 0
            
            if scope == "Test Match"
            {
                isTest = 1
            }
            
            let categoryMatch = (scope == "All Match") || objMatch.isTest == isTest
            return categoryMatch && objMatch.matchDate.lowercased().contains(searchText.lowercased())
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

extension MatchReportViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension MatchReportViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
//        filterContentForSearchText(searchController.searchBar.text!)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)

    }
}

