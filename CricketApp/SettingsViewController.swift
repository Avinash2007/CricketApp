//
//  SettingsViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 11/08/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import MessageUI


class SettingsViewController: UIViewController,GADBannerViewDelegate,MFMailComposeViewControllerDelegate {
    
    var arrList:NSArray!
    @IBOutlet weak var tableView:UITableView?
    var isForVideo:Bool = false
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        //        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.isFullVersion{
            // Request a Google Ad
            adBannerView.load(GADRequest())
            //            self.view.addSubview(adBannerView)
        }
//        arrList = ["RECALL","HAWALA","CHANGE PASSWORD","BACKUP & RESTORE","ABOUT US"]
        
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share(sender:)))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(sender:)))
        
        if isForVideo{
            self.title = "Video List"
            arrList = ["ADD INFO","SESSION","MATCH"]
        }
        else{
            
            arrList = ["RECALL","HAWALA","CONTACT US","WATCH VIDEOS"]
        }
        
        
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        self.tableView?.backgroundColor = Util.setTableViewBGColor()
        tableView?.separatorColor = Util.setTableViewBGColor()
    }
    
    // MARK: Tableview Methods
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        
//        cell.textLabel!.text = arrList[(indexPath as NSIndexPath).row]  as? String
//        
//        cell.backgroundColor = Util.setCellBackgroundColor()
//        cell.textLabel?.font = Util.setCellMainTitleFont()
//        cell.textLabel?.textColor = Util.setCellMainTitleTextColor()
//        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = Util.setCellBackgroundColor()
        cell.textLabel!.text = arrList[(indexPath as NSIndexPath).row]  as? String
        cell.textLabel?.font = Util.setCellMainTitleFont()
        cell.textLabel?.textColor = Util.setCellMainTitleTextColor()
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        
        if isForVideo{
            var youtubeId = "ue5zUj_9k9Y"
            switch (indexPath as NSIndexPath).row {
            case 0:
//                print((indexPath as NSIndexPath).row)
                
                youtubeId = "0b--uUPVVWE"
               
                
                break
            case 1:
                youtubeId = "ue5zUj_9k9Y"
               
                break
                
            case 2:
                youtubeId = "TwkVgoBXZAw"
                
                break
            
                
            default: break
                
            }
            
            
            var youtubeUrl = NSURL(string:"youtube://\(youtubeId)")!
            if UIApplication.shared.canOpenURL(youtubeUrl as URL){
                UIApplication.shared.openURL(youtubeUrl as URL)
            } else{
                youtubeUrl = NSURL(string:"https://www.youtube.com/watch?v=\(youtubeId)")!
                UIApplication.shared.openURL(youtubeUrl as URL)
            }
        }
        else
        {
            switch (indexPath as NSIndexPath).row {
            case 0:
                print((indexPath as NSIndexPath).row)
                
                
                let storyBoard:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
                
                
                let objFullReportVC = storyBoard.instantiateViewController(withIdentifier: "BookieFullReportViewController") as! BookieFullReportViewController
                objFullReportVC.isRecall = true
                self.navigationController?.pushViewController(objFullReportVC, animated: true)
                
                break
            case 1:
                
                let storyBoardReport:UIStoryboard = UIStoryboard(name: "Report", bundle: nil)
                
                let bookieReportVC = storyBoardReport.instantiateViewController(withIdentifier: "BookieReportViewController") as! BookieReportViewController
                bookieReportVC.isHawala = true
                self.navigationController?.pushViewController(bookieReportVC, animated: true)
                
                break
                
            case 2:
                //self.changeName()
                if MFMailComposeViewController.canSendMail()
                {
                    let composeVC = MFMailComposeViewController()
                    composeVC.mailComposeDelegate = self
                    
                    // Configure the fields of the interface.
                    composeVC.setToRecipients(["wedoappsforyou@gmail.com"])
                    composeVC.setSubject("Cricket Calc Feedback")
                    composeVC.setMessageBody("Hey WeDoApps! Here's my feedback.", isHTML: false)
                    
                    // Present the view controller modally.
                    self.present(composeVC, animated: true, completion: nil)
                }
                
                break
            case 3:
                
                let videoVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                videoVC.isForVideo = true;

                self.navigationController?.pushViewController(videoVC, animated: true)
                
                break
            
            default: break
                
            }
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)   
    }
    
    func share(sender:UIView){
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let textToShare = "Check out my app"
        
        if let myWebsite = URL(string: "https://itunes.apple.com/in/app/cricket-calc/id1324171518?mt=8") {//Enter link to your app here
            let objectsToShare = [textToShare, myWebsite, image ?? #imageLiteral(resourceName: "app-logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
    func changeName(){
        
        let alertController = UIAlertController(title: kAPPNAME, message: "Enter Name.", preferredStyle: .alert)
        
        var field:UITextField?;// operator ? because it's been initialized later
        alertController.addTextField(configurationHandler: {(input:UITextField)in
            //            input.placeholder="I am displayed, when there is no value ;-)";
            input.clearButtonMode=UITextFieldViewMode.whileEditing
            let defaults = UserDefaults.standard
            input.text = defaults.string(forKey: kUSERNAME)
        
            field=input;//assign to outside variable(for later reference)
        });
        
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction) in
            
            UserDefaults.standard.set(field?.text, forKey: kUSERNAME)
            UserDefaults.standard.synchronize()
            
        })
        
        alertController.addAction(action)
        
        showDetailViewController(alertController, sender: self)
        
    
    
    
}
    func mailComposeController(_ controller: MFMailComposeViewController,
                           didFinishWith result: MFMailComposeResult, error: Error?) {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    controller.dismiss(animated: true, completion: nil)
    }
    // MARK: - GADBannerViewDelegate methods
    
    
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        tableView?.tableHeaderView?.frame = bannerView.frame
        tableView?.tableHeaderView = bannerView
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }

}
