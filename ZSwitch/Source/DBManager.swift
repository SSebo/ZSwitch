//
//  DBManager.swift
//  ZSwitch
//
//  Created by zhangshibo on 11/10/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Foundation
import FMDB

class DBManager {
    
    static let shared = DBManager()
    private var fileURL:URL?
    
    private init() {
        fileURL = prepareUrl()
        prepareDB()
    }
    
    static func log(name: String) {
        self.shared.insert(name: name)
    }
    
    func insert(name: String) {
        if name == "" {
            return
        }
        let database = FMDatabase(url: fileURL)
        
        guard database.open() else {
            NSLog("Unable to open database")
            return
        }
        let now = Date()
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let nowStr = formatter.string(from: now)
        do {
            try database.executeUpdate(
                "INSERT INTO switch_history (APP_NAME, TIME, TIME_STR) values (?,?,?)",
                values: [name, now, nowStr])
        } catch {
            NSLog("failed: \(error.localizedDescription)")
        }
        database.close()
    }
    
    private func prepareUrl() -> URL {
        var url = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("ZSwitch")
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {}
        url.appendPathComponent("switch_history.sqlite")
        return url
    }
    
    private func prepareDB() {
        let database = FMDatabase(url: fileURL)
        
        guard database.open() else {
            NSLog("Unable to open database")
            return
        }
        
        do {
            try database.executeUpdate("""
                CREATE TABLE switch_history(
                    ID INTEGER PRIMARY KEY AUTOINCREMENT,
                    APP_NAME TEXT,
                    TIME TEXT,
                    TIME_STR TEXT
                )
            """, values: nil)
        } catch {
            NSLog("failed: \(error.localizedDescription)")
        }
        database.close()
    }
 
    func openDb() {

        let database = FMDatabase(url: fileURL)
        
        guard database.open() else {
            NSLog("Unable to open database")
            return
        }

        database.close()
    }
}
