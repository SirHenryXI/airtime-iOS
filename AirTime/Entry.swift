//
//  Entry.swift
//  AirTime
//
//  Created by Chase Acton on 2/2/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

class Entry2 : NSObject{
    
    var entryID: String
    var project: String
    var task: String
    var client: String
    var hours: String
    var date: String
    
    override init(){
        self.entryID = ""
        self.project = ""
        self.task = ""
        self.client = ""
        self.hours = ""
        self.date = ""
    }
    
}