//
//  ListViewModel.swift
//  CS3260FinalProject
//
//  Created by Elijah C. Cannon on 8/6/23.
//

import Foundation
import SQLite3

class ListViewModel: ObservableObject {
    
    @Published var entryList = [EntryModel]() {
        didSet {
            // this runs every time the entryList changes
            writeDatabase()
        }
    }
    var db: OpaquePointer?
    
    var dateFormatter = DateFormatter()
    
    init() {
        // create database (if not already created) then read from it
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        // database stuff
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent("Journal.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return
        }
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Entries (id INTEGER PRIMARY KEY AUTOINCREMENT, entryDate TEXT, modifiedDate TEXT, text TEXT)", nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error creating table: \(errmsg)")
        }
        
        readDatabase()
    }
    
    func readDatabase() {
        // get all entries from the database
        
        entryList.removeAll()
        let queryString = "SELECT * FROM Entries"
        var stmt:OpaquePointer?
 
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        
 
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = Int(sqlite3_column_int(stmt, 0))
            let entryDate = String(cString: sqlite3_column_text(stmt, 1))
            let modifiedDate = String(cString: sqlite3_column_text(stmt, 2))
            let text = String(cString: sqlite3_column_text(stmt, 3))
            
            guard let entryDateAsDate = dateFormatter.date(from: entryDate),
            let modifiedDateAsDate = dateFormatter.date(from: modifiedDate)
            else {
                break
            }
 
            //add values to list
            entryList.append(EntryModel(id: Int(id), entryDate: entryDateAsDate, modifiedDate: modifiedDateAsDate, text: text))
        }
    }
    
    func writeDatabase() {
        
        for entry in entryList {
            
            var stmt: OpaquePointer?
            
            let entryDateString: String = dateFormatter.string(from: entry.entryDate)
            let modifiedDateString: String = dateFormatter.string(from: entry.modifiedDate)
            let currDate: Date = Date()
            let currDateString: String = dateFormatter.string(from: currDate)
            
            // I added on conflict to update instead of creating new entries
            let queryString = "INSERT INTO Entries (id, entryDate, modifiedDate, text) VALUES (\(entry.id), '\(entryDateString)', '\(modifiedDateString)', '\(entry.text)') ON CONFLICT(id) DO UPDATE SET modifiedDate='\(currDateString)', text='\(entry.text)';"
            
            //preparing the query
            if sqlite3_prepare_v2(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing upsert: \(errmsg)")
                return
            }
            
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting entry: \(errmsg)")
                return
            }
            
            sqlite3_finalize(stmt)
            
            print("Entry saved successfully")
        }
    }
}
