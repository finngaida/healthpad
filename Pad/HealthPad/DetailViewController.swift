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
        
        Helper.sharedHelper.fetchData { (data) -> () in
            self.data = data
            Loader.hideLoader(self)
        }
    }
}
