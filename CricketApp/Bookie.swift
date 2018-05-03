//
//  Bookie.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 17/05/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation

class Bookie: NSObject {
    
    var bookieID = Int32()
    var bookieName = String()
    var bookieDate = String()
    var bookiePhone = String()
    var bookieEmail = String()
    var city = String()
    var ODICommission = Double()
    var testCommission = Double()
    var sessionCommission = Double()
    
    var amount = Double()
    
    
    var ODICommissionRS = Double()
    var testCommissionRS = Double()
    var sessionCommissionRS = Double()
    
    var totalAmount = Double()
    
}

class Hawala:NSObject{
    
    var hawalaID = Int32()
    var fromBookieID = Int32()
    var bookieName = String()
    var toBookieID = Int32()
    var remarks = String()
    var amount = Double()
    var hawalaDate = String()
    
}
