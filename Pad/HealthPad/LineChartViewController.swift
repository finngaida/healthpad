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
    
    public var lineView:LineView?
    public var data:[HealthObject]?
    
    public override func viewDidLoad() {
        
        lineView = LineView(frame: CGRectMake(50, 100, 500, 280))
        self.view.addSubview(lineView!)
        
        let barView = BarView(frame: CGRectMake(50, 400, 500, 280))
        self.view.addSubview(barView)
        
        setupData()
    }
    
    public func setupData() {
        
        guard let data = data else {return}
        lineView!.setData(data)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
