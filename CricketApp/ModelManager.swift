//
//  ModelManager.swift
//  CricketApp
//
//  Created by Avinash Meghnathi on 18/05/16.
//  Copyright © 2016 Avinash Meghnathi. All rights reserved.
//

import Foundation
import FMDB
let sharedInstance = ModelManager()

class ModelManager: NSObject {
    var  database:FMDatabase? = nil
    
    class func getInstance() -> ModelManager{
        
        if (sharedInstance.database == nil) {
            sharedInstance.database = FMDatabase(path: Util.getPath("CKTDB.sqlite"))
        }
        return sharedInstance
    }
    
    //MARK: BookieTable
    
    func addBookieData(_ bookieInfo: Bookie) ->Bool{
        sharedInstance.database!.open()
//        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO BookieTBL(BookieName,BookieCode,BookieDate,BookiePhone,BookieEmail,City,SessionCommi,ODICommi,TestCommi) VALUES (?,?,?,?,?,?,?,?,?)", withArgumentsInArray: [bookieInfo.bookieName,bookieInfo.bookieCode, bookieInfo.bookieDate,bookieInfo.bookiePhone,bookieInfo.bookieEmail,bookieInfo.city])
        
        
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO BookieTBL(BookieName,BookieDate,BookiePhone,BookieEmail,City,SessionCommi,ODICommi,TestCommi,Amount) VALUES ('\(bookieInfo.bookieName)','\(bookieInfo.bookieDate)','\(bookieInfo.bookiePhone)','\(bookieInfo.bookieEmail)','\(bookieInfo.city)','\(bookieInfo.sessionCommission)','\(bookieInfo.ODICommission)','\(bookieInfo.testCommission)','\(bookieInfo.amount)')", withArgumentsIn:nil)

        
        
        sharedInstance.database!.close()
        return isInserted
        
    }
    
