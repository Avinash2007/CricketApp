//
//  BookieViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 16/05/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class BookieViewController: UIViewController,GADBannerViewDelegate {

    var  arrBookieList = [Bookie]()
    var filteredBookie = [Bookie]()
    
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var tblView: UITableView!
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    
    //MARK: View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.barTintColor = Util.setSearchBarTintColor()
        searchController.searchBar.tintColor = Util.setNavigationBarColor()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getBookieData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Get Data FROM DB
    func getBookieData()
    {
        
        arrBookieList = ModelManager.getInstance().getAllBookieData(query: "SELECT * FROM BookieTBL ORDER BY BookieName ASC")
        if tblView.tableHeaderView == nil{
            tblView.tableHeaderView = searchController.searchBar
        }

        tblView.reloadData()
    }
    
    //MARK: ADD New Reocrd
   @IBAction func insertNewObject(_ sender: AnyObject) {
        let bookieDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BookieDetailViewController") as! BookieDetailViewController
        bookieDetailVC.arrBookie = arrBookieList
        self.navigationController?.pushViewController(bookieDetailVC, animated: true)
    }

   
    // MARK: - Table View

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredBookie.count
        }
        return arrBookieList.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Util.setCellBackgroundColor()
        cell.textLabel?.font = Util.setCellMainTitleFont()
        cell.textLabel?.textColor = Util.setCellMainTitleTextColor()
        cell.detailTextLabel?.font = Util.setCellMainTitleFont()
        cell.detailTextLabel?.textColor = Util.setCellMainTitleTextColor()
        
        var object = Bookie()
        if searchController.isActive && searchController.searchBar.text != "" {
            object = filteredBookie[(indexPath as NSIndexPath).row]
        }
        else
        {
            object = arrBookieList[(indexPath as NSIndexPath).row]
        }
        
        
        cell.textLabel!.text = object.bookieName
        cell.detailTextLabel?.text = object.city
        cell.textLabel?.backgroundColor = .clear
        cell.detailTextLabel?.backgroundColor = .clear
        return cell
    }
    
//     func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
    
     /*func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            
            var object = Bookie()
            if searchController.isActive && searchController.searchBar.text != "" {
                object = filteredBookie[(indexPath as NSIndexPath).row]
            }
            else
            {
                object = arrBookieList[(indexPath as NSIndexPath).row]
            }
            
            let isDeleted = ModelManager.getInstance().deleteBookieData(object)
            
            if isDeleted {
                Util.invokeAlertMethod("", strBody: "Record Deleted successfully.", delegate: nil)
            } else {
                Util.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
            }
            self.getBookieData()

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
 */
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        
        
        var object = Bookie()
        if searchController.isActive && searchController.searchBar.text != "" {
            object = filteredBookie[(indexPath as NSIndexPath).row]
        }
        else
        {
            object = arrBookieList[(indexPath as NSIndexPath).row]
        }
        
        
        if object.bookieID != 1 && object.bookieID != 2{
            let bookieDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BookieDetailViewController") as! BookieDetailViewController
            
            bookieDetailVC.objBookie = object
            bookieDetailVC.arrBookie = arrBookieList
            self.navigationController?.pushViewController(bookieDetailVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
    }
    
    
    func filterContentForSearchText(_ searchText: String) {

        filteredBookie = self.arrBookieList.filter({(objBookie:Bookie) ->Bool in
            return objBookie.bookieName.lowercased().contains(searchText.lowercased())
        })
        tblView.reloadData()
    }
    

}

extension BookieViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension BookieViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        //        tableView?.tableHeaderView?.frame = bannerView.frame
        //        tableView?.tableHeaderView = bannerView
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}
