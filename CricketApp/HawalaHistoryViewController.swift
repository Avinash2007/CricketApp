 //
//  HawalaHistoryViewController.swift
//  CricketApp
//
//  Created by Jeet Meghanathi on 14/12/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class HawalaHistoryViewController: UIViewController,GADBannerViewDelegate {
    
    var arrHawala = [Hawala]()
    var arrFilteredHawala = [Hawala]()
    var objBookie:Bookie!
    var arrBookieList = [Bookie]()
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var lblMessage:UILabel!
    
     let searchController = UISearchController(searchResultsController: nil)
    
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
        lblMessage.font = Util.setLableMessageFont()
        lblMessage.textColor = Util.setNavigationBarColor()

        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.barTintColor = Util.setSearchBarTintColor()
        searchController.searchBar.tintColor = Util.setNavigationBarColor()
        searchController.searchBar.scopeButtonTitles = ["Party Name", "Date"]
        
        
        self.title = objBookie.bookieName + "'s Hawala"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getBookieList()
        self.getHawala()
        
        
//        if objHawala !=  nil{
//            
//            var objBookieInner = Bookie()
//            
//            for bookie in arrBookieList{
//                
//                if bookie.bookieID == objHawala.toBookieID
//                {
//                    objBookieInner = bookie
//                    break
//                }
//            }
//            
//            
//            txtParty.text = objBookieInner.bookieName
//            txtAmount.text = String(objHawala.amount)
//            txtRemarks.text = objHawala.remarks
//        }
        
       
    }
    
    func getBookieList()
    {
        arrBookieList = ModelManager.getInstance().getAllBookieData(query: "SELECT * FROM BookieTBL ORDER BY BookieName ASC")
        
    }
    func getHawala(){
        
        arrHawala = ModelManager.getInstance().getHawalaDetail(query: "SELECT * FROM HawalaTBL WHERE FromBookieID = \(objBookie.bookieID) OR ToBookieID = \(objBookie.bookieID)  ORDER BY HawalaID DESC")
        
        
        
        for i in 0..<arrHawala.count{
            
            let objHawala = arrHawala[i]
            
            if objHawala.fromBookieID == objBookie.bookieID {
                objHawala.bookieName = self.getBookieFromBookieID(uniqueId: objHawala.toBookieID).bookieName
            }
            else
            {
                objHawala.bookieName = self.getBookieFromBookieID(uniqueId: objHawala.fromBookieID).bookieName
            }
            
            print(objHawala.bookieName)
        }
        
        if arrHawala.count == 0 {
            lblMessage.isHidden = false
            tblView.isHidden = true
        }
        else
        {
            lblMessage.isHidden = true
            tblView.isHidden = false
            if tblView.tableHeaderView == nil{
                tblView.tableHeaderView = searchController.searchBar
            }
            
            tblView.reloadData()
        }
        
    }
    
    @IBAction func btnAddClicked(){
     
        let hawalaVC = self.storyboard?.instantiateViewController(withIdentifier: "HawalaViewController") as! HawalaViewController
        hawalaVC.fromObjBookieGloble = objBookie

        self.navigationController?.pushViewController(hawalaVC, animated: true)

    }
    
    func getBookieFromBookieID(uniqueId: Int32)->Bookie {
        
        let obj = arrBookieList.first(where: {
            $0.bookieID == uniqueId
        })
        
        return obj!
        
    }
    
    // MARK: UITableview Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return arrFilteredHawala.count
        }
        else{
            return arrHawala.count
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = Util.setCellBackgroundColor()
        cell.textLabel?.font = Util.setCellMainTitleFont()
        cell.textLabel?.textColor = Util.setCellMainTitleTextColor()
        cell.textLabel?.backgroundColor = .clear
        cell.detailTextLabel?.backgroundColor = .clear
        
        let lblDate = cell.contentView.viewWithTag(111) as! UILabel
        lblDate.font = Util.setCellMainTitleFont()
        lblDate.textColor = Util.setCellMainTitleTextColor()
        lblDate.backgroundColor = .clear
        
        
        
        cell.detailTextLabel?.font = Util.setCellSubTitleFont()
        cell.detailTextLabel?.textColor = Util.setCellSubTitleTextColor()

        var objHawala = Hawala()
        
        if searchController.isActive && searchController.searchBar.text != "" {
                objHawala = arrFilteredHawala[indexPath.row]
        }
        else{
            objHawala = arrHawala[indexPath.row]
            
        }
        
        
        if objHawala.fromBookieID == objBookie.bookieID {
            
//            let objBookieInner = self.getBookieFromBookieID(uniqueId: objHawala.toBookieID)
            
            cell.textLabel!.text = "To -> " + objHawala.bookieName + "  " + String(objHawala.amount)
        }
        else
        {
//            let objBookieInner = self.getBookieFromBookieID(uniqueId: objHawala.fromBookieID)
            
            cell.textLabel!.text = "From -> " + objHawala.bookieName + "  " + String(objHawala.amount)
        }
        cell.detailTextLabel?.text = objHawala.remarks
        lblDate.text = objHawala.hawalaDate
//        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
     
       /* let hawalaVC = self.storyboard?.instantiateViewController(withIdentifier: "HawalaViewController") as! HawalaViewController
        hawalaVC.fromObjBookieGloble = objBookie
        hawalaVC.objHawala = arrHawala[indexPath.row]
        
        self.navigationController?.pushViewController(hawalaVC, animated: true)

        */
        tblView.deselectRow(at: indexPath, animated: true)
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        arrFilteredHawala = self.arrHawala.filter({(objHawala:Hawala) ->Bool in
            
            print(scope)
            if scope == "Party Name"{
                return objHawala.bookieName.lowercased().contains(searchText.lowercased())
            }
            else{
                return objHawala.hawalaDate.lowercased().contains(searchText.lowercased())
            }
            
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
 
 extension HawalaHistoryViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
 }
 
 extension HawalaHistoryViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
//        filterContentForSearchText(searchController.searchBar.text!)
        
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)

    }
 }