    func updateBookieData(_ bookieInfo: Bookie) -> Bool {
        sharedInstance.database!.open()
//        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE BookieTBL SET BookieName=?, BookieCode=? BookieDate=? WHERE BookieID=\(bookieInfo.bookieID)", withArgumentsInArray: [bookieInfo.bookieName, bookieInfo.bookieCode, bookieInfo.bookieDate])
        
        let strQuery = String(format: "UPDATE BookieTBL SET BookieName='%@', BookieDate='%@', BookiePhone='%@', BookieEmail='%@',City='%@', SessionCommi='%f', ODICommi='%f', TestCommi='%f'  WHERE BookieID ='%d'", arguments: [bookieInfo.bookieName,bookieInfo.bookieDate,bookieInfo.bookiePhone,bookieInfo.bookieEmail,bookieInfo.city,bookieInfo.sessionCommission,bookieInfo.ODICommission,bookieInfo.testCommission,bookieInfo.bookieID])
        
        let isUpdated = sharedInstance.database!.executeStatements(strQuery)
        
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteBookieData(_ bookieInfo: Bookie) -> Bool {
        sharedInstance.database!.open()
        
        let isDeleted = sharedInstance.database!.executeStatements("DELETE FROM BookieTBL WHERE BookieID=\(bookieInfo.bookieID)")
        
        sharedInstance.database!.close()
        return isDeleted
    }
    
    func getAllBookieData(query: String) -> [Bookie] {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery(query, withArgumentsIn: nil)
        var arrStudentInfo = [Bookie]()
        if (resultSet != nil) {
            while resultSet.next() {
                let bookieInfo = Bookie()
                bookieInfo.bookieID = resultSet.int(forColumn: "BookieID")
                bookieInfo.bookieName = resultSet.string(forColumn: "BookieName")
                bookieInfo.bookieDate = resultSet.string(forColumn: "BookieDate")
                bookieInfo.bookiePhone = resultSet.string(forColumn: "BookiePhone")
                bookieInfo.bookieEmail = resultSet.string(forColumn: "BookieEmail")
                bookieInfo.city = resultSet.string(forColumn: "City")
                bookieInfo.sessionCommission = resultSet.double(forColumn: "SessionCommi")
                bookieInfo.ODICommission = resultSet.double(forColumn: "ODICommi")
                bookieInfo.testCommission = resultSet.double(forColumn: "TestCommi")
                bookieInfo.amount = resultSet.double(forColumn: "Amount")
                bookieInfo.sessionCommissionRS = resultSet.double(forColumn: "SessionCommiRS")
                bookieInfo.ODICommissionRS = resultSet.double(forColumn: "ODICommiRS")
                bookieInfo.testCommissionRS = resultSet.double(forColumn: "TestCommiRS")
                bookieInfo.totalAmount = resultSet.double(forColumn: "TotalAmount")
                arrStudentInfo.append(bookieInfo)
            }
        }
        sharedInstance.database!.close()
        return arrStudentInfo
    }
    
    func getBookieName(strQuary:String) -> Bool{
        
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery(strQuary, withArgumentsIn: nil)
        
        var isRecordAvail = false
        
        if (resultSet != nil) {
            while resultSet.next() {
                isRecordAvail = true
            }
        }
        sharedInstance.database!.close()
        
        return isRecordAvail
    }
    
    
    /******************************************ODI Table***************************************************/
    
    // MARK: Match TABLE
    
    func addMatchData(_ objMatch: MatchClass) ->Bool{
        sharedInstance.database!.open()
       
        
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO MatchTBL(Team1,Team2,Team3,isTest,isCommi,isActive,MatchDate,WinnerTeam) VALUES ('\(objMatch.team1)','\(objMatch.team2)','\(objMatch.team3)','\(objMatch.isTest)','\(objMatch.isCommi)','\(objMatch.isActive)','\(objMatch.matchDate)','\(objMatch.winnerTeam)')", withArgumentsIn:nil)
        
        
        sharedInstance.database!.close()
        return isInserted
        
    }
    
    func updateMatchData(_ objMatch: MatchClass) -> Bool {
        sharedInstance.database!.open()
        //        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE BookieTBL SET BookieName=?, BookieCode=? BookieDate=? WHERE BookieID=\(bookieInfo.bookieID)", withArgumentsInArray: [bookieInfo.bookieName, bookieInfo.bookieCode, bookieInfo.bookieDate])
        
        let strQuery = String(format: "UPDATE MatchTBL SET Team1='%@', Team2='%@', Team3='%@', isTest='%d', isCommi='%d', isActive='%d'  WHERE MatchID ='%d'", arguments: [objMatch.team1,objMatch.team2,objMatch.team3,objMatch.isTest,objMatch.isCommi,objMatch.isActive,objMatch.matchID])
        
        let isUpdated = sharedInstance.database!.executeStatements(strQuery)
        
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteMatchData(_ objMatch: MatchClass) -> Bool {
        sharedInstance.database!.open()
        
        let isDeleted = sharedInstance.database!.executeStatements("DELETE FROM MatchTBL WHERE MatchID=\(objMatch.matchID)")
        
        sharedInstance.database!.close()
        return isDeleted
    }
    
    func getAllActiveMatch(_ query:String) -> [MatchClass] {
        sharedInstance.database!.open()
        
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery(query, withArgumentsIn: nil)
        var arrMatchDetail = [MatchClass]()
        if (resultSet != nil) {
            while resultSet.next() {
                let objMatch = MatchClass()
            
                objMatch.matchID = resultSet.int(forColumn: "MatchID")
                
                objMatch.team1 = resultSet.string(forColumn: "Team1")
                objMatch.team2 = resultSet.string(forColumn: "Team2")
                objMatch.team3 = resultSet.string(forColumn: "Team3")
                
                objMatch.isTest = resultSet.int(forColumn: "isTest")
                
                objMatch.isCommi = resultSet.int(forColumn: "isCommi")
                objMatch.isActive = resultSet.int(forColumn: "isActive")
             
                objMatch.matchDate = resultSet.string(forColumn: "MatchDate")
                objMatch.winnerTeam = resultSet.string(forColumn: "WinnerTeam")
                
                objMatch.Amount = resultSet.double(forColumn: "Amount")
                
                arrMatchDetail.append(objMatch)
            }
        }
        sharedInstance.database!.close()
        return arrMatchDetail
    }

    /******************************************Match Soda TABLE*********************************************/
    
    // MARK: MatchSoda TABLE
    
    func addMatchSodaData(_ matchSodaInfo:MatchSoda) -> Bool
    {
        sharedInstance.database?.open()

        
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO MatchSodaTBL(MatchID,BookieID,Bhav,Amount,Win,SodaDate,TeamCode,Commision) VALUES ('\(matchSodaInfo.matchID)','\(matchSodaInfo.bookieID)','\(matchSodaInfo.bhav)','\(matchSodaInfo.amount)','\(matchSodaInfo.win)','\(matchSodaInfo.matchSodaDate)','\(matchSodaInfo.teamCode)','\(matchSodaInfo.commision)')", withArgumentsIn:nil)
        
        sharedInstance.database?.close()
        
        return isInserted
    }
    
    
    func updateMatchSodaData(_ matchSodaInfo: MatchSoda) -> Bool {
        sharedInstance.database!.open()
        let strQuery = String(format: "UPDATE MatchSodaTBL SET BookieID='%d',Bhav='%f',Amount='%f',Win='%d',SodaDate='%@',TeamCode='%@',Commision='%f' WHERE MatchSodaID = %d", arguments:[matchSodaInfo.bookieID,matchSodaInfo.bhav,matchSodaInfo.amount,matchSodaInfo.win,matchSodaInfo.matchSodaDate,matchSodaInfo.teamCode,matchSodaInfo.commision, matchSodaInfo.matchSodaID])
        
        let isUpdated = sharedInstance.database!.executeStatements(strQuery)
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteMatchSodaData(_ matchSodaInfo: MatchSoda) -> Bool {
        sharedInstance.database!.open()
        
        let isDeleted = sharedInstance.database!.executeStatements("DELETE FROM MatchSodaTBL WHERE MatchSodaID=\(matchSodaInfo.matchSodaID)")
        
        sharedInstance.database!.close()
        return isDeleted
    }
    
    func getAllMatchSodaList(_ strQuery: String)->NSMutableArray {
        
        sharedInstance.database?.open()
        
        let resultSet:FMResultSet! = sharedInstance.database!.executeQuery(strQuery, withArgumentsIn: nil)
        let arrMatchSoda:NSMutableArray = NSMutableArray()
        
        if resultSet != nil{
            while resultSet.next() {
                let matchSodaInfo:MatchSoda = MatchSoda()
                
                matchSodaInfo.matchSodaID = resultSet.int(forColumn: "MatchSodaID")
                matchSodaInfo.matchID = resultSet.int(forColumn: "MatchID")
                matchSodaInfo.bookieID = resultSet.int(forColumn: "BookieID")
                
                matchSodaInfo.bhav = resultSet.double(forColumn: "Bhav")
                matchSodaInfo.amount = resultSet.double(forColumn: "Amount")
                
                matchSodaInfo.win = resultSet.int(forColumn: "Win")
                
                matchSodaInfo.matchSodaDate = resultSet.string(forColumn: "SodaDate")
                matchSodaInfo.teamCode = resultSet.string(forColumn: "TeamCode")
                matchSodaInfo.commision = resultSet.double(forColumn: "Commision")
                arrMatchSoda.add(matchSodaInfo)
            }
        }
        
        sharedInstance.database?.close()
        return arrMatchSoda
    }
    
      /*******************************Session TABLE*********************************************/
    // MARK: SESSION TABLE 
    
    func addSessionName(_ objSession:Session) -> Bool{
        sharedInstance.database!.open()
 
        let  isInserted = sharedInstance.database!.executeUpdate("INSERT INTO SessionTBL(SessionName,TeamName,SessionDate,isCommi,isActive,Amount,Run) VALUES ('\(objSession.sessionName)','\(objSession.teamName)','\(objSession.sessionDate)','\(objSession.isCommi)','\(objSession.isActive)','\(0)','\(0)')", withArgumentsIn: nil)
        sharedInstance.database?.close()
        return isInserted
        
    }
    
    
    func updateSessoionName(_ strQuery:String) -> Bool{
        sharedInstance.database!.open()
        
        
         let isUpdated = sharedInstance.database!.executeStatements(strQuery)
        
        sharedInstance.database?.close()
        return isUpdated
        
    }

    
    func deleteSession(_ objSession:Session) -> Bool {
        sharedInstance.database?.open()
        
         let isDeleted = sharedInstance.database!.executeStatements("DELETE FROM SessionTBL WHERE SessionID=\(objSession.sessionID)")
        sharedInstance.database?.close()
        
        return isDeleted
    }
    
    func getAllActiveSessionList(_ strQuery:String) -> [Session] {
        
        sharedInstance.database?.open()
        
        let resultSet:FMResultSet! = sharedInstance.database!.executeQuery(strQuery, withArgumentsIn: nil)
        var arrSessionList = [Session]()
        
        if resultSet != nil {
            while resultSet.next() {
                let objSession = Session()
                
                objSession.sessionID = resultSet.int(forColumn: "SessionID")
                objSession.sessionName = resultSet.string(forColumn: "SessionName")
                objSession.teamName = resultSet.string(forColumn: "TeamName")
                objSession.sessionDate = resultSet.string(forColumn: "SessionDate")
                objSession.isCommi = resultSet.int(forColumn: "isCommi")
                objSession.isActive = resultSet.int(forColumn: "isActive")
                objSession.Run = resultSet.int(forColumn: "Run")
                objSession.Amount = resultSet.double(forColumn: "Amount")
                arrSessionList.append(objSession)
            }
        }
        
        
        sharedInstance.database?.close()
        
        return arrSessionList
    }
    
    /*******************************SessionDetail TABLE****************************************/
    
    // MARK: SESSION DETAIL TABLE
    
    func addSessionDetailData(_ objSessionDetail:SessionSoda) -> Bool
    {
        sharedInstance.database?.open()
        
        
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO SessionSodaTBL(SessionID,BookieID,Run,Amount,Thay,SessionSodaDate,Bhav,Commision) VALUES ('\(objSessionDetail.sessionID)','\(objSessionDetail.bookieID)','\(objSessionDetail.Run)','\(objSessionDetail.amount)','\(objSessionDetail.thay)','\(objSessionDetail.sessionSodaDate)','\(objSessionDetail.bhav)','\(objSessionDetail.commision)')", withArgumentsIn:nil)
        
        sharedInstance.database?.close()
        
        return isInserted
    }
    
    
    func updateSessionDetailData(_ objSessionDetail: SessionSoda) -> Bool {
        sharedInstance.database!.open()
        let strQuery = String(format: "UPDATE SessionSodaTBL SET BookieID='%d',Run='%d',Amount='%f',Thay='%d',SessionSodaDate='%@',Bhav='%f',Commision='%f' WHERE SessionSodaID = %d", arguments:[objSessionDetail.bookieID,objSessionDetail.Run,objSessionDetail.amount,objSessionDetail.thay,objSessionDetail.sessionSodaDate,objSessionDetail.bhav,objSessionDetail.commision,objSessionDetail.sessionSodaID])
        
        let isUpdated = sharedInstance.database!.executeStatements(strQuery)
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func deleteSesionDetailData(_ objSessionDetail: SessionSoda) -> Bool {
        sharedInstance.database!.open()
        
        let isDeleted = sharedInstance.database!.executeStatements("DELETE FROM SessionSodaTBL WHERE SessionSodaID=\(objSessionDetail.sessionSodaID)")
        
        sharedInstance.database!.close()
        return isDeleted
    }
    
    func getAllDetailOfSession(_ strQuery: String)->NSMutableArray {
        
        sharedInstance.database?.open()
        
        let resultSet:FMResultSet! = sharedInstance.database!.executeQuery(strQuery, withArgumentsIn: nil)
        let arrSessionSoda:NSMutableArray = NSMutableArray()
        
        if resultSet != nil{
            while resultSet.next() {
                
                let objSessionDetail:SessionSoda = SessionSoda()
                
                objSessionDetail.sessionSodaID = resultSet.int(forColumn: "SessionSodaID")
                objSessionDetail.sessionID = resultSet.int(forColumn: "SessionID")
                objSessionDetail.bookieID = resultSet.int(forColumn: "BookieID")
                objSessionDetail.Run = resultSet.int(forColumn: "Run")
                objSessionDetail.amount = resultSet.double(forColumn: "Amount")
                objSessionDetail.thay = resultSet.int(forColumn: "Thay")
                objSessionDetail.bhav = resultSet.double(forColumn: "Bhav")
                objSessionDetail.sessionSodaDate = resultSet.string(forColumn: "SessionSodaDate")
                objSessionDetail.commision = resultSet.double(forColumn: "Commision")
                arrSessionSoda.add(objSessionDetail)
                
                
            }
        }
        
        sharedInstance.database?.close()
        return arrSessionSoda
    }
    
    func getMaxMinValue(_ objSession:Session)->NSMutableArray{
        sharedInstance.database?.open()
        
        let resultSet:FMResultSet! = sharedInstance.database!.executeQuery("SELECT MAX(Run),MIN(Run) FROM SessionSodaTBL WHERE SessionID = \(objSession.sessionID)", withArgumentsIn: nil)
        let arrMinMaxVal:NSMutableArray = NSMutableArray()
        
        if resultSet != nil {
            while resultSet.next() {
                arrMinMaxVal.insert(resultSet.string(forColumn: "MAX(Run)"), at: 0)
                arrMinMaxVal.insert(resultSet.string(forColumn: "MIN(Run)"), at: 1)
            }
        }
        sharedInstance.database?.close()
        return arrMinMaxVal
    }
    
    //MARK: COMMON UPDATE METHOD FOR ALL TABLE
    
    func updateRecord(_ strQuery:String) -> Bool{
        sharedInstance.database!.open()

        let isUpdated = sharedInstance.database!.executeStatements(strQuery)
        
        sharedInstance.database?.close()
        return isUpdated
        
    }
    
    //MARK: GetAccountDetail
    
    func getAccountDetailForAllMatch(_ strQuery:String)->[MatchResport]{
        
        sharedInstance.database?.open()
        
        var arrRecords = [MatchResport]()
        
        let resultSet:FMResultSet! = sharedInstance.database?.executeQuery(strQuery, withArgumentsIn: nil)
        
        if resultSet != nil {
            while resultSet.next() {
                let objMatchReport = MatchResport()
                
                objMatchReport.accountID = resultSet.int(forColumn: "AccountID")
                objMatchReport.matchID = resultSet.int(forColumn: "MatchID")
                objMatchReport.team1 = resultSet.string(forColumn: "Team1")
                objMatchReport.team2 = resultSet.string(forColumn: "Team2")
                objMatchReport.isTest = resultSet.int(forColumn: "isTest")
                objMatchReport.winnerTeam = resultSet.string(forColumn: "WinnerTeam")
                objMatchReport.matchDate = resultSet.string(forColumn: "MatchDate")
                objMatchReport.Amount = resultSet.double(forColumn: "Amount")
//                objMatchReport.commiAmount = resultSet.doubleForColumn(<#T##columnName: String!##String!#>)
                arrRecords.append(objMatchReport)
                
            }
        }
        sharedInstance.database?.close()
        return arrRecords
    }
    
    
    
    
    func getAccountDetail(_ strQuery:String)->[Account]{
        sharedInstance.database!.open()
        
        var arrRecords = [Account]()

        let resultSet:FMResultSet! = sharedInstance.database?.executeQuery(strQuery,withArgumentsIn: nil)
        
        if resultSet != nil{
            while resultSet.next() {
                
                let objAccount:Account = Account()
                
                objAccount.accountID = resultSet.int(forColumn: "AccountID")
                objAccount.matchID = resultSet.int(forColumn: "MatchID")
                objAccount.bookieID = resultSet.int(forColumn: "BookieID")
                objAccount.sessionID = resultSet.int(forColumn: "SessionID")
                objAccount.isMatch = resultSet.int(forColumn: "isMatch")
                objAccount.amount = resultSet.double(forColumn: "Amount")
                objAccount.bookieName = resultSet.string(forColumn: "BookieName")
                objAccount.commiAmount = resultSet.double(forColumn: "CommiAmount")
                
                arrRecords.append(objAccount)
            }
        }
        return arrRecords
    }

    func getAccountDetailForAllSession(_ strQuery:String)->[SessionReport]{
        
        sharedInstance.database?.open()
        
        var arrRecords = [SessionReport]()
        
        let resultSet:FMResultSet! = sharedInstance.database?.executeQuery(strQuery, withArgumentsIn: nil)
        
        if resultSet != nil {
            while resultSet.next() {
                let objSessionReport = SessionReport()
                
                objSessionReport.accountID = resultSet.int(forColumn: "AccountID")
                objSessionReport.sessionID = resultSet.int(forColumn: "SessionID")
                objSessionReport.sessionName = resultSet.string(forColumn: "SessionName")
                objSessionReport.teamName = resultSet.string(forColumn: "TeamName")
                objSessionReport.Run = resultSet.int(forColumn: "Run")
                objSessionReport.sessionDate = resultSet.string(forColumn: "SessionDate")
                objSessionReport.Amount = resultSet.double(forColumn: "Amount")
                objSessionReport.bookieAMT = resultSet.double(forColumn: "BookieAMT")
                arrRecords.append(objSessionReport)
                
            }
        }
        sharedInstance.database?.close()
        return arrRecords
    }
    
    //MARK: HAWALA Table
    
    func getHawalaDetail(query:String)->[Hawala]{
        
        sharedInstance.database?.open()
        
        var arrHawala = [Hawala]()
        
        let resultSet:FMResultSet! = sharedInstance.database?.executeQuery(query, withArgumentsIn: nil)
        
        if resultSet != nil
        {
            while resultSet.next(){
                let objHawala = Hawala()
                
                objHawala.hawalaID = resultSet.int(forColumn: "HawalaID")
                objHawala.fromBookieID = resultSet.int(forColumn: "FromBookieID")
                objHawala.toBookieID = resultSet.int(forColumn: "ToBookieID")
                objHawala.remarks = resultSet.string(forColumn: "Remarks")
                objHawala.amount = resultSet.double(forColumn: "Amount")
                objHawala.hawalaDate = resultSet.string(forColumn: "HawalaDate")
                
                arrHawala.append(objHawala)
            }
        }
        sharedInstance.database?.close()
        return arrHawala
    }
    
    func addHawalaData(objHawala:Hawala)->Bool {
        sharedInstance.database!.open()
        
        
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO HawalaTBL(FromBookieID,ToBookieID,Remarks,Amount,HawalaDate) VALUES ('\(objHawala.fromBookieID)','\(objHawala.toBookieID)','\(objHawala.remarks)','\(objHawala.amount)','\(objHawala.hawalaDate)')", withArgumentsIn:nil)
        
        
        sharedInstance.database!.close()
        return isInserted

    }
    
    func updateHawalaData(objHawala:Hawala)-> Bool{
        sharedInstance.database!.open()
       
        
        let strQuery = String(format: "UPDATE HawalaTBL SET FromBookieID='%d', ToBookieID='%d', Remarks='%@', Amount='%f', HawalaDate='%@' WHERE HawalaID ='%d'", arguments: [objHawala.fromBookieID,objHawala.toBookieID,objHawala.remarks,objHawala.amount,objHawala.hawalaDate,objHawala.hawalaID])
        
        let isUpdated = sharedInstance.database!.executeStatements(strQuery)
        
        sharedInstance.database!.close()
        return isUpdated

    }
    
    func getBookieFromBookieID(uniqueId: Int32)->Bookie {
        
        var objBookieInner:Bookie!
        for objBookieLocal in self.getAllBookieData(query: "SELECT * FROM BookieTBL ORDER BY BookieName ASC") where objBookieLocal.bookieID == uniqueId
        {
            
            objBookieInner = objBookieLocal
            break
        }
        
        return objBookieInner
        
        
    }
    
}
