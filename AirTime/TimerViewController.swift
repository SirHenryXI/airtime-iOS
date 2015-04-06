//
//  TimerViewController.swift
//  AirTime
//
//  Created by Chase Acton on 1/22/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var harvest = HarvestManager.sharedInstance() as! HarvestManager
    var beaconManager = iBeaconManager.sharedInstance() as! iBeaconManager
    var stopwatch = CAStopwatch.sharedInstance() as! CAStopwatch
    var refreshControl : UIRefreshControl = UIRefreshControl()
    
    @IBOutlet weak var topBar: UIToolbar?
    @IBOutlet weak var locationsLabel: UILabel?
    @IBOutlet weak var timerLabel: UILabel?
    @IBOutlet weak var profileImage: UIImageView?
    @IBOutlet weak var beaconsTable: UITableView?
    @IBOutlet weak var harvestTable: UITableView?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func checkBluetooth(){
        if beaconManager.bluetoothOn(){
            locationsLabel?.text = beaconManager.locationsNearby()
            locationsLabel?.backgroundColor = UIColor(red: 255.0/255.0, green: 199.0/255.0, blue: 21.0/255.0, alpha: 1.0)
        }else{
            locationsLabel?.text = "Bluetooth Off"
            locationsLabel?.backgroundColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        harvestTable?.reloadData()
        
        //Default label text
        let labelText:String = "0:00:00"
        var length = count(labelText)
        var myMutableString = NSMutableAttributedString (string: labelText, attributes: nil)
        myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-UltraLight", size: 90.0)!, range: NSRange(location:0,length:length-3))
        myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-UltraLight", size: 50.0)!, range: NSRange(location:length-3,length:3))
        timerLabel?.attributedText = myMutableString
    }
    
    func setupUI(){
        topBar?.clipsToBounds = true
        
        var currentUser : User = harvest.currentUser
        let imageURL = NSURL(string: currentUser.avatar_url)
        profileImage?.sd_setImageWithURL(imageURL)
        
        if let profile = profileImage {
            var loadView = UIView(frame: CGRectMake(0, 0, profile.frame.size.width, profile.frame.size.height))
            profileImage?.layer.cornerRadius = loadView.frame.size.width/2
        }
        
        //Add pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        refreshControl.addTarget(self, action: "refreshHarvest", forControlEvents: UIControlEvents.ValueChanged)
        harvestTable?.addSubview(refreshControl)
        
        profileImage?.layer.masksToBounds = true
        profileImage?.layer.borderColor = UIColor.whiteColor().CGColor
        profileImage?.layer.borderWidth = 2.0
        
        locationsLabel?.text = CARandomGreeting.greeting() + ", " + harvest.currentUser.first_name + " " + harvest.currentUser.last_name
        
        delay(4.0, closure: { () -> () in
            self.checkBluetooth()
        })
    }
    
    @IBAction func toggleTable(){
        if let hidden:Bool  = beaconsTable?.hidden { // This is ok
            beaconsTable?.hidden = !hidden
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        harvestTable?.reloadData()
        self.updateTime()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTable", name: "beaconsFound", object: nil)
    }
    
    @IBAction func addTime(){
        CAAlert.alertWithTitle("Add Time", message: "This feature is not done yet")
    }
    
    func refreshTable(){
        beaconsTable?.reloadData()
        self.checkBluetooth()
    }
    
    func updateTime(){
        if stopwatch.isRunning(){
            var elapsed:NSTimeInterval = stopwatch.runningTime()//2 hours 2:00:00 7200 seconds
            
            var elapsedTime:Int = Int(elapsed)
            
            var hours:Int = Int(elapsedTime/60/60)
            elapsedTime -= (hours * 60 * 60)
            
            var minutes:Int = Int(elapsedTime/60)
            elapsedTime -= (minutes * 60)
            
            var seconds:Int = Int(elapsedTime)
            
            let labelText:String = String(format: "%u:%02u:%02u", hours,minutes,seconds)
            var length = count(labelText)
            var myMutableString = NSMutableAttributedString (string: labelText, attributes: nil)
            myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-UltraLight", size: 90.0)!, range: NSRange(location:0,length:length-3))
            myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-UltraLight", size: 50.0)!, range: NSRange(location:length-3,length:3))
            
            timerLabel?.attributedText = myMutableString
            
            delay(0.1, closure: { () -> () in
                self.updateTime()
            })
        }else{
            timerLabel?.text = "0:00:00"
        }
    }
    
    @IBAction func openProfile(){
        self.performSegueWithIdentifier("profileSegue", sender: self)
    }
    
    @IBAction func timerPressed(){
        self.toggleTimer()
    }
    
    func refreshHarvest(){
        SVProgressHUD.showWithStatus("Loading Harvest Data", maskType: SVProgressHUDMaskType.Gradient)
        self.refreshControl.endRefreshing()
        
        harvest.batch { (success) -> Void in
            SVProgressHUD.dismiss()
            if success{
                self.harvestTable?.reloadData()
            }else{
                CAAlert.requestFailedAlert()
            }
        }
    }
    
    func toggleTimer(){
        if stopwatch.isRunning(){
            stopwatch.reset()
            self.updateTime()
            
            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
            harvest.addTimer(harvest.runningTimer, completion: { (success) -> Void in
                SVProgressHUD.dismiss()
                if success{
                    self.refreshHarvest()
                    self.harvest.runningTimer = nil
                }else{
                    CAAlert.requestFailedAlert()
                }
            })
        }else{
            var timer : Timer = Timer()
            timer.projectID = harvest.currentProject.projectID
            timer.projectName = harvest.currentProject.name
            timer.taskID = harvest.currentTask.taskID
            timer.taskName = harvest.currentTask.name
            timer.date = NSDate()
            harvest.runningTimer = timer
            
            stopwatch.startPause()
            self.updateTime()
            harvestTable?.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "projectsSegue" {
            let vc : HarvestSelectViewController = segue.destinationViewController as! HarvestSelectViewController
            vc.projects = true
        }else  if segue.identifier == "tasksSegue" {
            let vc : HarvestSelectViewController = segue.destinationViewController as! HarvestSelectViewController
            vc.tasks = true
        }
    }
    
    // MARK: - UITableView -
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == harvestTable{
            if section == 0{
                return 2
            }else if section == 1{
                return harvest.currentEntries.count
            }
        }else if tableView == beaconsTable{
            if let count = beaconManager.beaconsFound{
                return beaconManager.beaconsFound.count
            }else{
                return 0
            }
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        if tableView == harvestTable{
            return 2
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        if tableView == beaconsTable{
            var cell = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell
            if(cell == nil){
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL_ID")
            }
            
            if let beacon = beaconManager.beaconsFound[indexPath.row] as? CLBeacon{
                var proximityLabel : String = ""
                switch beacon.proximity{
                case CLProximity.Far:
                    proximityLabel = "Far"
                    break
                case CLProximity.Near:
                    proximityLabel = "Near"
                    break
                case CLProximity.Immediate:
                    proximityLabel = "Immediate"
                    break
                case CLProximity.Unknown:
                    proximityLabel = "Unknown"
                    break
                }
                
                if let majorName = CABeaconIdentifier.majorNameForBeacon(beacon){
                                cell!.textLabel?.text = CABeaconIdentifier.majorNameForBeacon(beacon) + " - " + CABeaconIdentifier.minorNameForBeacon(beacon)

                }else{
                    cell!.textLabel?.text = "Unknown Beacon"

                }
                //            cell!.textLabel?.text = CABeaconIdentifier.majorNameForBeacon(beacon) + " - " + CABeaconIdentifier.minorNameForBeacon(beacon)
                //            }
                var proximity = "Proximity: " + proximityLabel
                var rssi:String = "RSSI: " + String(beacon.rssi)
                var uuid = "UUID: " + beacon.proximityUUID.UUIDString
                
                cell!.detailTextLabel?.text = proximity + ", " + rssi + ", " + uuid
            }
            return cell!
            
        }else if tableView == harvestTable{
            if indexPath.section == 0{
                var cell = tableView.dequeueReusableCellWithIdentifier("SelectCell", forIndexPath: indexPath) as? SelectTableViewCell
                if cell == nil {
                    cell = SelectTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "SelectCell")
                }
                
                cell!.textLabel?.minimumScaleFactor = 0.9
                cell!.textLabel?.adjustsFontSizeToFitWidth = true
                if indexPath.row == 0{
                    var project : Project = harvest.currentProject
                    cell!.keyLabel?.text = "Project"
                    cell!.valueLabel?.text = project.name
                }else if indexPath.row == 1{
                    var task : Task = harvest.currentTask
                    cell!.keyLabel?.text = "Task"
                    cell!.valueLabel?.text = task.name
                }
                return cell!
            }else if indexPath.section == 1{
                var cell = tableView.dequeueReusableCellWithIdentifier("EntryCell", forIndexPath: indexPath) as? EntryTableViewCell
                if cell == nil {
                    cell = EntryTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "EntryCell")
                }
                
                var entry : Entry = harvest.currentEntries[indexPath.row] as! Entry
                
                cell?.projectLabel?.text = entry.project
                cell?.taskLabel?.text = entry.task
                cell?.timeLabel?.text = CATimeConverter.formatTime(entry.hours)
                
                return cell!
            }
            
        }
        return cell!
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if tableView == harvestTable{
            if indexPath.section == 0{
                return 56
            }
            if indexPath.section == 1{
                return 80
            }
        }
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == harvestTable{
            if indexPath.section == 0{
                if indexPath.row == 0{
                    self.performSegueWithIdentifier("projectsSegue", sender: self)
                }else if indexPath.row == 1{
                    self.performSegueWithIdentifier("tasksSegue", sender: self)
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver("beaconsFound")
    }
    
}