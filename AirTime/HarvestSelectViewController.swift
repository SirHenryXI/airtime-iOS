//
//  HarvestSelectViewController.swift
//  AirTime
//
//  Created by Chase Acton on 1/21/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

import UIKit

class HarvestSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var harvest = HarvestManager.sharedInstance() as! HarvestManager
    
    @IBOutlet weak var topBar: UIToolbar?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var harvestTable: UITableView?
    
    var projects : Bool = false
    var tasks : Bool = false
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topBar?.clipsToBounds = true
        
        if projects{
            titleLabel?.text = "Select Project"
        }
        if tasks{
            titleLabel?.text = "Select Task"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func close(){
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
    
    // MARK: - UITableView -
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if projects{
            return harvest.currentProjects.count
        }else if tasks{
            return harvest.currentTasks.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell_ : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CELL_ID") as? UITableViewCell
        if(cell_ == nil){
            cell_ = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL_ID")
        }
        
        if projects{
            var project = harvest.currentProjects[indexPath.row] as! Project
            cell_!.textLabel?.text = project.client.stringByReplacingOccurrencesOfString("&amp;", withString: "&") + " - " + project.name.stringByReplacingOccurrencesOfString("&amp;", withString: "&")
            
            if project.projectID == harvest.currentProject.projectID{
                cell_!.accessoryType = UITableViewCellAccessoryType.Checkmark
            }else{
                cell_!.accessoryType = UITableViewCellAccessoryType.None
            }
        }else if tasks{
            var task = harvest.currentTasks[indexPath.row] as! Task
            cell_!.textLabel?.text = task.name.stringByReplacingOccurrencesOfString("&amp;", withString: "&")
            
            if task.taskID == harvest.currentTask.taskID{
                cell_!.accessoryType = UITableViewCellAccessoryType.Checkmark
            }else{
                cell_!.accessoryType = UITableViewCellAccessoryType.None
            }
            
        }
        return cell_!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.projects{
            var project = harvest.currentProjects[indexPath.row] as! Project
            harvest.saveProject(project)
        }else if (self.tasks){
            var task = harvest.currentTasks[indexPath.row] as! Task
            harvest.saveTask(task)
        }
        harvestTable?.reloadData()
        self.close()
    }
    
}