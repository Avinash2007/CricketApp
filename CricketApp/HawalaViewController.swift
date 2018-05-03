//
//  HawalaViewController.swift
//  CricketApp
//
//  Created by Jeet Meghanathi on 12/12/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class HawalaViewController: UIViewController,GADBannerViewDelegate,GADInterstitialDelegate {
    
    var fromObjBookieGloble:Bookie!
    var toObjBookieGloble:Bookie!
    @IBOutlet weak var lblAmount:UILabel!
    @IBOutlet weak var txtRemarks:UITextField!
    @IBOutlet weak var txtParty:AutoCompleteTextField!
    @IBOutlet weak var txtAmount:UITextField!
    @IBOutlet weak var lblPartyName:UILabel!
    
    var objHawala:Hawala!
    var arrBookieList = [Bookie]()
    var filteredBookie = [Bookie]()
     var interstitial: GADInterstitial?
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.isFullVersion{
            // Request a Google Ad
            adBannerView.load(GADRequest())
            self.view.addSubview(adBannerView)
            interstitial = createAndLoadInterstitial()
        }
        
        Util.setFontOnLable(self.view)
        Util.setCornerRadius(self.view)
        
        Util.setBackgroundColor(self.view)
        
        let lblTitle = UILabel()
        lblTitle.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
        lblTitle.textAlignment = .center
        lblTitle.font = Util.setCustomNavigationMainTitleFont()
        lblTitle.textColor = .white
        lblTitle.text = fromObjBookieGloble.bookieName + " 's"
        
        
        let lblSubTitle = UILabel()
        lblSubTitle.frame = CGRect(x: 10, y: 20, width: 100, height: 20)
        lblSubTitle.textAlignment = .center
        lblSubTitle.font = Util.setCustomNavigationSubTitleFont()
        lblSubTitle.textColor = Util.setMainViewBGColor()
        
        lblSubTitle.text = "Hawala"
        
        
        
        
        let viewForNav = UIView()
        viewForNav.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        viewForNav.backgroundColor = .clear
        viewForNav.addSubview(lblTitle)
        viewForNav.addSubview(lblSubTitle)
        
        self.navigationItem.titleView = viewForNav
        

        lblAmount.text = String(format: "%.3f",fromObjBookieGloble.amount + fromObjBookieGloble.sessionCommissionRS + fromObjBookieGloble.ODICommissionRS + fromObjBookieGloble.testCommissionRS)
        
        configureTextField()
        handleTextFieldInterfaces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getBookieList()
        
        if objHawala !=  nil{
            
            var objBookieInner = Bookie()
            
            for bookie in arrBookieList{
                
                if bookie.bookieID == objHawala.toBookieID
                {
                    objBookieInner = bookie
                    break
                }
            }
            
            
            txtParty.text = objBookieInner.bookieName
            txtAmount.text = String(objHawala.amount)
            txtRemarks.text = objHawala.remarks
            if objHawala.toBookieID == fromObjBookieGloble.bookieID {
                lblPartyName.text = "From Party"
                let objBk = self.getBookieFromBookieID(uniqueId: objHawala.fromBookieID)
                txtParty.text = objBk.bookieName
            }
            
            let barBTNSave = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(self.btnAddClicked))
            self.navigationItem.rightBarButtonItem = barBTNSave
        }


        
    }
    
    func resignActiveTextField(){
        if txtRemarks.isFirstResponder{
            txtRemarks.resignFirstResponder()
        }
        else if txtAmount.isFirstResponder{
            txtAmount.resignFirstResponder()
        }
        else if txtParty.isFirstResponder{
            txtParty.resignFirstResponder()
        }
    }
   
    func getBookieList()
    {
        arrBookieList = ModelManager.getInstance().getAllBookieData(query: "SELECT * FROM BookieTBL ORDER BY BookieID ASC")
        
        
        var bk:Bookie!
        
        arrBookieList.remove(at: 1)
        
        for bookie in arrBookieList  {
            if bookie.bookieID == fromObjBookieGloble.bookieID{
                bk = bookie
            }
        }
         
        if let index = arrBookieList.index(of: bk){
            arrBookieList.remove(at: index)
        }
        
    
    }
    
    fileprivate func configureTextField(){
        txtParty.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        txtParty.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        txtParty.autoCompleteCellHeight = 35.0
        txtParty.maximumAutoCompleteCount = 20
        txtParty.hidesWhenSelected = true
        txtParty.hidesWhenEmpty = true
        txtParty.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        txtParty.autoCompleteAttributes = attributes
    }
    
    fileprivate func handleTextFieldInterfaces(){
        txtParty.onTextChange = {[weak self] text in
            if !text.isEmpty{
                self?.fetchAutocompletePlaces(text)
            }
        }
        
        txtParty.onSelect = {[weak self] text, indexpath in
            
            self?.toObjBookieGloble = self?.filteredBookie[indexpath.row]
            print((self?.toObjBookieGloble?.bookieName)! as String)
            
        }
    }
    fileprivate func fetchAutocompletePlaces(_ keyword:String) {
        
        filteredBookie = self.arrBookieList.filter({(objBookie:Bookie) ->Bool in
            return objBookie.bookieName.lowercased().contains(keyword.lowercased())
            
        })
        
        var arrBookieName = [String]()
        
        for objBookie in filteredBookie {
            
            arrBookieName.append(objBookie.bookieName)
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.txtParty.autoCompleteStrings = arrBookieName
        })
        return
        
        
    }

    
    @IBAction func btnAddClicked()
    {
        
        
        let isValidate = self.checkDetailofTextfield()
        
        if isValidate{
            
            if  objHawala == nil{
                    objHawala = Hawala()
            }
            
            objHawala.fromBookieID = fromObjBookieGloble.bookieID
            objHawala.amount = Double(txtAmount.text!)!
            objHawala.toBookieID = toObjBookieGloble.bookieID
            objHawala.remarks = txtRemarks.text!
            objHawala.hawalaDate = Util.stringFromDate(Date())
            let inserted = ModelManager.getInstance().addHawalaData(objHawala: objHawala)
            
            if inserted {
                
                
                let isUpdadated = self.applyAmountIntoBookieTable(havala: objHawala)
                
                if isUpdadated{
                    
                    let alert = UIAlertController(title: kAPPNAME, message: "Hawala entry created.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                        (action:UIAlertAction) in
                        self.txtParty.text = ""
                        self.txtAmount.text = ""
                        self.txtRemarks.text = ""
                        self.resignActiveTextField()
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    }))
                    showDetailViewController(alert, sender: self)
                }
                
            }

        }
    }
    
    func checkDetailofTextfield()->Bool{
        
        if txtParty.text == self.fromObjBookieGloble.bookieName{
            let alert = UIAlertController(title: kAPPNAME, message: "From Party and To Party should not be same.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            showDetailViewController(alert, sender: self)
            
            return false
        }
        else if txtParty.text == "" {
            let alert = UIAlertController(title: kAPPNAME, message: "Enter Valid Party Name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            showDetailViewController(alert, sender: self)
            return false

        }
        else if txtAmount.text == ""{
            let alert = UIAlertController(title: kAPPNAME, message: "Enter Valid Amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            showDetailViewController(alert, sender: self)
            return false

        }
        else
        {
            var isAvailBookie = false
            for bookie in arrBookieList {
                
                if bookie.bookieName == txtParty.text {
//                    objBookie = bookie
                    isAvailBookie = true
                    break;
                }
            }
            
            if !isAvailBookie {
                let alert = UIAlertController(title: kAPPNAME, message: "Enter Valid Party Name.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                showDetailViewController(alert, sender: self)
                return false
            }

        }
        
        
        return true
    }
    
    func getBookieFromBookieID(uniqueId: Int32)->Bookie {
        
        var objBookieInner:Bookie!
        for objBookieLocal in arrBookieList where objBookieLocal.bookieID == uniqueId
        {
            
            objBookieInner = objBookieLocal
            break
        }
        
        return objBookieInner
        
        
    }
    
    func applyAmountIntoBookieTable(havala:Hawala)->Bool{
        
        
        
        
        let objBookieFrom = self.getBookieFromBookieID(uniqueId: havala.fromBookieID)
        let objBookieTo = self.getBookieFromBookieID(uniqueId: havala.toBookieID)
        
        objBookieFrom.amount = objBookieFrom.amount + havala.amount
        objBookieTo.amount = objBookieTo.amount - havala.amount

        let isUpdatedFromBookie = ModelManager.getInstance().updateRecord("UPDATE BookieTBL SET Amount = \(objBookieFrom.amount) WHERE BookieID = \(objBookieFrom.bookieID)")
        let isUpdatedToBookie = ModelManager.getInstance().updateRecord("UPDATE BookieTBL SET Amount = \(objBookieTo.amount) WHERE BookieID = \(objBookieTo.bookieID)")

        if isUpdatedToBookie && isUpdatedFromBookie{
            return true
        }
        else{
                return false
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
