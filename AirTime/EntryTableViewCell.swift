//
//  EntryTableViewCell.swift
//  AirTime
//
//  Created by Chase Acton on 3/11/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {
    
    @IBOutlet var taskLabel: UILabel?
    @IBOutlet var projectLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    
    override func layoutSubviews(){
        self.timeLabel?.layer.cornerRadius = 6
        self.timeLabel?.layer.masksToBounds = true
    }
    
}