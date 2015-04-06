//
//  TodayViewController.swift
//  AirTime Widget
//
//  Created by Chase Acton on 3/13/15.
//  Copyright (c) 2015 Chase Acton. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet var timerLabel:UILabel?
    @IBOutlet var titleLabel:UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSizeMake(0, 150)
        
        //Default label text
        let labelText:String = "0:00:00"
        var length = count(labelText)
        var myMutableString = NSMutableAttributedString (string: labelText, attributes: nil)
        myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 46.0)!, range: NSRange(location:0,length:length-3))
        myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 30.0)!, range: NSRange(location:length-3,length:3))
        timerLabel?.attributedText = myMutableString
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets
        (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
            return UIEdgeInsetsZero
    }
    
    @IBAction func pause(){
        
    }
    
    @IBAction func newTimer(){
        let url = NSURL(string: "airtime://")
        self.extensionContext?.openURL(url!, completionHandler: nil)
    }
    
}