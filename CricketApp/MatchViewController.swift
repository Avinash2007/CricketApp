//
//  MatchViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 16/05/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
class MatchViewController: UIViewController,GADBannerViewDelegate {
   
   
    var objMatch:MatchClass!
    var amountLeft:Double = 0
    var amountRight:Double = 0
    var bhavLeft:Double = 0
    var bhavRight:Double = 0
    var isReanOnly:Int32 = 0
    var finalAmount:Double = 0.0
    
    var arrMatchSodaList: NSMutableArray!
    var arrBookie = [Bookie]()
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var bottomView:UIView!
    @IBOutlet weak var lblLeftTitle:UILabel!
    @IBOutlet weak var lblLeftAmount:UILabel!
    @IBOutlet weak var lblLeftBhav:UILabel!
    
    @IBOutlet weak var lblRightTitle:UILabel!
    @IBOutlet weak var lblRightAmount:UILabel!
    @IBOutlet weak var lblRightBhav:UILabel!
    
    @IBOutlet weak var viewClose:UIView!
    @IBOutlet weak var segmentTeam:UISegmentedControl!
    @IBOutlet weak var lblFinalAmount:UILabel!
    var finshMatchBarButton:UIBarButtonItem!
    
    var viewBlackGloble:UIView!

    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.frame = CGRect(x: 0, y: self.bottomView.frame.origin.y - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
        return adBannerView
    }()
    
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.isFullVersion{
            // Request a Google Ad
            adBannerView.load(GADRequest())
            self.view.addSubview(adBannerView)
        }
        
        
        segmentTeam .setTitle(objMatch.team1, forSegmentAt: 0);
        segmentTeam .setTitle(objMatch.team2, forSegmentAt: 1);
        
        Util.setBackgroundColor(viewClose)
        Util.setCornerRadius(viewClose)
        Util.setFontOnLable(viewClose)
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        self.tblView?.backgroundColor = Util.setTableViewBGColor()
        tblView?.separatorColor = Util.setTableViewBGColor()
        
