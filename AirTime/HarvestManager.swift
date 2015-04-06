//
//  HarvestManager.swift
//  AirTime
//
//  Created by Chase Acton on 2/3/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

import Alamofire

class HarvestManager2 {
    

    
    var currentCompany : Company?
    var currentUser : User?
    var currentProject : Project?
    var currentTask : Task?
    var runningTimer : Timer?
    
    var currentEntries: [Entry]?
    var currentEntriesTemp: [Entry]?
    var currentTasks: [Task]?
    var currentProjects: [Project]?


    class var sharedInstance: HarvestManager2 {
        struct Static {
            static var instance: HarvestManager2?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = HarvestManager2()
        }
        return Static.instance!
    }
    
    func login(username : String, password : String, completion: ((Bool) -> Void)?){

        let plainString = "chase@chaseacton.com:pass" as NSString
        let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
        
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        defaultHeaders["Accept"] = "application/json"
        defaultHeaders["Content-Type"] = "application/json"
        defaultHeaders["Authorization"] = "Basic " + "Y2hhc2VAY2hhc2VhY3Rvbi5jb206QzEyMzQxMjM0"
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        
        let manager = Alamofire.Manager(configuration: configuration)



        

        var endpoint:String = "/account/who_am_i"
        var urlString:String = kWebServicesEndpoint + endpoint
        manager.request(.GET, urlString)
            .responseJSON {(request, response, JSON, error) in
                println(error)
                println(JSON)
        }
        
        
       // var endpoint:String = "/account/who_am_i"
//        var urlString:String = kWebServicesEndpoint + endpoint
//        println("loginWithUsername: " + urlString)
//        
//        var manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
//        manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(username, password: password)
//        manager.requestSerializer.setValue("application/json", forHTTPHeaderField:"Accept")
//        manager.requestSerializer.setValue("application/json", forHTTPHeaderField:"Content-Type")
//        manager.GET(urlString, parameters: nil, success: { (operation, JSON) -> Void in
//            
//            //let companyJSON = JSON["current_rates"] as? Dictionary<String,Any>
//
////            var companyJSON:Dictionary = JSON["company"]
//            
//        }) { (operation, error) -> Void in
//            
//        }

    }
    
    
    
    
}

/*



    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
    //                NSLog(@"loginWithUsername: %@",JSON);
    
    //Save company info
    NSDictionary *companyJSON = [JSON objectForKey:@"company"];
    Company *company = [[Company alloc] init];
    company.base_uri = [NSString stringWithFormat:@"%@",[companyJSON objectForKey:@"base_uri"]];
    company.full_domain = [NSString stringWithFormat:@"%@",[companyJSON objectForKey:@"full_domain"]];
    company.name = [NSString stringWithFormat:@"%@",[companyJSON objectForKey:@"name"]];
    self.currentCompany = company;
    
    //Save user info
    NSDictionary *userJSON = [JSON objectForKey:@"user"];
    User *user = [[User alloc] init];
    
    NSString *imageURLToCheck = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"avatar_url"]];
    //If user has a default image, it will only return the URI of the URL. A custom profile image will return the full URL
    if ([CAValidator validURL:imageURLToCheck]){
    NSLog(@"valid");
    user.avatar_url = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"avatar_url"]];
    }else{
    NSLog(@"invalid");
    user.avatar_url = [NSString stringWithFormat:@"%@%@",kWebServicesEndpoint,[userJSON objectForKey:@"avatar_url"]];
    }
    
    NSLog(@"url: %@",user.avatar_url);
    
    user.email = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"email"]];
    user.first_name = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"first_name"]];
    user.last_name = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"last_name"]];
    user.userID = [NSString stringWithFormat:@"%@",[userJSON objectForKey:@"userID"]];
    self.currentUser = user;
    block(TRUE);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
    block(FALSE);
    }];
}*/
