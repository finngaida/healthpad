//
//  LineChartViewController.swift
//  HealthPad
//
//  Created by Finn Gaida on 16.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit
import Charts
import GradientView

public class LineChartViewController: UIViewController, ChartViewDelegate {
    
    public var stepsView:HeartRateView?
    public var sleepView:SleepView?
    public var weightView:BloodPressureView?
    public var data:[HealthObject]?
    
    public override func viewDidLoad() {
        
        stepsView = HeartRateView(frame: CGRectMake(100, 100, 500, 280))
        self.view.addSubview(stepsView!)
        
        weightView = BloodPressureView(frame: CGRectMake(100, 400, 500, 280))
        self.view.addSubview(weightView!)
        
        sleepView = SleepView(frame: CGRectMake(100, 700, 500, 280))
        self.view.addSubview(sleepView!)
        
        setupData()
    }
    
    public func setupData() {
        
        guard let data = data else {return}
        stepsView!.setData(data)
        sleepView!.setData(data)
        weightView!.setData(data)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
