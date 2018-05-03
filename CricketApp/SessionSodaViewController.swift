//
//  SessionSodaViewController.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 01/06/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class SessionSodaViewController: UIViewController ,GADBannerViewDelegate{
    
    var objSession:Session!
    
    var arrSessionSodaList:NSMutableArray!
    var arrBookie = [Bookie]()
//    var arrForBook:NSMutableArray!
    var isReadOnly:Int32 = 0
    
    var barBTNCloseSession:UIBarButtonItem!
    
    //FOR SEGMENT 2
    var arrShowBook:NSMutableArray = NSMutableArray()
    
    var maxRun:Int32!
    var minRun:Int32!
    var finalAmount:Double = 0.0
    var objSessionSodaGloble:SessionSoda!
    var arrSessionSoda:NSMutableArray = NSMutableArray()
    
    var viewBlackGloble:UIView!
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var viewClose:UIView!
    @IBOutlet weak var lblFinalAmount:UILabel!
    @IBOutlet weak var txtFinalRun:UITextField!
    @IBOutlet weak var lblMessage:UILabel!
    @IBOutlet weak var segment:UISegmentedControl!
    
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Util.getBannerAdsID()
        adBannerView.delegate = self
        adBannerView.rootViewController = self
//        adBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height-(self.navigationController?.tabBarController?.tabBar.frame.size.height)! - adBannerView.frame.size.height, width: adBannerView.frame.size.width, height: adBannerView.frame.size.height)
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
//            self.view.addSubview(adBannerView)
        }
        
        self.title = objSession.sessionName + " " + objSession.teamName
        self.applyLayoutOnView()
        
        
        if isReadOnly == 1 {
            self.navigationItem.rightBarButtonItems = []
            
            let yPos = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
            let tabbarHeight = self.navigationController?.tabBarController?.tabBar.frame.height
            
            tblView.frame = CGRect(x: 0, y:yPos , width: self.view.frame.size.width, height: self.view.frame.size.height - (yPos + tabbarHeight!))
            segment.isHidden = true
//            self.title = "Run = " + String(objSession.Run)
        }
        else{
        
            segment.isHidden = false
        }
         segment.selectedSegmentIndex = 0
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if appDel.isDeletedSession {
            appDel.isDeletedSession = false
            _ = self.navigationController?.popViewController(animated: true)
            
            return
        }
        
        
        if appDel.isUpdatedSession {
            appDel.isUpdatedSession = false
            _ = self.navigationController?.popViewController(animated: true)
            
            return
        }

        
        self.getAllBookieList()
        self.changeSegmentValue(segment)
        
        self.checkBook()
    }
    
    override func viewWillLayoutSubviews() {
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkBook(){
        
        maxRun = 0
        minRun = 0
        
        arrSessionSoda = ModelManager.getInstance().getAllDetailOfSession("SELECT * FROM SessionSodaTBL WHERE SessionID = \(objSession.sessionID) ORDER BY SessionSodaID DESC")
        
        if arrSessionSoda.count > 0 {
            objSessionSodaGloble = arrSessionSoda.object(at: 0) as! SessionSoda
        }
        tblView.reloadData()

    }
    
    func applyLayoutOnView(){
     
//        viewClose.layer.borderWidth = 0.5
//        viewClose.layer.borderColor = Util.setNavigationBarColor().cgColor
        Util.setBackgroundColor(viewClose)
        Util.setCornerRadius(viewClose)
        Util.setFontOnLable(viewClose)
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        self.tblView?.backgroundColor = Util.setTableViewBGColor()
        tblView?.separatorColor = Util.setTableViewBGColor()

        
        
        let btnCloseSession = UIButton()
        btnCloseSession.titleLabel?.numberOfLines = 2
        btnCloseSession.setTitle("Finish\nSession", for: .normal)
        btnCloseSession.setTitleColor(Util.setColorForDisableButton(), for: .disabled)
        btnCloseSession.sizeToFit()
        btnCloseSession.titleLabel?.textAlignment = .center
        btnCloseSession.titleLabel?.font = Util.setBarButtonFont()
        btnCloseSession.addTarget(self, action: #selector(self.closeSession(_:)), for: .touchUpInside)
        barBTNCloseSession = UIBarButtonItem(customView: btnCloseSession)
        
        
        let btnPlus = self.navigationItem.rightBarButtonItem
        
        self.navigationItem.rightBarButtonItems = [btnPlus!,barBTNCloseSession]
        
        if isReadOnly == 1 {
            
            let lblTitle = UILabel()
            lblTitle.frame = CGRect(x: 50, y: 0, width: 100, height: 20)
            lblTitle.textAlignment = .center
            lblTitle.font = Util.setCustomNavigationMainTitleFont()
            lblTitle.textColor = .white
            lblTitle.text = objSession.teamName
            
            
            let lblSubTitle = UILabel()
            lblSubTitle.frame = CGRect(x: 0, y: 20, width: 100, height: 20)
            lblSubTitle.textAlignment = .center
            lblSubTitle.font = Util.setCustomNavigationSubTitleFont()
            lblSubTitle.textColor = Util.setMainViewBGColor()
            lblSubTitle.text = objSession.sessionName
            
            
            let lblRun = UILabel()
            lblRun.frame = CGRect(x: 100, y: 20, width: 100, height: 20)
            lblRun.textAlignment = .center
            lblRun.font = Util.setCustomNavigationSubTitleFont()
            lblRun.textColor = Util.setMainViewBGColor()
            lblRun.text = "Run = " + String(objSession.Run)
            
            
            
            let viewForNav = UIView()
            viewForNav.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
            viewForNav.backgroundColor = .clear
            viewForNav.addSubview(lblTitle)
            viewForNav.addSubview(lblSubTitle)
            viewForNav.addSubview(lblRun)
            self.navigationItem.titleView = viewForNav

            
        }
        else{
            
            let lblTitle = UILabel()
            lblTitle.frame = CGRect(x: 0, y: 0, width: 100, height: 22)
            lblTitle.textAlignment = .center
            lblTitle.font = Util.setCustomNavigationMainTitleFont()
            lblTitle.textColor = .white
            lblTitle.adjustsFontSizeToFitWidth = true
            lblTitle.text = objSession.teamName
            
            
            let lblSubTitle = UILabel()
            lblSubTitle.frame = CGRect(x: 0, y: 23, width: 100, height: 20)
            lblSubTitle.textAlignment = .center
            lblSubTitle.adjustsFontSizeToFitWidth = true
            lblSubTitle.font = Util.setCustomNavigationSubTitleFont()
            lblSubTitle.textColor = Util.setMainViewBGColor()
            lblSubTitle.text = objSession.sessionName
            
            
            let viewForNav = UIView()
            viewForNav.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
            viewForNav.backgroundColor = .clear
            viewForNav.addSubview(lblTitle)
            viewForNav.addSubview(lblSubTitle)
            
            self.navigationItem.titleView = viewForNav
            
            

        }
        
        lblMessage.font = Util.setLableMessageFont()
        lblMessage.textColor = Util.setNavigationBarColor()
        
        
        
        segment.tintColor = Util.setNavigationBarColor()
        segment.backgroundColor = Util.setMainViewBGColor()
        
        let attr = NSDictionary(object: UIFont(name:kFONTBTN, size: 15.0)!, forKey: NSFontAttributeName as NSCopying)
        
        segment.setTitleTextAttributes(attr as? [AnyHashable: Any], for: UIControlState())
        
        txtFinalRun.addTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)), for: UIControlEvents.editingChanged)
    }
    
   
    
    //MARK: IBAction Mehods
    
    
    @IBAction func changeSegmentValue(_ sender:UISegmentedControl)
    {
        if segment.selectedSegmentIndex == 0 {
            
            self.getAllSessionSoda()
        }
        else{
            if arrSessionSoda.count > 0 {
                
                //self.checkBook()
                self.calculateArray()
            }
           
        }
    }
    
    @IBAction func closeSession(_ sender:AnyObject){
        
       // arrForBook = ModelManager.getInstance().getAllDetailOfSession("SELECT * FROM SessionSodaTBL WHERE SessionID = \(objSession.sessionID) ORDER BY SessionSodaID DESC")
        
        
        if arrSessionSoda.count == 0 {
            
            let alert = UIAlertController(title: kAPPNAME, message: "Please Add Soda Using + Sign", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler:{
                (action:UIAlertAction) in
                self.barBTNCloseSession.isEnabled = true
            })
            
            alert.addAction(okAction)
            showDetailViewController(alert, sender: self)
            
        }
        else{
             let viewBlack = UIView.init(frame: UIScreen.main.bounds)
            viewBlack.backgroundColor = .black
            viewBlack.alpha = 0.5
            self.viewClose.center = self.view.center
            
            

            
            let appDel = UIApplication.shared.delegate as! AppDelegate
            appDel.window?.addSubview(viewBlack)
            appDel.window?.addSubview(viewClose)
//            self.view.addSubview(viewBlack)
//            self.view.addSubview(viewClose)
            
            
            viewBlackGloble = viewBlack
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.cancelClose))
            viewBlack.isUserInteractionEnabled = true
            viewBlack.addGestureRecognizer(gesture)

        }
        
    }
    
    
    @IBAction func finalClose(_ sender:AnyObject){
        
        
//        if txtFinalRun.text != "" && lblFinalAmount.text == "" {
//         
//            Util.invokeAlertMethod("Alert", strBody: "Please Enter Run.", delegate: nil)
//            return
//        }
//        
//        if lblFinalAmount.text == "" {
//            
//            
//            
//            Util.invokeAlertMethod("Alert", strBody: "Please Enter Run.", delegate: nil)
//            txtFinalRun.becomeFirstResponder()
//            return
//        }
        
        
        if txtFinalRun.text == "" {
            
            let alert = UIAlertController(title: kAPPNAME, message: "Please Enter Run.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            showDetailViewController(alert, sender: self)
            
            return
        }
        
        
        objSession.Amount = finalAmount
        objSession.isActive = 0
        
        let strQuery = String(format: "UPDATE SessionTBL SET isActive='%d', Amount='%f', Run='%d' WHERE SessionID ='%d'", arguments: [objSession.isActive,objSession.Amount,Int32(txtFinalRun.text!)!, objSession.sessionID])
        
        let isUpdated = ModelManager.getInstance().updateRecord(strQuery)
        
        if isUpdated{
            
            self.insertRecordIntoAccount()
            cancelClose()
           _ = self.navigationController?.popViewController(animated: true)
        }
        else
        {
            Util.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
        }
        
    }
    
    func insertRecordIntoAccount()
    {
        
        var amountForBook:Double = 0.0
        var commiForBook:Double = 0.0

        
        for i in 0 ..< arrSessionSodaList.count + 1
        {
            
            
            if i < arrSessionSodaList.count{
                
                let objSessionLocal = arrSessionSodaList[i] as! SessionSodaList
                
                let objAccount:Account = Account()
                
                objAccount.matchID = 0
                
                objAccount.sessionID = objSession.sessionID
                objAccount.bookieID = objSessionLocal.bookieID
                objAccount.isMatch = 0
                
                
                var amount:Double = 0
                var commiAmount:Double = 0
                
                for j in 0 ..< objSessionLocal.arrRecordPerBookie.count {
                    
                    let objSessionSoda = objSessionLocal.arrRecordPerBookie[j] as! SessionSoda
                    
                    if objSession.isCommi == 0 {
                        objSessionSoda.commision = 0.0
                    }
                    
                    if objSessionSoda.thay == 1 {
                        if Int32(txtFinalRun.text!) >= objSessionSoda.Run
                        {
                            amount = amount + (objSessionSoda.amount * objSessionSoda.bhav)
                            
                        }
                        else
                        {
                            amount = amount - objSessionSoda.amount
                            
                        }
                    }
                    else
                    {
                        
                        if Int32(txtFinalRun.text!) >= objSessionSoda.Run
                        {
                            
                            amount = amount - (objSessionSoda.amount * objSessionSoda.bhav)
                            
                        }
                        else{
                            amount = amount + (objSessionSoda.amount * objSessionSoda.bhav)
                            
                        }
                    }
                    commiAmount = commiAmount + (objSessionSoda.amount * objSessionSoda.commision/100)
                }
                objAccount.amount = amount * -1
                
                objAccount.commiAmount = commiAmount * -1
                
                amountForBook = amountForBook + objAccount.amount
                commiForBook = commiForBook + objAccount.commiAmount
                
                let strQuery:String = "INSERT INTO AccountTBL(MatchID,BookieID,SessionID,isMatch,Amount,CommiAmount) VALUES ('\(objAccount.matchID)','\(objAccount.bookieID)','\(objAccount.sessionID)','\(objAccount.isMatch)','\(objAccount.amount)','\(objAccount.commiAmount)')"
                
                let isInserted = ModelManager.getInstance().updateRecord(strQuery)
                
                if isInserted {
                    print("inserted")
                    
                    
                    let objBookie = ModelManager.getInstance().getBookieFromBookieID(uniqueId: objSessionLocal.bookieID)
                    
                    objBookie.amount = objBookie.amount + objAccount.amount
                    objBookie.sessionCommissionRS = objBookie.sessionCommissionRS + objAccount.commiAmount
                    objBookie.totalAmount = objBookie.totalAmount + objAccount.amount
                    let strQuery = String(format: "UPDATE BookieTBL SET Amount='%f', SessionCommiRS='%f', TotalAmount='%f' WHERE BookieID ='%d'", arguments: [objBookie.amount,objBookie.sessionCommissionRS,objBookie.totalAmount, objBookie.bookieID])
                    
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
                
                objAccount.matchID = 0
                objAccount.sessionID = objSession.sessionID
                objAccount.isMatch = 0
                
                
                objAccount.amount = amountForBook * -1
                objAccount.commiAmount = commiForBook * -1
                
                objAccount.bookieID = kBOOKID
                
                
                
                let strQuery:String = "INSERT INTO AccountTBL(MatchID,BookieID,SessionID,isMatch,Amount,CommiAmount) VALUES ('\(objAccount.matchID)','\(objAccount.bookieID)','\(objAccount.sessionID)','\(objAccount.isMatch)','\(objAccount.amount)','\(objAccount.commiAmount)')"
                
                let isInserted = ModelManager.getInstance().updateRecord(strQuery)
                
                if isInserted {
                    print("inserted")
                    
                    let objBookie = ModelManager.getInstance().getBookieFromBookieID(uniqueId: kBOOKID)
                    
                    objBookie.amount = objBookie.amount + objAccount.amount
                    objBookie.sessionCommissionRS = objBookie.sessionCommissionRS + objAccount.commiAmount
                    objBookie.totalAmount = objBookie.totalAmount + objAccount.amount
                    let strQuery = String(format: "UPDATE BookieTBL SET Amount='%f', SessionCommiRS='%f', TotalAmount='%f' WHERE BookieID ='%d'", arguments: [objBookie.amount, objBookie.sessionCommissionRS, objBookie.totalAmount, objBookie.bookieID])
                    
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
            
            /*let objSessionLocal = arrSessionSodaList[i] as! SessionSodaList
            
            let objAccount:Account = Account()
            
            objAccount.matchID = 0
            
            objAccount.sessionID = objSession.sessionID
            objAccount.bookieID = objSessionLocal.bookieID
            objAccount.isMatch = 0
            
            var amount:Double = 0
            var commiAmount:Double = 0
            
            for j in 0 ..< objSessionLocal.arrRecordPerBookie.count {
                
                let objSessionSoda = objSessionLocal.arrRecordPerBookie[j] as! SessionSoda
                
                if objSession.isCommi == 0 {
                    objSessionSoda.commision = 0.0
                }
                
                if objSessionSoda.thay == 1 {
                    if Int32(txtFinalRun.text!) >= objSessionSoda.Run
                    {
                        amount = amount + (objSessionSoda.amount * objSessionSoda.bhav)
                        
                    }
                    else
                    {
                        amount = amount - (objSessionSoda.amount * objSessionSoda.bhav)
                        
                    }
                }
                else{
                    
                    if Int32(txtFinalRun.text!) >= objSessionSoda.Run{
                        
                        amount = amount - (objSessionSoda.amount * objSessionSoda.bhav)
                        
                    }
                    else{
                        amount = amount + (objSessionSoda.amount * objSessionSoda.bhav)
                        
                    }
                }
                commiAmount = commiAmount + (objSessionSoda.amount * objSessionSoda.commision/100)
            }
            objAccount.amount = amount * -1
            
            objAccount.commiAmount = commiAmount
            let strQuery:String = "INSERT INTO AccountTBL(MatchID,BookieID,SessionID,isMatch,Amount,CommiAmount) VALUES ('\(objAccount.matchID)','\(objAccount.bookieID)','\(objAccount.sessionID)','\(objAccount.isMatch)','\(objAccount.amount)','\(objAccount.commiAmount)')"
            
            let isInserted = ModelManager.getInstance().updateRecord(strQuery)
            
            if isInserted {
                print("inserted")
            }
            else{
                print("Problem")
            }
            
            
            for j in 0 ..< arrBookie.count
            {
                
                let objBookie = arrBookie[j]
                
                if objBookie.bookieID == objSessionLocal.bookieID {
                    
                    
                    objBookie.amount = objBookie.amount + objAccount.amount
                    
                    objBookie.sessionCommissionRS = objBookie.sessionCommissionRS + objAccount.commiAmount
                    
                    let strQuery = String(format: "UPDATE BookieTBL SET Amount='%f', SessionCommiRS='%f' WHERE BookieID ='%d'", arguments: [objBookie.amount,objBookie.sessionCommissionRS, objBookie.bookieID])
                    
                    let isUpdated = ModelManager.getInstance().updateRecord(strQuery)
                    
                    if isUpdated{
                        break;
                    }
                    else
                    {
                        Util.invokeAlertMethod("", strBody: "Error in inserting record.", delegate: nil)
                    }
                    
                }
                
            }*/
            
        }
        
    }

    
    @IBAction func cancelClose(){
        
        lblFinalAmount.text = ""
        txtFinalRun.text = ""
        if txtFinalRun.isFirstResponder {
            txtFinalRun.resignFirstResponder()
        }
        viewClose.removeFromSuperview()
        viewBlackGloble.removeFromSuperview()
    }
    
    
    
    @IBAction func insertNewObject(_ sender: AnyObject) {
        
        let storyBoardSession:UIStoryboard = UIStoryboard(name: "Session", bundle: nil)
        
        let sessionDetailVC = storyBoardSession.instantiateViewController(withIdentifier: "SessionDetailViewController") as! SessionDetailViewController
        sessionDetailVC.objSession = objSession
        sessionDetailVC.title = self.title
        self.navigationController?.pushViewController(sessionDetailVC, animated: true)
    }

    
    func calculateArray()
    {
        arrShowBook.removeAllObjects()
        
        let arrayMinMax = ModelManager.getInstance().getMaxMinValue(objSession)
        maxRun = Int32(arrayMinMax.object(at: 0) as! String)
        minRun = Int32(arrayMinMax.object(at: 1) as! String)
        
        maxRun = maxRun + Int32(4)
        minRun = minRun - Int32(4)
        
        let length = maxRun - minRun + Int32(1)
        
        for i in 0 ..< length {
            
            let objSessionBook = SessionBookShow()
            
            objSessionBook.run = minRun + i
            
            if objSessionBook.run == objSessionSodaGloble.Run {
                objSessionBook.isLastRecord = true
            }
            
            
            objSessionBook.amount = self.calculateAmount(objSessionBook.run)
            
            arrShowBook.add(objSessionBook);
        }
        
        tblView.reloadData()
    }

    
    //MARK: Calculate BOOK
    func calculateAmount(_ runScore:Int32) -> Double
    {
        var finalAmount:Double = 0.0
        
        
        for i in 0 ..< arrSessionSoda.count {
            
            let objSessionSoda = arrSessionSoda[i] as! SessionSoda
            if objSession.isCommi == 0 {
                objSessionSoda.commision = 0
            }
            
            
            if objSessionSoda.thay == 1
            {
                
                if runScore >= objSessionSoda.Run {
                    finalAmount = finalAmount + ((objSessionSoda.bhav/100) * objSessionSoda.amount) + (objSessionSoda.amount * objSessionSoda.commision/100)
                }
                else{
                    finalAmount = finalAmount + (objSessionSoda.amount * objSessionSoda.commision/100) - objSessionSoda.amount
                }
                
            }
            else
            {
                if runScore >= objSessionSoda.Run
                {
                    
                    
                    finalAmount = finalAmount + (objSessionSoda.amount * objSessionSoda.commision/100) - (objSessionSoda.amount * (objSessionSoda.bhav/100))
                }
                else{
                    finalAmount = finalAmount + (objSessionSoda.amount * objSessionSoda.commision/100) + objSessionSoda.amount
                }
                
            }
            
        }
        
        return finalAmount
    }

    
    //MARK: DB Call
    
    func getAllSessionSoda()  {
        
        
        arrSessionSodaList = NSMutableArray()
        
        var arrDB:NSMutableArray!
        
        
        arrDB = ModelManager.getInstance().getAllDetailOfSession("SELECT * FROM SessionSodaTBL WHERE SessionID = \(objSession.sessionID) ORDER BY SessionSodaID DESC")
        let objSet:NSMutableSet = NSMutableSet()
        
        if arrDB.count == 0 {
            lblMessage.isHidden = false
            tblView.isHidden = true
        }
        else
        {
            lblMessage.isHidden = true
            tblView.isHidden = false

        }
        
        for i in 0 ..< arrDB.count{
            
            let objMatchSoda = arrDB[i] as! SessionSoda
            
            objSet.add(String(objMatchSoda.bookieID))
            
        }
        var arrSet = objSet.allObjects
        
        
        for i in 0 ..< arrSet.count
        {
            
            let setValue = arrSet[i] as! String
            
            let objMatchLocal:SessionSodaList = SessionSodaList()
            
            for j in 0 ..< arrDB.count
            {
                
                let objMatch = arrDB[j] as! SessionSoda
                
                
                if setValue ==  String(objMatch.bookieID)
                {
                    objMatchLocal.arrRecordPerBookie.add(objMatch)
                }
            }
            
            for j in 0 ..< arrBookie.count {
                
                let objBookie = arrBookie[j] 
                
                if setValue == String(objBookie.bookieID) {
                    objMatchLocal.bookieID = objBookie.bookieID
                    objMatchLocal.strBookieName = objBookie.bookieName
                    objMatchLocal.sessionCommi = objBookie.sessionCommission
                    break;
                }
                
            }
            arrSessionSodaList.add(objMatchLocal)
        }
        

        if arrSessionSodaList.count > 0 {
                tblView.reloadData()
        }
        

    }
    
    func getAllBookieList(){
        
        arrBookie = ModelManager.getInstance().getAllBookieData(query: "SELECT * FROM BookieTBL ORDER BY BookieName ASC")
    }
    
    
    
    
    //MARK: TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if range.location > 2 {
                return false
            }

        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool { // do stuff
    
        if textField.text != "" {
            lblFinalAmount.text = String(format: "%@ = %.3f",kBOOKNAME, self.calculateAmount(Int32(txtFinalRun.text!)!))
            finalAmount = self.calculateAmount(Int32(txtFinalRun.text!)!)
        }
        else{
            lblFinalAmount.text = ""
        }
        
        
        
        return true
    }
    
     func textFieldShouldClear(_ textField: UITextField) -> Bool{
        
        lblFinalAmount.text = ""

        return true
    }
    
    
    //MARK: TableView Delegate Methods
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        
        if segment.selectedSegmentIndex == 0 {
            return arrSessionSodaList.count
        }
        else{
            return 1
        }
        
    }

   
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        
        if segment.selectedSegmentIndex == 0 {
            let objMatchLocal = arrSessionSodaList[section] as! SessionSodaList
            return objMatchLocal.strBookieName
        }
        else{
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segment.selectedSegmentIndex == 0 {
            let objSessionSodaList = arrSessionSodaList[section] as! SessionSodaList
            return objSessionSodaList.arrRecordPerBookie.count
        }
        else{
            return arrShowBook.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.backgroundColor = Util.setCellBackgroundColor()
                
        if segment.selectedSegmentIndex == 0 {
            
            let lblRun = cell.viewWithTag(11) as! UILabel
            let lblAmout = cell.viewWithTag(12) as! UILabel
            let lblSessionDetailDate = cell.viewWithTag(13) as! UILabel

            
            let objSessionSodaList = arrSessionSodaList[(indexPath as NSIndexPath).section] as! SessionSodaList
            
            let object = objSessionSodaList.arrRecordPerBookie[(indexPath as NSIndexPath).row] as! SessionSoda
            var strSodo:String
            
            if object.thay == 1 {
                strSodo = "L"
            }
            else{
                strSodo = "K"
            }
            
            //cell.textLabel!.text = object.run + " " + strSodo + "    " + object.amount + "  " + object.sessionDetailDate
            
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
            
            
            let attributedStringForObject = NSMutableAttributedString(string: "Run =  " +  String(object.Run) + "  ",attributes:dicWhite)
            
            let attributedStringForSoda = NSMutableAttributedString(string: strSodo,
                                                                    attributes:dicBlack)
            
            attributedStringForObject.append(attributedStringForSoda)
            
            lblRun.attributedText = attributedStringForObject
            
            
            
//            lblRun.text = "Run = " + String(object.Run) + "  " + strSodo as String
            lblAmout.text = String(format: "%.1f",object.amount) + " * " + String(format: "%.2f",object.bhav)
            lblSessionDetailDate.text = object.sessionSodaDate as String
            
//            lblRun.textColor = .white
            lblAmout.textColor = .white
            lblSessionDetailDate.textColor = .white
            
            if isReadOnly == 1 {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            lblSessionDetailDate.isHidden = false

        }
        else{
            
            let lblRun = cell.viewWithTag(11) as! UILabel
            let lblAmout = cell.viewWithTag(12) as! UILabel
            let lblSessionDetailDate = cell.viewWithTag(13) as! UILabel

            
            let objBookShow = arrShowBook[(indexPath as NSIndexPath).row] as! SessionBookShow
            
            lblRun.text = "Run = " + String(objBookShow.run)
            lblAmout.text = String(format:"%.3f",objBookShow.amount)
            //lblAmout.frame = CGRect(x: lblAmout.frame.origin.x, y: lblAmout.frame.origin.y, width: 140, height: lblAmout.frame.size.height)

            if objBookShow.isLastRecord == true {
                lblRun.font = UIFont(name: "Helvetica-Bold", size: 18.0)
                lblAmout.font = UIFont(name: "Helvetica-Bold", size: 18.0)
                lblRun.textColor = Util.setNavigationBarColor()
                lblAmout.textColor = Util.setNavigationBarColor()
            }
            else{
                lblRun.font = Util.setCellMainTitleFont()
                lblAmout.font = Util.setCellMainTitleFont()
                lblRun.textColor = .white
                lblAmout.textColor = .white
            }

           
            
            lblSessionDetailDate.isHidden = true
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        if segment.selectedSegmentIndex == 0 {
            if isReadOnly == 1 {
                return false
            }
            else{
                return true
            }
        }
        else{
            return false
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let objSessionSodaList = arrSessionSodaList[(indexPath as NSIndexPath).section] as! SessionSodaList
            
            
            
            let object = objSessionSodaList.arrRecordPerBookie[(indexPath as NSIndexPath).row] as! SessionSoda
            
            
            let alert = UIAlertController(title: kAPPNAME, message: "Are you Sure to Delete this Soda?", preferredStyle: .alert)
            
            let alertCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let alertDelete = UIAlertAction(title: "Delete", style: .destructive, handler: {
                (alertAc:UIAlertAction) in
                
                let isDeleted = ModelManager.getInstance().deleteSesionDetailData(object)
                self.getAllSessionSoda()
                self.checkBook()
                if isDeleted{
                    let alertMessage = UIAlertController(title: kAPPNAME, message: "Soda Deleted Successfully.", preferredStyle: .alert)
                    let alertOK = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alertMessage.addAction(alertOK)
                    self.showDetailViewController(alertMessage, sender: self)
                }
            })
            
            alert.addAction(alertCancel)
            alert.addAction(alertDelete)
            
            showDetailViewController(alert, sender: self)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        if segment.selectedSegmentIndex == 0 {
            if isReadOnly == 0 {
                let objSessionSodaList = arrSessionSodaList[(indexPath as NSIndexPath).section] as! SessionSodaList
                
                let sessionDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "SessionDetailViewController") as! SessionDetailViewController
                sessionDetailVC.objSession = objSession
                sessionDetailVC.objSesionDetail = objSessionSodaList.arrRecordPerBookie[(indexPath as NSIndexPath).row] as! SessionSoda
                
                
                sessionDetailVC.title = self.title
                self.navigationController?.pushViewController(sessionDetailVC, animated: true)
            }
        }
        
        tblView.deselectRow(at: indexPath, animated: true)
        
    }
    //MARK: Keyboard Notification
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            print(keyboardHeight)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.viewClose.frame = CGRect(x: self.viewClose.frame.origin.x, y: self.viewClose.frame.size.height - 100, width: self.viewClose.frame.size.width, height: self.viewClose.frame.size.height)
            }, completion: nil)
        }
    }
    
    // MARK: - GADBannerViewDelegate methods
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
                tblView?.tableHeaderView?.frame = bannerView.frame
                tblView?.tableHeaderView = bannerView
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}
