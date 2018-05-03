//
//  ODIDetailViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 09/06/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class ODIDetailViewController: UIViewController,GADBannerViewDelegate,GADInterstitialDelegate {
    
   
    @IBOutlet weak var txtTeam1:UITextField!
    @IBOutlet weak var txtTeam2:UITextField!
    @IBOutlet weak var txtTeam3:UITextField!
    @IBOutlet weak var switchCommi:UISwitch!
    @IBOutlet weak var btnAdd:UIButton!
    @IBOutlet weak var lblTeam3:UILabel!
    
    var objMatch:MatchClass!
    var isTest:Bool = Bool()
    var txtGloble:UITextField!
    var interstitial: GADInterstitial?
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    // MARK: Controller Methods
    
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
        
        if isTest == false {
            txtTeam3.isHidden = true
            lblTeam3.isHidden = true
        }
        else{
            txtTeam3.text = "Draw"
            txtTeam3.isEnabled = false
        }
        
        
        if objMatch != nil{
            txtTeam1.text = objMatch.team1
            txtTeam2.text = objMatch.team2
            
            if objMatch.isCommi == 1 {
                    switchCommi.setOn(true, animated: false)
            }
            else
            {
                switchCommi.setOn(false, animated: false)
            }
            
            btnAdd .setTitle("Save", for: UIControlState())
        }
        else{
             switchCommi.setOn(false, animated: false)
//            txtTeam1.becomeFirstResponder()
        }
        
        txtGloble = txtTeam2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
  
    @IBAction func addTeam(_ sender:AnyObject)
    {
        if txtTeam1.text == "" {
            Util.invokeAlertMethod("Alert", strBody: "Please Team 1 name.", delegate: nil)
            return
        }
        else if txtTeam2.text == ""{
            Util.invokeAlertMethod("Alert", strBody: "Please Team 2 name.", delegate: nil)
            return
        }
        
        if objMatch != nil
        {
            
            objMatch.team1 = txtTeam1.text!
            objMatch.team2 = txtTeam2.text!
            
            if isTest == true {
                objMatch.team3 = txtTeam3.text!
                objMatch.isTest = 1
            }
            else
            {
                objMatch.isTest = 0
            }
            
            if switchCommi.isOn {
                objMatch.isCommi = 1
            }
            else
            {
                objMatch.isCommi = 0
            }
            
            objMatch.isActive = 1
            
            
            let isUpdated = ModelManager.getInstance().updateMatchData(objMatch)
            
            if isUpdated {
                self.resignActiveKeyboard()
                
                let alert = UIAlertController(title: kAPPNAME, message: "Match Updated successfully.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction) in
                    let appDel = UIApplication.shared.delegate as! AppDelegate
                    if self.isTest == false {
                        
                        appDel.isUpdateODIMatch = true
                    }
                    else
                    {
                        appDel.isUpdateTestMatch = true
                    }
                    
                    _ = self.navigationController?.popViewController(animated: true)
                    
                    
                }))
                
                showDetailViewController(alert, sender: self)
//                Util.invokeAlertMethod("", strBody: "Match Updated successfully.", delegate: nil)
            } else {
                Util.invokeAlertMethod("", strBody: "Error in updating record.", delegate: nil)
            }

        }
        else
        {
            
            objMatch = MatchClass()
            
            objMatch.team1 = txtTeam1.text!
            objMatch.team2 = txtTeam2.text!
            
            if isTest == true {
                objMatch.team3 = txtTeam3.text!
                objMatch.isTest = 1
            }
            else
            {
                objMatch.isTest = 0
            }

            
            if switchCommi.isOn {
                objMatch.isCommi = 1
            }
            else
            {
                objMatch.isCommi = 0
            }
            
            objMatch.isActive = 1
            
            objMatch.matchDate = Util.stringFromDate(Date())
            
            let isInserted = ModelManager.getInstance().addMatchData(objMatch)
            
            if isInserted {
                
                self.resignActiveKeyboard()
                
                let alert = UIAlertController(title: kAPPNAME, message: "Match Added successfully.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (action:UIAlertAction) in
                    
                    _ = self.navigationController?.popViewController(animated: true)
                    

                }))
                
                showDetailViewController(alert, sender: self)
                
//                Util.invokeAlertMethod("", strBody: "Match Added successfully.", delegate: nil)
            } else {
                Util.invokeAlertMethod("", strBody: "Error in Inserting record.", delegate: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            // do something with your currentPoint
            if touch.view == self.view{
                 self.resignActiveKeyboard()
                
            }
           
        }
        
    }
    
    func resignActiveKeyboard()
    {
        if txtTeam1.isFirstResponder{
            txtTeam1.resignFirstResponder()
        }
        else if txtTeam2.isFirstResponder{
            txtTeam2.resignFirstResponder()
        }
        else if txtTeam3.isFirstResponder{
            txtTeam3.resignFirstResponder()
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
