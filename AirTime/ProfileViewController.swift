//
//  ProfileViewController.swift
//  AirTime
//
//  Created by Chase Acton on 1/21/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var harvest = HarvestManager.sharedInstance() as! HarvestManager
    
    @IBOutlet weak var topBar: UIToolbar?
    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var settingsTable: UITableView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    @IBOutlet weak var companyLabel: UILabel?
    
    var datePicker = UIDatePicker()
    var toolbar = UIToolbar()
    var pickerHolder = UIView()
    var currentTimeSetting : String = ""
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.displayProfile()
        self.setupPicker()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func displayProfile(){
        topBar?.clipsToBounds = true
        
        var currentUser : User = harvest.currentUser
        
        nameLabel?.text = currentUser.first_name + " " + currentUser.last_name
        emailLabel?.text = currentUser.email
        
        let imageURL = NSURL(string: currentUser.avatar_url)
        profileImage?.sd_setImageWithURL(imageURL)
        
        if let profile = profileImage {
            var loadView = UIView(frame: CGRectMake(0, 0, profile.frame.size.width, profile.frame.size.height))
            profileImage?.layer.cornerRadius = loadView.frame.size.width/2
        }
        
        profileImage?.layer.masksToBounds = true
        profileImage?.layer.borderColor = UIColor.whiteColor().CGColor
        profileImage?.layer.borderWidth = 1.0
        
        var currentCompany : Company = harvest.currentCompany
        companyLabel?.text = currentCompany.name
    }
    
    @IBAction func done(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signOut(){
        var alert = UIAlertController(title: "Are You Sure", message:nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                Account.signOut()
                //Pop to root
                let previousView = self.presentingViewController as! UINavigationController
                self.dismissViewControllerAnimated(false, completion:  {
                    let viewControllers: [UIViewController] = previousView.viewControllers as! [UIViewController]
                    viewControllers[0].navigationController!.popToRootViewControllerAnimated(false)
                })
            default:
                break
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func setupPicker(){
        pickerHolder = UIView(frame: CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.height, 219+44))
        datePicker.datePickerMode = UIDatePickerMode.Time
        datePicker.backgroundColor = UIColor.whiteColor()
        datePicker.frame = CGRectMake(0,44,0,0)
        toolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44)
        
        var doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "closePicker")
        
        var buttons = [doneButton]
        
        toolbar.setItems(buttons, animated: false)
        
        pickerHolder.addSubview(datePicker)
        pickerHolder.addSubview(toolbar)
        
        self.view.addSubview(pickerHolder)
        
    }
    
    func changeArrivalTime(){
        currentTimeSetting = "arrivalTime"
        self.showPicker()
    }
    
    func changeLunchTime(){
        currentTimeSetting = "lunchTime"
        self.showPicker()
    }
    
    func changeDepartureTime(){
        currentTimeSetting = "departureTime"
        self.showPicker()
    }
    
    func showPicker(){
        if NSUserDefaults.standardUserDefaults().objectForKey(currentTimeSetting) != nil{
            var selectedDate : NSDate = NSUserDefaults.standardUserDefaults().objectForKey(currentTimeSetting) as! NSDate
            datePicker.date = selectedDate
        }
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.pickerHolder.frame = CGRectMake(0, self.view.bounds.size.height-(219+44), self.view.bounds.size.height, 219+44)
        })
    }
    
    func closePicker(){
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.pickerHolder.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.height, 219+44)
        })
        
        NSUserDefaults.standardUserDefaults().setObject(datePicker.date, forKey: currentTimeSetting);
        NSUserDefaults.standardUserDefaults().synchronize()
        
        settingsTable?.reloadData()
    }
    
    // MARK: - UITableView -
    
    func sectionTitles() -> [String] {
        return ["", "Settings"]
    }
    
    func section1RowTitles() -> [String] {
        return ["Open Harvest In Safari", "Sign Out"]
    }
    
    func section2RowTitles() -> [String] {
        return ["Auto Login", "Configure Beacons", self.arrivalTime(), self.lunchTime(), self.departureTime()]
    }
    
    func lunchTime() -> String{
        var lunchTime:String = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("lunchTime") != nil{
            var selectedDate : NSDate = NSUserDefaults.standardUserDefaults().objectForKey("lunchTime") as! NSDate
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "hh:mm a"
            let time:String = formatter.stringFromDate(selectedDate)
            
            lunchTime = "Lunch Time: " + time
        }else{
            lunchTime = "Lunch Time: Not Set"
        }
        return lunchTime
    }
    
    func arrivalTime() -> String{
        var arrivalTime:String = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("arrivalTime") != nil{
            var selectedDate : NSDate = NSUserDefaults.standardUserDefaults().objectForKey("arrivalTime") as! NSDate
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "hh:mm a"
            let time:String = formatter.stringFromDate(selectedDate)
            
            arrivalTime = "Arrival Time: " + time
        }else{
            arrivalTime = "Arrival Time: Not Set"
        }
        return arrivalTime
    }
    
    func departureTime() -> String{
        var departureTime:String = ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("departureTime") != nil{
            var selectedDate : NSDate = NSUserDefaults.standardUserDefaults().objectForKey("departureTime") as! NSDate
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "hh:mm a"
            let time:String = formatter.stringFromDate(selectedDate)
            
            departureTime = "Departure Time: " + time
        }else{
            departureTime = "Departure Time: Not Set"
        }
        return departureTime
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return self.sectionTitles()[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.section1RowTitles().count
        }
        return self.section2RowTitles().count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell_ : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell
        if(cell_ == nil){
            cell_ = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL_ID")
        }
        
        if indexPath.section == 0{
            cell_!.textLabel?.text = self.section1RowTitles()[indexPath.row]
            cell_!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }else{
            cell_!.textLabel?.text = self.section2RowTitles()[indexPath.row]
            if indexPath.row == 0{
                if Account.autoLogin(){
                    cell_!.accessoryType = UITableViewCellAccessoryType.Checkmark
                }else{
                    cell_!.accessoryType = UITableViewCellAccessoryType.None
                }
            }else if indexPath.row == 1{
                cell_!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }else{
                cell_!.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        return cell_!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0{
            if indexPath.row == 0{
                UIApplication.sharedApplication().openURL(NSURL(string:kHarvestLoginURL)!)
            }else if indexPath.row == 1{
                self.signOut()
            }
        }else{
            if indexPath.row == 0{
                Account.toggleAutoLogin()
                settingsTable?.reloadData()
            }else if indexPath.row == 1{
                self.performSegueWithIdentifier("beaconConfigSegue", sender: self)
            }else if indexPath.row == 2{
                self.changeArrivalTime()
            }else if indexPath.row == 3{
                self.changeLunchTime()
            }else if indexPath.row == 4{
                self.changeDepartureTime()
            }
        }
    }
}