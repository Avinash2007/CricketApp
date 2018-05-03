//
//  BookieDetailViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 17/05/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class BookieDetailViewController: UIViewController,GADBannerViewDelegate,GADInterstitialDelegate {
    
    
    //MARK: User Interface
    
    @IBOutlet weak var txtBookieName: UITextField!
    @IBOutlet weak var txtCity:UITextField!
    @IBOutlet weak var txtPhone:UITextField!
    @IBOutlet weak var txtEmail:UITextField!
    @IBOutlet weak var txtSessionCommi:UITextField!
    @IBOutlet weak var txtODICommi:UITextField!
    @IBOutlet weak var txtTestCommi:UITextField!
    

    
    var txtActive:UITextField!
    var interstitial: GADInterstitial?
    //MARK: Globle Variables for Controller
    var objBookie: Bookie!
    var isPresent:Int32 = 0
    var arrBookie = [Bookie]()
    var isDone = false
    
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    //MARK: ViewController Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.isFullVersion{
            // Request a Google Ad
            adBannerView.load(GADRequest())
            self.view.addSubview(adBannerView)
            interstitial = createAndLoadInterstitial()
        }
        
        
        
        Util.setFontOnLable(self.view)
        Util.setCornerRadius(self.view)
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        
        if objBookie != nil {
            
//            btnAdd .setTitle("Save", for:UIControlState())
            
            
            txtBookieName.text = objBookie.bookieName as String
            txtCity.text = objBookie.city as String
            txtPhone.text = objBookie.bookiePhone as String
            txtEmail.text = objBookie.bookieEmail as String
            txtSessionCommi.text = String(objBookie.sessionCommission)
            txtODICommi.text = String(objBookie.ODICommission)
            txtTestCommi.text = String(objBookie.testCommission)
            
            let barButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.btnAddClicked))
            self.navigationItem.rightBarButtonItem = barButton
        }
        
        if isPresent == 1 {
            let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(BookieDetailViewController.btnDoneClicked))
            self.navigationItem.rightBarButtonItem = btnDone
        }
        
//        txtBookieName.becomeFirstResponder()
        
       
        
        txtActive = txtBookieName
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: IBAction Methods
    
    func btnDoneClicked(){
        
        if txtBookieName.text != "" {
            isDone = true
            self.btnAddClicked()
        }
        else
        {
            if (txtActive?.isFirstResponder)!{
                txtActive?.resignFirstResponder()
            }
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        
    }
    @IBAction func btnAddClicked()
    {
        
        if txtBookieName.text == "" {
            let alert = UIAlertController(title: kAPPNAME, message: "Please add party name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            showDetailViewController(alert, sender: self)
            
            return
        }
        
        
        
        let name:String = txtBookieName.text!
        
        let isRecordAvail:Bool
        
        if (objBookie == nil)
        {
            objBookie = Bookie()
            objBookie.amount = 0.0
            isRecordAvail = self.showAlertMessage(query: "SELECT BookieName FROM BookieTBL WHERE UPPER(BookieName) = UPPER('\(name)')")
            
            
            if isRecordAvail {
                return
            }
            
            self.fillValueInObject()
         
            let isInserted = ModelManager.getInstance().addBookieData(objBookie)
            
            
            if isInserted {
                
                if self.isDone{
                    
                    if (self.txtActive?.isFirstResponder)!{
                        self.txtActive?.resignFirstResponder()
                    }
                }
                
                let alert = UIAlertController(title: kAPPNAME, message: "Party added successfully.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction) in
                    
                    if self.isDone{
                        
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                    else
                    {
                        self.txtBookieName.text = ""
                        self.txtCity.text = ""
                        self.txtEmail.text = ""
                        self.txtPhone.text = ""
                        self.txtODICommi.text = ""
                        self.txtTestCommi.text = ""
                        self.txtSessionCommi.text = ""
                        
                        self.txtBookieName.becomeFirstResponder()
                        self.objBookie = nil
                        
                    }
                    
                }))
                
                showDetailViewController(alert, sender: self)
                
            }

        }
        else
        {
            
            isRecordAvail = self.showAlertMessage(query: "SELECT BookieName FROM BookieTBL WHERE UPPER(BookieName) = UPPER('\(name)') AND  BookieID <> \(objBookie.bookieID) COLLATE NOCASE")
            
            if isRecordAvail {
                return
            }
            
             self.fillValueInObject()
            
            let isUpdated = ModelManager.getInstance().updateBookieData(objBookie)
            
            if txtActive.isFirstResponder {
                txtActive.resignFirstResponder()
            }
            
            if isUpdated {
                
                let alert = UIAlertController(title: kAPPNAME, message: "Record Updated successfully.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction) in
                    
                    _ = self.navigationController?.popViewController(animated: true)
                }))
                 showDetailViewController(alert, sender: self)
            }
            
        }
        
    }
    
    func showAlertMessage(query:String) -> Bool{
        
        let isAvailRecord = ModelManager.getInstance().getBookieName(strQuary: query)
        
        
        if isAvailRecord {
            
            let alert = UIAlertController(title: kAPPNAME, message: "Name already exist! Please change the name.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            showDetailViewController(alert, sender: self)
         
           
        }

        return isAvailRecord
    }
    
    func fillValueInObject(){
        objBookie.bookieName = txtBookieName.text!
        objBookie.bookieDate = Util.stringFromDate(Date())
        
        
        objBookie.bookiePhone = txtPhone.text!
        objBookie.bookieEmail = txtEmail.text!
        objBookie.city = txtCity.text!
        
        
        if txtSessionCommi.text == "" {
            objBookie.sessionCommission = 0.0
        }
        else
        {
            objBookie.sessionCommission = Double(txtSessionCommi.text!)!
        }
        
        if txtODICommi.text == "" {
            objBookie.ODICommission = 0.0
        }
        else
        {
            objBookie.ODICommission = Double(txtODICommi.text!)!
        }
        
        if txtTestCommi.text == "" {
            objBookie.testCommission = 0.0
        }
        else
        {
            objBookie.testCommission = Double(txtTestCommi.text!)!
        }

    }
    
    //MARK: Textfield Delegate
    
    public func textFieldDidBeginEditing(_ textField: UITextField)
    {
        txtActive = textField
    }
//    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
//        txtActive = textField
//        return true
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            if touch.view == self.view{
                
                if txtActive.isFirstResponder{
                    txtActive.resignFirstResponder()
                }
            }
        }
        
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
    
    
    // MARK: - GADInterstitialDelegate methods
    
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: Util.getInterstitialID())
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        request.testDevices = [ kGADSimulatorID ]
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Interstitial loaded successfully")
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        //        print("Will Dismiss")
        
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("Did Dismiss")
        
        
    }
   
}
