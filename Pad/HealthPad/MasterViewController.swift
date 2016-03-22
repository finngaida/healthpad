//
//  MasterViewController.swift
//  HealthPad
//
//  Created by Finn Gaida on 16.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import Foundation
import UIKit
import ActionKit
import Async
import Charts

public class MasterViewController: UITableViewController {
    
    override public func viewDidLoad() {
        
    }
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = Helper.sharedHelper.latestData else {return 1}
        return data.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        if indexPath.row == 0 && self.tableView(tableView, numberOfRowsInSection: 0) == 1 {
            cell.textLabel?.text = "Test Line Chart"
        } else {
            cell.textLabel?.text = ""
        }
        
        guard let data = Helper.sharedHelper.latestData else {return cell}
        cell.textLabel?.text = Array(data.keys)[indexPath.row]
        return cell
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let data = Helper.sharedHelper.latestData {
            NSNotificationCenter.defaultCenter().postNotificationName(Helper.sharedHelper.typeSelectedNotification, object: Array(data.keys)[indexPath.row])
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(Helper.sharedHelper.typeSelectedNotification, object: nil)
        }
    }
    
}
