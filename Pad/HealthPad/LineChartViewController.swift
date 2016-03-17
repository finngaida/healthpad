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
    
    public var stepsView:StepsView?
    public var sleepView:SleepView?
    public var weightView:WeightView?
    public var data:[HealthObject]?
    
    public override func viewDidLoad() {
        
        stepsView = StepsView(frame: CGRectMake(0, 100, 500, 280))
        self.view.addSubview(stepsView!)
        
        sleepView = SleepView(frame: CGRectMake(50, 400, 500, 280))
        self.view.addSubview(sleepView!)
        
        weightView = WeightView(frame: CGRectMake(50, 700, 500, 280))
        self.view.addSubview(weightView!)
        
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
