//
//  DataManager.swift
//  AssignmentOnTableViews
//
//  Created by Smitha Ramamurthy on 12/03/18.
//  Copyright © 2018 Smitha Ramamurthy. All rights reserved.
//

import Cocoa

class Employee: NSObject, Decodable {
    @objc dynamic var name: String
    @objc dynamic var empID: String
    
    override init() {
        self.name = ""
        self.empID = ""
    }
    
    /// Parse the JSON data using Codable Protocol
    /// - Parameter dataString: Multiline data string received from web server
    /// - Returns: An Array of Employees decoded from the dataString
    static func decode(data: Data) -> [Employee] {
        var employeeData = [Employee]()
        do {
            employeeData = try JSONDecoder().decode([Employee].self, from: data)
        } catch {
            print("Error Parsing JSON ")
        }
        return employeeData
    }
}