        let btnCloseSession = UIButton()
        btnCloseSession.titleLabel?.numberOfLines = 2
        btnCloseSession.setTitle("Finish\nMatch", for: .normal)
        btnCloseSession.sizeToFit()
        btnCloseSession.titleLabel?.textAlignment = .center
        btnCloseSession.titleLabel?.font = Util.setBarButtonFont()
        btnCloseSession.addTarget(self, action: #selector(self.closeMatch(_:)), for: .touchUpInside)
        finshMatchBarButton = UIBarButtonItem(customView: btnCloseSession)
        
        
        if isReanOnly == 1
        {
            self.navigationItem.rightBarButtonItems = []
            
            let lblTitle = UILabel()
            lblTitle.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
            lblTitle.textAlignment = .center
            lblTitle.font = Util.setCustomNavigationMainTitleFont()
            lblTitle.textColor = .white
            lblTitle.text = "Winner Team"
            
            
            let lblSubTitle = UILabel()
            lblSubTitle.frame = CGRect(x: 10, y: 20, width: 100, height: 20)
            lblSubTitle.textAlignment = .center
            lblSubTitle.font = Util.setCustomNavigationSubTitleFont()
            lblSubTitle.textColor = Util.setMainViewBGColor()
            
            if objMatch.winnerTeam == "Team1" {
                    lblSubTitle.text = objMatch.team1
            }
            else{
                lblSubTitle.text = objMatch.team2
            }
            
            
            
            
            let viewForNav = UIView()
            viewForNav.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
            viewForNav.backgroundColor = .clear
            viewForNav.addSubview(lblTitle)
            viewForNav.addSubview(lblSubTitle)
            
            self.navigationItem.titleView = viewForNav

            
        }
        else{
            let btnPlus = self.navigationItem.rightBarButtonItem
            self.navigationItem.rightBarButtonItems = [btnPlus!,finshMatchBarButton]
        }
        
//        lblLeftBhav.backgroundColor = Util.setNavigationBarColor()
        lblLeftTitle.backgroundColor = .clear//Util.setNavigationBarColor()
        lblRightTitle.backgroundColor = .clear//Util.setNavigationBarColor()
        
        lblLeftTitle.textColor = Util.setNavigationBarColor()
        lblRightTitle.textColor = Util.setNavigationBarColor()
        
        lblLeftBhav.backgroundColor = .clear
        lblRightBhav.backgroundColor = .clear
        
        lblLeftAmount.backgroundColor = .clear
        lblRightAmount.backgroundColor = .clear
        
        lblRightBhav.textColor = Util.setNavigationBarColor()
        lblLeftBhav.textColor = Util.setNavigationBarColor()
        
        
        lblLeftBhav.font = Util.setNavigationFont()
        lblRightBhav.font = Util.setNavigationFont()
        
        lblLeftAmount.font = Util.setNavigationFont()
        lblRightAmount.font = Util.setNavigationFont()
        
        
        bottomView.backgroundColor = Util.setCellBackgroundColor()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if appDel.isDeleteODIMatch {
            appDel.isDeleteODIMatch = false
            _ = self.navigationController?.popViewController(animated: true)
            
            return
        }
        
        
        if appDel.isUpdateODIMatch {
            appDel.isUpdateODIMatch = false
            _ = self.navigationController?.popViewController(animated: true)
            
            return
        }
        
        
        self.getAllBookieList()

        
        if isReanOnly == 1 {
            lblLeftBhav.isHidden = true
            lblRightBhav.isHidden = true
        }
        
        self.getMatchSodaList()

        tblView.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0)

//        tblView.setContentOffset(cgpointm, animated: false)
    }
    
    // MARK: - IBACTION METHODS
    
    @IBAction func insertNewObject(_ sender: AnyObject) {
        let matchDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "MatchDetailViewController") as! MatchDetailViewController
        matchDetailVC.objMatch = objMatch
        self.navigationController?.pushViewController(matchDetailVC, animated: true)
    }
    
    @IBAction func closeMatch(_ Sender: AnyObject){
        
        if arrMatchSodaList.count == 0 {
            let alert = UIAlertController(title: kAPPNAME, message: "Please Add Soda Using + Sign" , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.showDetailViewController(alert, sender: self)
            
        }
        else
        {
            
            self.teamChange(segmentTeam)
            
//            if amountLeft < 0
//            {
//                lblFinalAmount.textColor = UIColor.red
//            }
//            else
//            {
//                lblFinalAmount.textColor = Util.setNavigationBarColor()
//            }
//            lblFinalAmount.text = String(format: "%@ = %.3f",kBOOKNAME,amountLeft)
//            finalAmount = amountLeft
            
            
            let viewBlack = UIView.init(frame: UIScreen.main.bounds)
            viewBlack.backgroundColor = .black
            viewBlack.alpha = 0.5
            self.viewClose.center = self.view.center
            
            let appDel = UIApplication.shared.delegate as! AppDelegate
            appDel.window?.addSubview(viewBlack)
            appDel.window?.addSubview(viewClose)

            
            viewBlackGloble = viewBlack
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.cancelPress))
            viewBlack.isUserInteractionEnabled = true
            viewBlack.addGestureRecognizer(gesture)
        }
        
    }
    
    @IBAction func cancelPress(){
        
        viewClose.removeFromSuperview()
        viewBlackGloble.removeFromSuperview()
    }
    
    @IBAction func teamChange(_ Sender:UISegmentedControl)
    {
        if Sender.selectedSegmentIndex == 0 {
            if amountLeft < 0
            {
                lblFinalAmount.textColor = UIColor.red
            }
            else
            {
                lblFinalAmount.textColor = Util.setNavigationBarColor()
            }
            lblFinalAmount.text = String(format: "%@ = %.3f",kBOOKNAME,amountLeft)
            finalAmount = amountLeft
        }
        else
        {
            if amountRight < 0
            {
                lblFinalAmount.textColor = UIColor.red
            }
            else
            {
                lblFinalAmount.textColor = Util.setNavigationBarColor()
            }
            lblFinalAmount.text = String(format: "%@ = %.3f",kBOOKNAME,amountRight)
            finalAmount = amountRight
        }
    }
    @IBAction func btnFinalClose(_ Sender:AnyObject){
        
        objMatch.isActive = 0
        //        objMatch.winnerTeam = segmentTeam.titleForSegmentAtIndex(segmentTeam.selectedSegmentIndex)!
        
        if segmentTeam.selectedSegmentIndex == 0 {
            objMatch.winnerTeam = "Team1"
        }
        else{
            objMatch.winnerTeam = "Team2"
        }
        
        objMatch.Amount = finalAmount
        
        let strQuery = String(format: "UPDATE MatchTBL SET isActive='%d',WinnerTeam='%@',Amount='%f' WHERE MatchID ='%d'", arguments: [objMatch.isActive,objMatch.winnerTeam,objMatch.Amount, objMatch.matchID])
        
        let isUpdated = ModelManager.getInstance().updateRecord(strQuery)
        
        if isUpdated{
            
            self.insertRecordIntoAccount()
            cancelPress()
            _ = self.navigationController?.popViewController(animated: true)
        }
        else
        {
            Util.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
        }
        
        
        
    }
    
    
    func insertRecordIntoAccount(){
        
        var amountForBook:Double = 0.0
        var commiForBook:Double = 0.0
        
        for i in 0 ..< arrMatchSodaList.count + 1
        {
            
            if i < arrMatchSodaList.count
            {
                let objMatchLocal = arrMatchSodaList[i] as! MatchList
                let objAccount:Account = Account()
                
                objAccount.matchID = objMatch.matchID
                objAccount.sessionID = 0
                objAccount.isMatch = 1

                if segmentTeam.selectedSegmentIndex == 0 {
                    
                    objAccount.amount = objMatchLocal.amountLeft - objMatchLocal.commissionRs
                }
                else
                {
                    objAccount.amount = objMatchLocal.amountRight - objMatchLocal.commissionRs
                }
                objAccount.commiAmount = objMatchLocal.commissionRs
                objAccount.amount = objAccount.amount * -1
                
                amountForBook = amountForBook + objAccount.amount
                commiForBook = commiForBook + objAccount.commiAmount
                
                objAccount.bookieID = objMatchLocal.bookieID
                
                
                
                let strQuery:String = "INSERT INTO AccountTBL(MatchID,BookieID,SessionID,isMatch,Amount,CommiAmount) VALUES ('\(objAccount.matchID)','\(objAccount.bookieID)','\(objAccount.sessionID)','\(objAccount.isMatch)','\(objAccount.amount)','\(objAccount.commiAmount)')"
                
                let isInserted = ModelManager.getInstance().updateRecord(strQuery)
                
                if isInserted {
                    print("inserted")
                    
                    let objBookie = ModelManager.getInstance().getBookieFromBookieID(uniqueId: objMatchLocal.bookieID)
                    
                    objBookie.amount = objBookie.amount + objAccount.amount
                    objBookie.ODICommissionRS = objBookie.ODICommissionRS + objAccount.commiAmount
                    objBookie.totalAmount = objBookie.totalAmount + objAccount.amount
                    let strQuery = String(format: "UPDATE BookieTBL SET Amount='%f', ODICommiRS='%f', TotalAmount='%f' WHERE BookieID ='%d'", arguments: [objBookie.amount, objBookie.ODICommissionRS,objBookie.totalAmount, objBookie.bookieID])
                    
                    let isUpdated = ModelManager.getInstance().updateRecord(strQuery)
                    
                    if isUpdated{
                       // break;
                    }
                    else
                    {
                        Util.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
                    }

                }
                else{
                    print("Problem")
                }
            }
            else
            {
                let objAccount:Account = Account()
                
                objAccount.matchID = objMatch.matchID
                objAccount.sessionID = 0
                objAccount.isMatch = 1
            
                
                objAccount.amount = amountForBook * -1
                objAccount.commiAmount = commiForBook
                
                objAccount.bookieID = kBOOKID
                
                
                
                let strQuery:String = "INSERT INTO AccountTBL(MatchID,BookieID,SessionID,isMatch,Amount,CommiAmount) VALUES ('\(objAccount.matchID)','\(objAccount.bookieID)','\(objAccount.sessionID)','\(objAccount.isMatch)','\(objAccount.amount)','\(objAccount.commiAmount)')"
                
                let isInserted = ModelManager.getInstance().updateRecord(strQuery)
                
                if isInserted {
                    print("inserted")
                    
                    let objBookie = ModelManager.getInstance().getBookieFromBookieID(uniqueId: kBOOKID)
                    
                    objBookie.amount = objBookie.amount + objAccount.amount
                    objBookie.ODICommissionRS = objBookie.ODICommissionRS + objAccount.commiAmount
                    objBookie.totalAmount = objBookie.totalAmount + objAccount.amount
                    let strQuery = String(format: "UPDATE BookieTBL SET Amount='%f', ODICommiRS='%f', TotalAmount='%f' WHERE BookieID ='%d'", arguments: [objBookie.amount, objBookie.ODICommissionRS, objBookie.totalAmount, objBookie.bookieID])
                    
                    let isUpdated = ModelManager.getInstance().updateRecord(strQuery)
                    
                    if isUpdated{
                       // break;
                    }
                    else
                    {
                        Util.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
                    }
                    
                }
                else{
                    print("Problem")
                }

                
            }
            
        }
        
    }
    
