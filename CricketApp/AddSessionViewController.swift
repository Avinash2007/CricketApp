//
//  AddSessionViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 12/06/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class AddSessionViewController: UIViewController,GADBannerViewDelegate,GADInterstitialDelegate {
    
    //MARK: User Interface
    
    @IBOutlet weak var txtTeamName:UITextField!
    @IBOutlet weak var txtSessionName:UITextField!
    @IBOutlet weak var switchCommi:UISwitch!
    @IBOutlet weak var btnAdd:UIButton!
    var objSession:Session!
    var isPresent:Int32 = 0
    var interstitial: GADInterstitial?
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    // MARK: View Controller Methods
    
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
        
        if objSession != nil {
            
            txtSessionName.text = objSession.sessionName
            txtTeamName.text = objSession.teamName
            
            if objSession.isCommi == 1 {
                switchCommi.setOn(true, animated: false)
            }
            else
            {
                switchCommi.setOn(false, animated: false)
            }
            
            btnAdd.setTitle("Save", for: UIControlState())
        }
        else
        {
             switchCommi.setOn(true, animated: false)
            
            if isPresent  == 1{
                
                let barButtonDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.btnDoneClicked))
                
                self.navigationItem.rightBarButtonItem = barButtonDone
                
            }
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func btnDoneClicked(){
        
        if txtSessionName.text == "" || txtTeamName.text == "" {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        else{
            self.addSession(btnAdd)
        }
        
    }
    
    @IBAction func addSession(_ sender:AnyObject)
    {
        
        if txtTeamName.text == "" {
            let alert = UIAlertController(title: kAPPNAME, message: "Please Enter Team Name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (action:UIAlertAction) in
                
                self.txtTeamName.becomeFirstResponder()
            
                
            }))
            showDetailViewController(alert, sender: self)
            return
        }else if txtSessionName.text == "" {
            let alert = UIAlertController(title: kAPPNAME, message: "Please Enter Session Name.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (action:UIAlertAction) in
                
                self.txtSessionName.becomeFirstResponder()
                
                
            }))
            showDetailViewController(alert, sender: self)
            return
        }
        
        
        if objSession != nil
        {
            
            objSession.teamName = txtTeamName.text!
            objSession.sessionName = txtSessionName.text!
            
            if switchCommi.isOn {
                objSession.isCommi = 1
            }
            else
            {
                objSession.isCommi = 0
            }
            
            objSession.isActive = 1
            
              let strQuery = String(format: "UPDATE SessionTBL SET SessionName='%@', TeamName='%@', isCommi='%d', isActive='%d'  WHERE SessionID ='%d'", arguments: [objSession.sessionName,objSession.teamName,objSession.isCommi,objSession.isActive,objSession.sessionID])
            
            let isUpdated = ModelManager.getInstance().updateSessoionName(strQuery)
            
            
            if isUpdated {
                let appDel = UIApplication.shared.delegate as! AppDelegate
                appDel.isUpdatedSession = true
                let alert = UIAlertController(title: kAPPNAME, message: "Record Updated successfully.", preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "OK", style: .default, handler:{ (action:UIAlertAction) in
                    
                    if self.isPresent == 1 {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                    else{
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                })
                alert.addAction(alertAction)
                showDetailViewController(alert, sender: self)
            }
        }
        else
        {
            
            objSession = Session()
            
            objSession.teamName = txtTeamName.text!
            objSession.sessionName = txtSessionName.text!
            
            if switchCommi.isOn {
                objSession.isCommi = 1
            }
            else
            {
                objSession.isCommi = 0
            }
            
            objSession.isActive = 1
            
            objSession.sessionDate = Util.stringFromDate(Date())
            
            let isInserted = ModelManager.getInstance().addSessionName(objSession)
            
            if isInserted {
                
                self.resignKeyBoardFromScreen()
                
                let alert = UIAlertController(title: kAPPNAME, message: "Session added successfully.", preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "OK", style: .default, handler:{ (action:UIAlertAction) in
                   
                    if self.isPresent == 1 {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                    else{
                        _ = self.navigationController?.popViewController(animated: true)
                        
                    }
                    
                    })
                alert.addAction(alertAction)
                showDetailViewController(alert, sender: self)
            }
        }
    }
   
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            if touch.view == self.view{
                self.resignKeyBoardFromScreen()
               
            }            
        }
        
    }
    
    func resignKeyBoardFromScreen(){
        if txtTeamName.isFirstResponder{
            txtTeamName.resignFirstResponder()
        }
        else if txtSessionName.isFirstResponder{
            txtSessionName.resignFirstResponder()
        }
    }
    
    // MARK: - GADBannerViewDelegate methods
    
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
