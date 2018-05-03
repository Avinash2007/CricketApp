//
//  BookieReportViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 16/07/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class BookieReportViewController: UIViewController,GADBannerViewDelegate {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var viewHeader:UIView!
    var arrList = [Bookie]()
    var filteredBookie = [Bookie]()
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
                adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    
     let searchController = UISearchController(searchResultsController: nil)
    var isHawala = Bool()
    //MARK: View Controller Methods
    
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
        Util.setLableTitleOnTableHeader(myView: viewHeader)
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.barTintColor = Util.setSearchBarTintColor()
        searchController.searchBar.tintColor = Util.setNavigationBarColor()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getPartyFromDB()
        
    }
    
    func getPartyFromDB(){
        
        arrList = ModelManager.getInstance().getAllBookieData(query: "SELECT * FROM BookieTBL ORDER BY BookieName ASC")
        
        if tblView.tableHeaderView == nil{
            tblView.tableHeaderView = searchController.searchBar
        }
        
        tblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredBookie.count
        }

        
        return arrList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if isHawala{
            return 0.0
        }
        else
        {
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if isHawala{
            return UIView()
        }
        else
        {
            return viewHeader
        }
//        if !searchController.isActive{
        
//        }
        
//        return UIView()
    }
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Util.setCellBackgroundColor()
        
        if isHawala{
            let lblName = cell.contentView.viewWithTag(111) as! UILabel
            let lblAmount = cell.contentView.viewWithTag(113) as! UILabel
            let lblTemp = cell.contentView.viewWithTag(112) as! UILabel
            
            lblTemp.isHidden = true
            
            lblName.backgroundColor = .clear
            lblAmount.backgroundColor = .clear
            
            lblName.textColor = Util.setCellMainTitleTextColor()
            lblAmount.textColor = Util.setCellMainTitleTextColor()
            
            
            lblName.font = Util.setCellMainTitleFont()
            lblAmount.font = Util.setCellMainTitleFont()
            
            
            var object = Bookie()
            if searchController.isActive && searchController.searchBar.text != "" {
                object = filteredBookie[(indexPath as NSIndexPath).row]
            }
            else
            {
                object = arrList[(indexPath as NSIndexPath).row]
            }
            
            
            
            lblName.text = object.bookieName
//            if object.bookieID == kBOOKID{
                lblAmount.text = String(format: "%.3f",object.amount + object.sessionCommissionRS + object.ODICommissionRS + object.testCommissionRS)
//            }
//            else
//            {
//                lblAmount.text = String(format: "%.3f",object.amount - object.sessionCommissionRS - object.ODICommissionRS - object.testCommissionRS)
//            }
        }
        else
        {
            let lblName = cell.contentView.viewWithTag(111) as! UILabel
            let lblAmount = cell.contentView.viewWithTag(112) as! UILabel
            let lblCommi = cell.contentView.viewWithTag(113) as! UILabel
            
            
            lblName.backgroundColor = .clear
            lblAmount.backgroundColor = .clear
            lblCommi.backgroundColor = .clear
            
            lblName.textColor = Util.setCellMainTitleTextColor()
            lblAmount.textColor = Util.setCellMainTitleTextColor()
            lblCommi.textColor = Util.setCellMainTitleTextColor()
            
            
            lblName.font = Util.setCellMainTitleFont()
            lblAmount.font = Util.setCellMainTitleFont()
            lblCommi.font = Util.setCellMainTitleFont()
            
            
            var object = Bookie()
            if searchController.isActive && searchController.searchBar.text != "" {
                object = filteredBookie[(indexPath as NSIndexPath).row]
            }
            else
            {
                object = arrList[(indexPath as NSIndexPath).row]
            }
            
            
            
            lblName.text = object.bookieName
            
           // if object.bookieID == kBOOKID{
                lblAmount.text = String(format: "%.3f",object.totalAmount + object.sessionCommissionRS + object.ODICommissionRS + object.testCommissionRS)
//            }
//            else
//            {
//                lblAmount.text = String(format: "%.3f",object.amount - object.sessionCommissionRS - object.ODICommissionRS - object.testCommissionRS)
//            }
            
            lblCommi.text = String(format: "%.3f",object.sessionCommissionRS + object.ODICommissionRS + object.testCommissionRS)
        }

        
//        cell.textLabel!.text = object.bookieName as String + "          " + String(format: "%.3f",object.amount + object.sessionCommissionRS) + "      " + String(format: "%.3f",object.sessionCommissionRS)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
    
        let storyBoard:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
        
        var object = Bookie()
        if searchController.isActive && searchController.searchBar.text != "" {
            object = filteredBookie[(indexPath as NSIndexPath).row]
        }
        else
        {
            object = arrList[(indexPath as NSIndexPath).row]
        }
        
        if object.bookieID != kBOOKID {
            if isHawala {
                
                
                let storyBoardSetting = UIStoryboard(name: "Settings", bundle: nil)
                
                let objHawalaHistroyVC = storyBoardSetting.instantiateViewController(withIdentifier: "HawalaHistoryViewController") as! HawalaHistoryViewController
                objHawalaHistroyVC.objBookie = object
                self.navigationController?.pushViewController(objHawalaHistroyVC, animated: true)
                
            }
            else
            {
                let bookieFullReportVC = storyBoard.instantiateViewController(withIdentifier: "BookieFullReportViewController") as! BookieFullReportViewController
                bookieFullReportVC.objBookie = object
                
                self.navigationController?.pushViewController(bookieFullReportVC, animated: true)
            }

        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func filterContentForSearchText(_ searchText: String) {
        
        filteredBookie = self.arrList.filter({(objBookie:Bookie) ->Bool in
            return objBookie.bookieName.lowercased().contains(searchText.lowercased())
        })
        tblView.reloadData()
    }
    
    // MARK: - GADBannerViewDelegate methods
    
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

extension BookieReportViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension BookieReportViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

