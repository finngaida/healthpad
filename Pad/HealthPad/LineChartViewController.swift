//
//  LineChartViewController.swift
//  HealthPad
//
//  Created by Finn Gaida on 16.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit
import Charts

public class LineChartViewController: UIViewController {
    
    var scrollView:UIScrollView!
    public var stepsView:StepsView?
    public var sleepView:SleepView?
    public var weightView:WeightView?
    public var bloodPressureView:BloodPressureView?
    public var heartRateView:HeartRateView?
    public var energyView:ActiveEnergyView?
    public var data:[HealthObject]?
    
    public override func viewDidLoad() {
        
        scrollView = UIScrollView(frame: self.view.frame)
        self.view.addSubview(scrollView)
        
        let width = self.view.frame.width * 0.6
        let height = width * 0.56
        
        heartRateView = HeartRateView(frame: CGRectMake(50, (height + 20) * 0 + 20, width, height))
        scrollView.addSubview(heartRateView!)
        
        bloodPressureView = BloodPressureView(frame: CGRectMake(50, (height + 20) * 1 + 20, width, height))
        scrollView.addSubview(bloodPressureView!)
        
        sleepView = SleepView(frame: CGRectMake(50, (height + 20) * 2 + 20, width, height))
        scrollView.addSubview(sleepView!)
        
        stepsView = StepsView(frame: CGRectMake(50, (height + 20) * 3 + 20, width, height))
        scrollView.addSubview(stepsView!)
        
        energyView = ActiveEnergyView(frame: CGRectMake(50, (height + 20) * 4 + 20, width, height))
        scrollView.addSubview(energyView!)
        
        weightView = WeightView(frame: CGRectMake(50, (height + 20) * 5 + 5, width, height))
        scrollView.addSubview(weightView!)
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, (weightView?.frame.origin.y)! + (weightView?.frame.height)! + 50)
        
        setupData()
    }
    
    public func setupData() {
        
        heartRateView?.setData([[120, 43], [130, 50], [125, 55], [120, 55], [125, 45], [130, 40]].map({HeartRate(highestbpm:$0[0], lowestbpm:$0[1], all:[HeartRateValue(date:nil, bpm:$0[0]), HeartRateValue(date:nil, bpm:$0[1])], description:"", unit:Unit.bpm, date:nil)}))
        
        bloodPressureView?.setData([[120,80], [130,90], [140,90], [135,85], [125,80], [130,95]].map({BloodPressure(highest:$0[0], lowest:$0[1], all:[BloodPressureValue(systolic:$0[0], diastolic:$0[1])], description:"", unit:Unit.mmHg, date:nil)}))
        
        sleepView?.setData([6, 7, 8, 7, 8, 8, 6, 6].map({Sleep(hours:$0, description:"", unit:Unit.hours, date:nil)}))
        
        stepsView?.setData([6234, 7234, 8234, 7543, 8724, 8234, 6234, 6734].map({Steps(count:$0, description:"", unit:Unit.steps, date:nil)}))
        
        weightView?.setData([79.5, 79.0, 80.0, 79.0, 81.0, 80.5, 79.0, 70.5].map({Weight(value:$0, description:"", unit:Unit.kg, date:nil)}))
        
        if let data = Helper.sharedHelper.latestData {
            
            if let energies = data["ActiveEnergyBurned"] {
                print("Energy: \(energies)")
                energyView?.setData(energies.map({Energy(value:Double("\(($0 as! GeneralHealthObject).value)") ?? 0, description:"\($0)", unit:Unit.kcal, date:nil)}))
                
            }
            
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
