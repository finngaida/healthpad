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

public class DetailViewController: UIViewController {
    
    var data:Dictionary<String,Array<HealthObject>>?
    
    public override func viewDidLoad() {
        
    }
    
    @IBAction func syncData(sender: AnyObject) {
        
        let loader = Loader.showLoader(self)
        loader.label?.text = "Loading..."
        
        Helper.sharedHelper.fetchData(loader) { (data) -> () in
            self.data = data
            print(data)
            Loader.hideLoader(self)
            ((self.splitViewController?.viewControllers[0] as! UINavigationController).viewControllers[0] as! MasterViewController).tableView.reloadData()
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.destinationViewController)
        if segue.identifier == Helper.sharedHelper.showLineChartSegue, let dest = segue.destinationViewController as? LineChartViewController {
            
            if let type = sender as? String {
                
            }
        }
    }
}
