//
//  ViewController.swift
//  fmdb-demo
//
//  Created by Roland on 2019-02-12.
//  Copyright © 2019 Game of Apps. All rights reserved.
//

import UIKit
import FMDB

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //////
        // This next section should only be executed ONCE when the app is first deployed
        // Set up database path
        let filemgr = FileManager.default
        
        // Returns the path to the document directory
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard dirPaths.count > 0 else {
            print("Error in retrieving document folder")
            return
        }

        let databasePath = dirPaths[0].appendingPathComponent("contacts.db")
        print("databasePath = \(databasePath)")
        
        // Create database (in our documents folder, file is named contacts.db) -- if database already exists, then this command will just open it
        let contactDb = FMDatabase(url: databasePath)
        
        // Check if database is open (if so, it's been created or opened properly)
        guard contactDb.open() else {
            print("Error: \(contactDb.lastErrorMessage())")
            return
        }
        
        // At this point, database is now open
        
        
        // Let's create a CONTACTS table
        var sql = "CREATE TABLE IF NOT EXISTS contacts (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, phone TEXT);"
        guard contactDb.executeStatements(sql) else {
            print("Error: \(contactDb.lastErrorMessage())")
            return
        }
        
        //// End of initial app set up section
        
        
        // Insert a row into the Contacts table
        // In a real app, the contact will be created as a response to an Add Button, and the user will enter the field values
        // In this example below, we've just hard-coded the values
        // This way embeds the values to be inserted into the string
        var name = "Joe Smith"
        var address = "123 Abc Street"
        var phone = "555-555-5555"
        // The quotes around the TEXT values to be inserted must be escaped so the quote doesn't prematurely end the Swift string. Or you can use single quotes as well
        sql = "INSERT INTO contacts (name, address, phone) VALUES (\"\(name)\", \"\(address)\", '\(phone)')"
        guard contactDb.executeUpdate(sql, withArgumentsIn: []) else {
            print("Error: \(contactDb.lastErrorMessage())")
            return
        }

        // This is an alternative way of providing the arguments, we use "?"s as placeholders, then supply the arguments in the arguments array
        name = "Jane Doe"
        address = "456 Def Road"
        phone = "666-666-6666"
        sql = "INSERT INTO contacts (name, address, phone) VALUES (?, ?, ?)"
        guard contactDb.executeUpdate(sql, withArgumentsIn: [name, address, phone]) else {
            print("Error: \(contactDb.lastErrorMessage())")
            return
        }
        
        
        // Retrievals
        
        // Let's retrieve all the records
        sql = "SELECT name, address, phone FROM contacts"
        var results = contactDb.executeQuery(sql, withArgumentsIn: [])
        guard let dataSet = results else {
            print("Query returned nil")
            return
        }
        while dataSet.next() {
            // The following guard statement considers nil name/address/phone to be an invalid row
            guard let name = dataSet.string(forColumn: "name"), let address = dataSet.string(forColumn: "address"), let phone = dataSet.string(forColumn: "phone") else {
                // Retrieved a record where either name, address of phone is nil
                print("Retrieved an invalid row")
                continue
            }
            // Succesfully retrieved the row
            print("Retrieved name=\(name), address=\(address), phone=\(phone)")
        }
        
        
        // Retrieve with a WHERE clause
        // In a regular app, the nameToSearch will probably be provided by the user
        let nameToSearch = "James"
        sql = "SELECT name, address, phone FROM contacts WHERE name = \"\(nameToSearch)\""
        results = contactDb.executeQuery(sql, withArgumentsIn: [])
        guard let dataSet1 = results else {
            print("Query returned nil")
            return
        }
        while dataSet1.next() {
            // Retrieve fields as is without using guard statement--this means nil values are allowed
            let name = dataSet1.string(forColumn: "name")
            let address = dataSet1.string(forColumn: "address")
            let phone = dataSet1.string(forColumn: "phone")
            
            // Succesfully retrieved the row
            print("Retrieved name=\(String(describing: name)), address=\(String(describing: address)), phone=\(String(describing: phone))")
        }

        
        // Close database
        contactDb.close()
        
        
        //        let date = Date()
        //        let numberOfSeconds = date.timeIntervalSinceReferenceDate
    }


}

