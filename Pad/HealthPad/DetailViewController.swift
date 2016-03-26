//
//  DetailViewController.swift
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
import CloudKit

public class DetailViewController: UIViewController {
    
    var data:Dictionary<String,Array<Day>>?
    
    public override func viewDidLoad() {
        
        // Arrange
        let helper = Helper.sharedHelper
        let cal = NSCalendar.currentCalendar()
        let components = cal.components([.Day], fromDate: NSDate())
        
        let date1 = cal.dateFromComponents(components)
        components.day += 1
        let date2 = cal.dateFromComponents(components)
        
        let record1Day1 = CKRecord(recordType: "Test")
        let record2Day1 = CKRecord(recordType: "Test")
        let record1Day2 = CKRecord(recordType: "Test")
        let record2Day2 = CKRecord(recordType: "Test")
        
        record1Day1["endDate"] = date1
        record2Day1["endDate"] = date1
        record1Day2["endDate"] = date2
        record2Day2["endDate"] = date2
        
        record1Day1["content"] = "10.0"
        record2Day1["content"] = "20.0"
        record1Day2["content"] = "10.0"
        record2Day2["content"] = "20.0"
        
        let records = [record1Day1, record2Day1, record1Day2, record2Day2]
        
        // Act
        if let days = helper.daysFromRecords(records, recordType: "Test") {
            
            print("days: \(days), count: \(days.count), max: \(days[0].maximumValue), min: \(days[0].minimumValue), all: \(days[0].all)")
            
        }

        
    }
    
    @IBAction func syncData(sender: AnyObject) {
        
        let loader = Loader.showLoader(self)
        loader.label?.text = "Loading..."
        
        Helper.sharedHelper.fetchData(loader) { (data) -> () in
            self.data = data
            Loader.hideLoader(self)
            ((self.splitViewController?.viewControllers[0] as! UINavigationController).viewControllers[0] as! MasterViewController).tableView.reloadData()
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.destinationViewController)
        if segue.identifier == Helper.sharedHelper.showLineChartSegue, let _ = segue.destinationViewController as? LineChartViewController {
            
            if let _ = sender as? String {
                
            }
        }
    }
}
