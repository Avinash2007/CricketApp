//
//  PartnershipViewController.swift
//  CricketApp
//
//  Created by Jeet Meghanathi on 26/11/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import UIKit

protocol PartnershipDelegate:class {
    func addPartnership(controller:PartnershipViewController, objPartnership:Partnership)
}

class PartnershipViewController: UIViewController {

    @IBOutlet weak var txtPartyName:AutoCompleteTextField!
    @IBOutlet weak var txtPartnership:UITextField!
    @IBOutlet weak var txtSelfCommission:UITextField!
    @IBOutlet weak var txtThirdPartyCommission:UITextField!
    @IBOutlet weak var segmentGame:UISegmentedControl!
    
    var arrBookieList = [Bookie]()
    var filteredBookie = [Bookie]()
    var objPartner:Partnership!
    weak var delegate:PartnershipDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Util.setFontOnLable(self.view)
        Util.setCornerRadius(self.view)
        
        self.view.backgroundColor = Util.setMainViewBGColor()
        
//        if objPartner != nil {
//            txtPartyName.text = objPartner.partyName
//            txtPartnership.text = String(objPartner.partnership)
//            txtSelfCommission.text = String(objPartner.selfCommi)
//            txtThirdPartyCommission.text = String(objPartner.partyCommi)
//
//            if objPartner.gameType == "Session" {
//                segmentGame.selectedSegmentIndex = 0
//            }
//            else if objPartner.gameType == "One Day" {
//                segmentGame.selectedSegmentIndex = 1
//            }
//            else
//            {
//                segmentGame.selectedSegmentIndex = 2
//            }
//
//        }
//        else
//        {
//            self.getBookieList()
//        }

        configureTextField()
        handleTextFieldInterfaces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        
//        txtPartyName.becomeFirstResponder()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.dismissKeyboard()
    }
    
   /* func getBookieList()
    {
        arrBookieList = ModelManager.getInstance().getAllBookieData(query: "SELECT * FROM BookieTBL ORDER BY BookieName ASC")
        
        let objBookie = Bookie()
        objBookie.bookieID = ModelManager.getInstance().getLastBookieId(strQuery: "SELECT MAX(BookieID) FROM BookieTBL")
        objBookie.bookieID += 1
        print(objBookie.bookieID)
        objBookie.bookieName = "SELF"
        arrBookieList.append(objBookie)
        
        
    }*/
    
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
        
//        txtPartyName.onSelect = {[weak self] text, indexpath in
        
//            let objBookie = self?.filteredBookie[indexpath.row]
//            print((objBookie?.bookieName)! as String)
            
//        }
    }

    
    @IBAction func addRecord(){
    /*
        if txtPartyName.text == ""{
            let alert = UIAlertController(title: kAPPNAME, message: "Please Enter Party Name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            showDetailViewController(alert, sender: self)
            
        }
        else
        {
            
            let objPartnership = Partnership()
            var isAvail = false
            
            for objBookie in arrBookieList {
                
                if objBookie.bookieName == txtPartyName.text{
//                    objPartnership.bookieID = objBookie.bookieID
                    objPartnership.partnerID = objBookie.bookieID
                    objPartnership.partyName = objBookie.bookieName
                    isAvail = true
                    break;
                }
            }
            
            if isAvail{
                
                
                if txtPartnership.text == "" && txtSelfCommission.text == ""
                {
                    let alert = UIAlertController(title: kAPPNAME, message: "Please Enter Partnership or Commission", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    showDetailViewController(alert, sender: self)
                }
                else
                {
                    objPartnership.gameType = segmentGame.titleForSegment(at: segmentGame.selectedSegmentIndex)!
                    
                    if txtPartnership.text == "" {
                        objPartnership.partnership = 0
                    }
                    else
                    {
                        objPartnership.partnership = Double(txtPartnership.text!)!
                    }
                    
                    if txtSelfCommission.text == "" {
                    
                        objPartnership.selfCommi = 0
                    }
                    else
                    {
                        objPartnership.selfCommi = Double(txtSelfCommission.text!)!
                    }
                    
                    if txtThirdPartyCommission.text == "" {
                            objPartnership.partyCommi = 0
                    }
                    else{
                        objPartnership.partyCommi = Double(txtThirdPartyCommission.text!)!
                    }
                    
                    delegate?.addPartnership(controller: self,objPartnership: objPartnership)
                   _ = self.navigationController?.popViewController(animated: true)
                    
                }
                
                
                
            }
            else
            {
                let alert = UIAlertController(title: kAPPNAME, message: "Please Enter Valid Party Name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                showDetailViewController(alert, sender: self)
            }
            
        }*/
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
            self.txtPartyName.autoCompleteStrings = arrBookieName
        })
        return
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            if touch.view == self.view{
                self.dismissKeyboard()
                
            }
        }
        
    }
    
    
    func dismissKeyboard(){
        if txtSelfCommission.isFirstResponder {
            txtSelfCommission.resignFirstResponder()
        }else if txtThirdPartyCommission.isFirstResponder {
            txtThirdPartyCommission.resignFirstResponder()
        }
        else if txtPartnership.isFirstResponder {
            txtPartnership.resignFirstResponder()
        }
        else if txtPartyName.isFirstResponder{
            txtPartyName.resignFirstResponder()
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField){
//        print(textField.text! as String)
     /*   if textField == txtPartyName {
           
            var isAvail = false
            
            for objBookie in arrBookieList {
                
                if objBookie.bookieName == txtPartyName.text{
                    isAvail = true
                    break;
                }
            }
            if !isAvail{
                let alert = UIAlertController(title: kAPPNAME, message: "Please Enter Valid Party Name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{
                    (action:UIAlertAction) in
                    
                    self.txtPartyName.becomeFirstResponder()
                }))
                showDetailViewController(alert, sender: self)
            }
            
            
            
        }*/
    }
    
    
   /* func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if textField == txtPartyName {
            if txtPartyName.text == "SELF" {
                txtPartnership.isEnabled = false
                txtThirdPartyCommission.isEnabled = false
            }
            else{
                txtPartnership.isEnabled = true
                txtThirdPartyCommission.isEnabled = true
            }
        }
        return true
    }
    */
}
