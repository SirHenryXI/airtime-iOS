//
//  ConfigureBeaconsViewController.swift
//  AirTime
//
//  Created by Chase Acton on 1/21/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

import UIKit

class ConfigureBeaconsViewController: UIViewController {

    @IBOutlet weak var topBar: UIToolbar?
    @IBOutlet weak var uuidLabel: UITextView?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        topBar?.clipsToBounds = true
        uuidLabel?.text = "To configure AirTime beacons, please visit " + kBeaconConfigURL
        self.navigationController?.interactivePopGestureRecognizer.delegate = nil
    }
    
    @IBAction func openSafari(){
        UIApplication.sharedApplication().openURL(NSURL(string:kBeaconConfigURL)!)
    }
    
    @IBAction func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}