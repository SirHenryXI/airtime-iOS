//
//  User.swift
//  AirTime
//
//  Created by Chase Acton on 2/3/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

class User2 : NSObject{
    
    var avatar_url: String
    var email: String
    var first_name: String
    var last_name: String
    var userID: String
    
    override init(){
        self.avatar_url = ""
        self.email = ""
        self.first_name = ""
        self.last_name = ""
        self.userID = ""
    }
    
}