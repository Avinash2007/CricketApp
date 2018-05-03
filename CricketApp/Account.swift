//
//  Account.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 16/07/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation

class Account: NSObject {
    
    var accountID: Int32 = Int32()
    var bookieID: Int32 = Int32()
    var bookieName:String = String()
    
    var matchID: Int32 = Int32()
    var sessionID:Int32 = Int32()
    var isMatch:Int32 = Int32()
    var amount:Double = Double()
    var commiAmount:Double = Double()
}