//    
//    func getBookieFromBookieID(uniqueId: Int32)->Bookie {
//        
//        var objBookieInner:Bookie!
//        for objBookieLocal in arrBookie where objBookieLocal.bookieID == uniqueId
//        {
//            
//            objBookieInner = objBookieLocal
//            break
//        }
//        
//        return objBookieInner
//        
//        
//    }
    
    
    // MARK: - GET DB VALUES METHOD
    
    func getAllBookieList()
    {
        
        arrBookie = ModelManager.getInstance().getAllBookieData(query: "SELECT * FROM BookieTBL ORDER BY BookieName ASC")
    }
    
    func getMatchSodaList()
    {
        amountRight = 0
        amountLeft = 0
        bhavLeft = 0
        bhavRight = 0
        
        //        lblLeft.text =  objMatch.team1 + " = " + String(amountLeft)
        //        lblRight.text =  objMatch.team2 + " = " + String(amountRight)
        
        lblLeftTitle.text = objMatch.team1
        if amountLeft < 0
        {
            lblLeftAmount.textColor = UIColor.red
        }
        else
        {
            lblLeftAmount.textColor = UIColor.white
        }
        lblLeftAmount.text = String(format: "%.2f",amountLeft)
        
        
        
        lblLeftBhav.text = String(bhavLeft)
        
        lblRightTitle.text = objMatch.team2
        
        if amountRight < 0
        {
            lblRightAmount.textColor = UIColor.red
        }
        else
        {
            lblRightAmount.textColor = UIColor.white
        }
        lblRightAmount.text = String(format: "%.2f",amountRight)
        lblRightBhav.text = String(bhavRight)
        
        
        
        arrMatchSodaList = NSMutableArray()
        
        var arrDB:NSMutableArray = NSMutableArray()
        
        
        arrDB = ModelManager.getInstance().getAllMatchSodaList("SELECT * FROM MatchSodaTBL WHERE MatchID = \(objMatch.matchID) ORDER BY MatchSodaID DESC")
        
        let objSet:NSMutableSet = NSMutableSet()
        
        for i in 0 ..< arrDB.count{
            
            let objMatchSoda = arrDB[i] as! MatchSoda
            
            objSet.add(String(objMatchSoda.bookieID))
            
        }
        var arrSet = objSet.allObjects
        
        
        for i in 0 ..< arrSet.count
        {
            
            let setValue = arrSet[i] as! String
            
            let objMatchLocal:MatchList = MatchList()
            
            for j in 0 ..< arrDB.count
            {
                
                let objMatch = arrDB[j] as! MatchSoda
                
                
                if setValue ==  String(objMatch.bookieID)
                {
                    objMatchLocal.arrRecordPerBookie.add(objMatch)
                }
            }
            
            for j in 0 ..< arrBookie.count {
                
                let objBookie = arrBookie[j] 
                
                if setValue == String(objBookie.bookieID) {
                    
                    objMatchLocal.strBookieName = objBookie.bookieName
//                    objMatchLocal.odiCommi = objBookie.ODICommission
                    objMatchLocal.bookieID = objBookie.bookieID
                    break;
                }
                
            }
            arrMatchSodaList.add(objMatchLocal)
        }
        
        //Calculation of total amount
        
        //
        
        for i in 0 ..< arrMatchSodaList.count {
            
            let objMatchLocal = arrMatchSodaList[i] as! MatchList
            
                       
            for j in 0 ..< objMatchLocal.arrRecordPerBookie.count {
                
                
                
                let objMatchSoda = objMatchLocal.arrRecordPerBookie[j] as! MatchSoda
                
                if objMatch.isCommi == 0 {
                    
                    objMatchSoda.commision = 0
                }

                
                
                if objMatchSoda.win == 1
                {
                    
                    if objMatchSoda.teamCode == "Team1" {
                                                
                        objMatchLocal.amountLeft = objMatchLocal.amountLeft + (objMatchSoda.bhav * objMatchSoda.amount/100) + (objMatchSoda.commision * objMatchSoda.amount/100)
                        
                        objMatchLocal.amountRight = objMatchLocal.amountRight - objMatchSoda.amount + (objMatchSoda.commision * objMatchSoda.amount/100)
                        
                    }
                    else
                    {
                        objMatchLocal.amountRight = objMatchLocal.amountRight + (objMatchSoda.bhav * objMatchSoda.amount/100) + (objMatchSoda.commision * objMatchSoda.amount/100)
                        
                        objMatchLocal.amountLeft = objMatchLocal.amountLeft - objMatchSoda.amount + (objMatchSoda.commision * objMatchSoda.amount/100)
                        
                    }
                    
                }
                else
                {
                    if objMatchSoda.teamCode == "Team1" {
                        
                        objMatchLocal.amountLeft = objMatchLocal.amountLeft - (objMatchSoda.amount * objMatchSoda.bhav/100) + (objMatchSoda.commision * objMatchSoda.amount/100)
                        
                        
                        objMatchLocal.amountRight = objMatchLocal.amountRight + objMatchSoda.amount + (objMatchSoda.commision * objMatchSoda.amount/100)
                        
                    }
                    else
                    {
                        objMatchLocal.amountRight = objMatchLocal.amountRight - (objMatchSoda.amount * objMatchSoda.bhav/100) + (objMatchSoda.commision * objMatchSoda.amount/100)
                        
                        
                        objMatchLocal.amountLeft = objMatchLocal.amountLeft + objMatchSoda.amount + (objMatchSoda.commision * objMatchSoda.amount/100)
                        
                        
                    }
                }
                objMatchLocal.commissionRs = objMatchLocal.commissionRs + (objMatchSoda.commision * objMatchSoda.amount/100)
                
            }
            
        }
        
        
        self.setValForFinalAmount()
        //
        
        //        print(objSet);
        tblView.reloadData()
    }
    
    
    func setValForFinalAmount(){
        for i in 0 ..< arrMatchSodaList.count {
            
            
            let objMatchLocal = arrMatchSodaList[i] as! MatchList
            
            amountLeft = amountLeft + objMatchLocal.amountLeft
            amountRight = amountRight + objMatchLocal.amountRight
            
            
            if amountLeft < 0
            {
                lblLeftAmount.textColor = UIColor.red
            }
            else
            {
                lblLeftAmount.textColor = UIColor.white
            }
            
            lblLeftAmount.text = String(format: "%.2f",amountLeft)
            
            bhavLeft = amountLeft/amountRight
            
            if bhavLeft < 0 {
                bhavLeft=bhavLeft * -1
            }
            lblLeftBhav.text = String(format: "%.2f",bhavLeft)
            
            lblRightTitle.text = objMatch.team2
            
            if amountRight < 0
            {
                lblRightAmount.textColor = UIColor.red
            }
            else
            {
                lblRightAmount.textColor = UIColor.white
            }
            
            lblRightAmount.text = String(format: "%.2f",amountRight)
            
            bhavRight = amountRight/amountLeft
            
            if bhavRight < 0 {
                bhavRight=bhavRight * -1
            }
            
            lblRightBhav.text = String(format: "%.2f",bhavRight)
            
            
            
        }
        
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return arrMatchSodaList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        let objMatchLocal = arrMatchSodaList[section] as! MatchList
        
        
        
        return objMatchLocal.arrRecordPerBookie.count
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30.0
//    }

//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 25.0
//    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let objMatchLocal = arrMatchSodaList[section] as! MatchList
        return objMatchLocal.strBookieName
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let objMatchLocal = arrMatchSodaList[section] as! MatchList
        
//        amountLeft = amountLeft + objMatchLocal.amountLeft
//        amountRight = amountRight + objMatchLocal.amountRight
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        footerView.backgroundColor = UIColor.clear
        
        let lblLeftSide = UILabel(frame: CGRect(x: 20,y: 2.5,width: (tableView.frame.size.width/2)-40,height: 20))
        lblLeftSide.textAlignment = .left
        
        
        
        lblLeftSide.text = String(objMatchLocal.amountLeft)
        
        if objMatchLocal.amountLeft < 0 {
            lblLeftSide.textColor = UIColor.red
        }
        else
        {
            lblLeftSide.textColor = Util.setNavigationBarColor()
        }
        lblLeftSide.font = Util.setNavigationFont()
        footerView.addSubview(lblLeftSide)
        
        
        let lblRightSide = UILabel(frame: CGRect(x: (tableView.frame.size.width/2) + 20 ,y: 2.5,width: (tableView.frame.size.width/2)-40,height: 20))
        lblRightSide.textAlignment = .right
        lblRightSide.text = String(objMatchLocal.amountRight)
        lblRightSide.font = Util.setNavigationFont()
        if objMatchLocal.amountRight < 0 {
            lblRightSide.textColor = UIColor.red
        }
        else
        {
            lblRightSide.textColor = Util.setNavigationBarColor()
        }
        footerView.addSubview(lblRightSide)
        
        
        
        return footerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Util.setCellBackgroundColor()
        
        let objMatchLocal = arrMatchSodaList[(indexPath as NSIndexPath).section] as! MatchList
        
        
        let object = objMatchLocal.arrRecordPerBookie[(indexPath as NSIndexPath).row] as! MatchSoda
        
        let strSodo:String
        
        if object.win == 1 {
            strSodo = "L"
        }
        else{
            strSodo = "K"
        }
        
        let lblTeam = cell.viewWithTag(11) as! UILabel
        let lblAmout = cell.viewWithTag(12) as! UILabel
        let lblDate = cell.viewWithTag(13) as! UILabel
       
        lblTeam.font = Util.setCellMainTitleFont()
        lblAmout.font = Util.setCellMainTitleFont()
        lblDate.font = Util.setCellMainTitleFont()
        
        lblTeam.textColor = Util.setNavigationTitleColor()
        lblDate.textColor = Util.setNavigationTitleColor()
        lblAmout.textColor = Util.setNavigationTitleColor()
        

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
        
        
        
        
        if object.teamCode == "Team1" {
        
            let attributedStringForSoda = NSMutableAttributedString(string: strSodo + " ",
                                                                    attributes:dicBlack)
            
            let attributedStringForObject = NSMutableAttributedString(string: objMatch.team1,attributes:dicWhite)
            
            
            
            attributedStringForSoda.append(attributedStringForObject)
            
            lblTeam.attributedText = attributedStringForSoda
        }
        else{
            let attributedStringForSoda = NSMutableAttributedString(string: strSodo + " ",
                                                                    attributes:dicBlack)
            
            let attributedStringForObject = NSMutableAttributedString(string: objMatch.team2,attributes:dicWhite)
            
            
            
            attributedStringForSoda.append(attributedStringForObject)
            
            lblTeam.attributedText = attributedStringForSoda
        }

        
        
        lblAmout.text = String(format: "%.1f",object.amount) + " * " + String(format: "%.2f",object.bhav)
        
        
        lblDate.text = object.matchSodaDate as String
        
        if isReanOnly == 1{
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if isReanOnly == 1 {
            return false
        }
        else{
            return true
        }
        
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let objMatchLocal = arrMatchSodaList[(indexPath as NSIndexPath).section] as! MatchList
            
            let objMatchSoda = objMatchLocal.arrRecordPerBookie[(indexPath as NSIndexPath).row] as! MatchSoda
            
            
            let isDeleted = ModelManager.getInstance().deleteMatchSodaData(objMatchSoda)
            
            if isDeleted {
                Util.invokeAlertMethod("", strBody: "Record Deleted successfully.", delegate: nil)
            } else {
                Util.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
            }
            self.getMatchSodaList()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        if isReanOnly == 0 {
            let matchDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "MatchDetailViewController") as! MatchDetailViewController
            
            let objMatchLocal = arrMatchSodaList[(indexPath as NSIndexPath).section] as! MatchList
            
            matchDetailVC.objMatchSoda = objMatchLocal.arrRecordPerBookie[(indexPath as NSIndexPath).row] as! MatchSoda
            matchDetailVC.objMatch = objMatch
            
            
            self.navigationController?.pushViewController(matchDetailVC, animated: true)

        }
        tableView.deselectRow(at: indexPath, animated: true)
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
