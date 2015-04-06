//
//  LoginViewController.swift
//  AirTime
//
//  Created by Chase Acton on 1/27/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate{
    
    var harvest = HarvestManager.sharedInstance() as! HarvestManager
    //    var harvest2 = HarvestManager2.sharedInstance as HarvestManager2
    
    @IBOutlet var usernameField : UITextField?
    @IBOutlet var passwordField : UITextField?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Register for local notifications
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes:
            UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        
        //Check for saved credentials
        self.checkLogin()
    }
    
    func checkLogin(){
        if Account.exists(){
            usernameField?.text = Account.username()
            
            if Account.autoLogin(){
                self.touchIDLoginWithUsername(Account.username())
            }else{
                //Attempt Touch ID login if device has it
                let context : LAContext = LAContext()
                
                var error: NSError?
                
                // Set the reason string that will appear on the authentication alert.
                var reasonString = "Sign in to AirTime"
                
                // Check if the device can evaluate the policy.
                if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
                    [context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                        
                        if success {
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                self.touchIDLoginWithUsername(Account.username())
                            })
                        }
                        else{
                            // If authentication failed then show a message to the console with a short description.
                            // In case that the error is a user fallback, then show the password alert view.
                            println(evalPolicyError?.localizedDescription)
                            
                            switch evalPolicyError!.code {
                                
                            case LAError.SystemCancel.rawValue:
                                println("Authentication was cancelled by the system")
                                
                            case LAError.UserCancel.rawValue:
                                println("Authentication was cancelled by the user")
                                
                            case LAError.UserFallback.rawValue:
                                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                    self.enterPassword()
                                })
                            default:
                                println("Authentication failed")
                            }
                        }
                    })]
                }
            }
        }
    }
        
    func enterPassword(){
        passwordField?.becomeFirstResponder()
    }
    
    func touchIDLogin(){
        self.touchIDLoginWithUsername(Account.username())
    }
    
    func touchIDLoginWithUsername(username:String){
        SVProgressHUD.showWithStatus("Authenticating", maskType: SVProgressHUDMaskType.Gradient)
        var password:String = SSKeychain.passwordForService("Harvest", account: username)
        harvest.loginWithUsername(username, password: password) { (authenticated) -> Void in
            if authenticated{
                //Load content before moving on
                SVProgressHUD.showWithStatus("Loading Harvest Data", maskType: SVProgressHUDMaskType.Gradient)
                self.loadRecent()
            }else{
                SVProgressHUD.showErrorWithStatus("Invalid username or password")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField{
            passwordField?.becomeFirstResponder()
            return false
        }else if textField == passwordField{
            self.login()
            return false
        }
        return true
    }
    
    @IBAction func login(){
        let usernameText : String = usernameField!.text
        let passwordText : String = passwordField!.text
        
        if count(usernameText) > 0 && count(passwordText) > 0{
            self.view.endEditing(true)
            SVProgressHUD.showWithStatus("Authenticating", maskType: SVProgressHUDMaskType.Gradient)
            harvest.loginWithUsername(usernameText, password: passwordText, completion: { (authenticated) -> Void in
                if authenticated{
                    //Authentication was successful, save credentials in Keychain
                    SSKeychain.setPassword(passwordText, forService: "Harvest", account: usernameText)
                    NSUserDefaults.standardUserDefaults().setObject(usernameText, forKey: "HarvestEmail")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    //Load content before moving on
                    SVProgressHUD.showWithStatus("Loading Harvest Data", maskType: SVProgressHUDMaskType.Gradient)
                    self.loadRecent()
                }else{
                    SVProgressHUD.showErrorWithStatus("Invalid username or password")
                }
            })
        }else{
            CAAlert.alertWithTitle("Error", message: "Please enter your username and password")
        }
    }
    
    func loadRecent(){
        harvest.batch { (success) -> Void in
            SVProgressHUD.dismiss()
            if success{
                if NSUserDefaults.standardUserDefaults().objectForKey("autoLogin") == nil{
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "autoLogin")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                self.performSegueWithIdentifier("homeSegue", sender: self)
            }else{
                CAAlert.requestFailedAlert()
            }
        }
    }
    
    @IBAction func forgotPassword(){
        UIApplication.sharedApplication().openURL(NSURL(string:kHarvestLoginURL)!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        usernameField?.text = nil
        passwordField?.text = nil
    }
}