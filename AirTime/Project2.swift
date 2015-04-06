//
//  Project.swift
//  AirTime
//
//  Created by Chase Acton on 2/2/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

class Project2 : NSObject, NSCoding {
    
    var projectID: String = ""
    var name: String = ""
    var active: Bool = false
    
    required init(coder aDecoder: NSCoder) {
        if let projectID = aDecoder.decodeObjectForKey("projectID") as? String {
            self.projectID = projectID
        }
        if let name = aDecoder.decodeObjectForKey("name") as? String {
            self.name = name
        }
        if let active = aDecoder.decodeObjectForKey("active") as? Bool {
            self.active = active
        }
    }
    
    func encodeWithCoder(_aCoder: NSCoder) {
        _aCoder.encodeObject(projectID, forKey: "projectID")
        _aCoder.encodeObject(name, forKey: "name")
        _aCoder.encodeBool(active, forKey: "active")

    }
    
}