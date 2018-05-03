//
//  SessionDetailViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 31/05/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class SessionDetailViewController: UIViewController,GADBannerViewDelegate {
    
    var arrBookieList = [Bookie]()
    var filteredBookie = [Bookie]()
    var objSession:Session!
    var objSesionDetail:SessionSoda!
    
    @IBOutlet var segmentRun:UISegmentedControl!

    
    @IBOutlet var txtRun:UITextField!
    @IBOutlet var txtAmount:UITextField!
    @IBOutlet var txtBhav:UITextField!
    @IBOutlet var txtPartyName:AutoCompleteTextField!
   
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    
    //MARK: ViewControllers Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.isFullVersion{
            // Request a Google Ad
            adBannerView.load(GADRequest())
            self.view.addSubview(adBannerView)
        }
        
        Util.setFontOnLable(self.view)
        Util.setCornerRadius(self.view)
        Util.setBackgroundColor(self.view)
        
        txtBhav.text = "100"
        
        if objSesionDetail != nil {
            txtRun.text = String(objSesionDetail.Run)
            txtAmount.text = String(objSesionDetail.amount)
            txtBhav.text = String(objSesionDetail.bhav)
            
            
            if objSesionDetail.thay == 1 {
                segmentRun.selectedSegmentIndex = 0
            }
            else
            {
                segmentRun.selectedSegmentIndex = 1
            }
            
            let barBTNSave = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.btnAddClicked))
            self.navigationItem.rightBarButtonItem = barBTNSave

            
        }
        
        configureTextField()
        handleTextFieldInterfaces()


       


    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        if appDel.isDeletedSession {
            appDel.isDeletedSession = false
            _ = self.navigationController?.popToRootViewController(animated: true)
            
            return
        }
        
        if appDel.isUpdatedSession {
            appDel.isUpdatedSession = false
            _ = self.navigationController?.popToRootViewController(animated: true)
            
            return
        }
        
        self.getBookieList()
       
        if objSesionDetail != nil {
            for bookie in arrBookieList {
                
                if bookie.bookieID == objSesionDetail.bookieID{
                    txtPartyName.text = bookie.bookieName
                    break;
                }
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tapOnInnerView()
    }
    
    fileprivate func configureTextField(){
        txtPartyName.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        txtPartyName.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        txtPartyName.autoCompleteCellHeight = 35.0
        txtPartyName.maximumAutoCompleteCount = 20
        txtPartyName.hidesWhenSelected = true
        txtPartyName.hidesWhenEmpty = true
        txtPartyName.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        txtPartyName.autoCompleteAttributes = attributes
    }
    
    fileprivate func handleTextFieldInterfaces(){
        txtPartyName.onTextChange = {[weak self] text in
            if !text.isEmpty{
                self?.fetchAutocompletePlaces(text)
            }
        }
        
        txtPartyName.onSelect = {[weak self] text, indexpath in
            
            let objBookie = self?.filteredBookie[indexpath.row]
            print((objBookie?.bookieName)! as String)
            
        }
    }
    
    
    func tapOnInnerView(){
        if txtRun.isFirstResponder {
            txtRun.resignFirstResponder()
        }
        else if txtAmount.isFirstResponder {
            txtAmount.resignFirstResponder()
        }
        else if txtBhav.isFirstResponder {
            txtBhav.resignFirstResponder()
        }
        else if txtPartyName.isFirstResponder{
            txtPartyName.resignFirstResponder()
        }
    }
    
    func getBookieList()
    {
        arrBookieList = ModelManager.getInstance().getAllBookieData(query: "SELECT * FROM BookieTBL ORDER BY BookieID ASC")
        
        arrBookieList.removeFirst()
        arrBookieList.removeFirst()
        
        
        
        if arrBookieList.count == 0 {
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.showAlert), userInfo: nil, repeats: false)
        }
       
        

        
    }
    
    func showAlert()
    {
        
        let alert = UIAlertController(title: kAPPNAME, message: "Please add party first.", preferredStyle: .alert)
        
        let actionOK = UIAlertAction(title: "OK", style: .default, handler: {
            (action:UIAlertAction) in
            self.openBookieViewController()
        })
        
        alert.addAction(actionOK)
        showDetailViewController(alert, sender: self)
    }

    func openBookieViewController(){
        let storyBoardMain:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let bookieDetailVC = storyBoardMain.instantiateViewController(withIdentifier: "BookieDetailViewController") as! BookieDetailViewController
        
        bookieDetailVC.isPresent = 1
        
        let navController = UINavigationController.init(rootViewController: bookieDetailVC)
        
        navController.navigationBar.barTintColor =  Util.setNavigationBarColor()
        navController.navigationBar.tintColor = UIColor.white
        navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.present(navController, animated:true, completion: nil)
    }
    
    //MARK: IBAction Methods
    
    
    
    @IBAction func btnAddClicked()
    {
        
        var objBookie = Bookie()
        
        if txtRun.text == "" {
            let alert = UIAlertController(title: kAPPNAME, message: "Please Enter Run.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (action:UIAlertAction) in
                self.txtRun.becomeFirstResponder()
            }))
            showDetailViewController(alert, sender: self)
            
            return
        }
        else if txtAmount.text == "" {
            
            let alert = UIAlertController(title: kAPPNAME, message: "Please Enter Amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (action:UIAlertAction) in
                self.txtAmount.becomeFirstResponder()
            }))
            showDetailViewController(alert, sender: self)
            
            return
        }
        else if txtBhav.text == "" {
            let alert = UIAlertController(title: kAPPNAME, message: "Please Enter Bhav.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (action:UIAlertAction) in
                self.txtBhav.becomeFirstResponder()
            }))
            showDetailViewController(alert, sender: self)
            
            return
        }
        else{
            
            var isAvailBookie = false
            for bookie in arrBookieList {
                
                if bookie.bookieName == txtPartyName.text {
                    objBookie = bookie
                    isAvailBookie = true
                    break;
                }
            }
            
            if !isAvailBookie {
                let alert = UIAlertController(title: kAPPNAME, message: "Enter Valid Party Name.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                showDetailViewController(alert, sender: self)
                return
            }
            
        }
        
      
        
        if objSesionDetail != nil {
            
            objSesionDetail.Run = Int32(txtRun.text!)!
            objSesionDetail.amount = Double(txtAmount.text!)!
            objSesionDetail.bhav = Double(txtBhav.text!)!
            
            objSesionDetail.bookieID = objBookie.bookieID
            objSesionDetail.sessionID = objSession.sessionID
            
            if segmentRun.selectedSegmentIndex == 0 {
                objSesionDetail.thay = 1
            }
            else
            {
                objSesionDetail.thay = 0
            }
            
            
            if objSession.isCommi == 1 {
                objSesionDetail.commision = objBookie.sessionCommission
            }            
            let isUpdated = ModelManager.getInstance().updateSessionDetailData(objSesionDetail)
            
            if isUpdated
            {
                
                let alert = UIAlertController(title: kAPPNAME, message: "Soda Updated successfully.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction) in
                     _ = self.navigationController?.popViewController(animated: true)
                }))
                showDetailViewController(alert, sender: self)
                
            }
        }
        else
        {
            
            
            let objSessionDetail = SessionSoda()
            
            objSessionDetail.Run = Int32(txtRun.text!)!
            objSessionDetail.amount = Double(txtAmount.text!)!
            objSessionDetail.bhav = Double(txtBhav.text!)!
            
            objSessionDetail.bookieID = objBookie.bookieID
            objSessionDetail.sessionID = objSession.sessionID
            
            if objSession.isCommi == 1 {
                objSessionDetail.commision = objBookie.sessionCommission
            }
            
            
            if segmentRun.selectedSegmentIndex == 0 {
                objSessionDetail.thay = 1
            }
            else
            {
                objSessionDetail.thay = 0
            }

            
            objSessionDetail.sessionSodaDate = Util.timeAsStringFromDate(Date())
            
            let isInserted = ModelManager.getInstance().addSessionDetailData(objSessionDetail)
            
            if isInserted {
                
                let alert = UIAlertController(title: kAPPNAME, message: "Soda added successfully.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction) in
                    
                        self.txtBhav.text = "100"
                        self.txtAmount.text = ""
                        self.txtRun.text = ""
                        self.txtPartyName.text = ""
                        self.txtPartyName.becomeFirstResponder()
                        self.segmentRun.selectedSegmentIndex = 0
                    
                }))
                showDetailViewController(alert, sender: self)
                
            }
        }
        
        
    }

//    func filterContentForSearchText(_ searchText: String) {
//        
//        filteredBookie = self.arrList.filter({(objBookie:Bookie) ->Bool in
//            return objBookie.bookieName.lowercased().contains(searchText.lowercased())
//        })
//        tblView.reloadData()
//    }

    
    fileprivate func fetchAutocompletePlaces(_ keyword:String) {
        
        filteredBookie = self.arrBookieList.filter({(objBookie:Bookie) ->Bool in
            return objBookie.bookieName.lowercased().contains(keyword.lowercased())
            
        })
        
        var arrBookieName = [String]()
        
        for objBookie in filteredBookie {
            
            arrBookieName.append(objBookie.bookieName)
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.txtPartyName.autoCompleteStrings = arrBookieName
        })
        return
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            if touch.view == self.view{
                self.tapOnInnerView()
                
            }
        }
        
    }
    
    //MARK: TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtRun {
            
            if range.location > 2 {
                return false
            }
        }
        
        return true
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
