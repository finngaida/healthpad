//
//  SplitViewController.swift
//  HealthPad
//
//  Created by Finn Gaida on 16.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit

public class SplitViewController: UISplitViewController {

    var master:MasterViewController?
    var detail:DetailViewController?
    
    public override func viewDidLoad() {
        
        master = (self.viewControllers[0] as! UINavigationController).viewControllers[0] as? MasterViewController
        detail = (self.viewControllers[1] as! UINavigationController).viewControllers[0] as? DetailViewController
        
        NSNotificationCenter.defaultCenter().addObserverForName(Helper.sharedHelper.typeSelectedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            if let d = self.detail {
                d.performSegueWithIdentifier(Helper.sharedHelper.showLineChartSegue, sender: notification.object)
            }
        }
        
    }
    
}
