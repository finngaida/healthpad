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
    public var bloodPressureView:BloodPressureView?
    public var heartRateView:HeartRateView?
    public var data:[HealthObject]?
    
    public override func viewDidLoad() {
        
        heartRateView = HeartRateView(frame: CGRectMake(100, 100, 500, 280))
        self.view.addSubview(heartRateView!)
        
        bloodPressureView = BloodPressureView(frame: CGRectMake(100, 400, 500, 280))
        self.view.addSubview(bloodPressureView!)
        
        sleepView = SleepView(frame: CGRectMake(100, 700, 500, 280))
        self.view.addSubview(sleepView!)
        
        stepsView = StepsView(frame: CGRectMake(100, 1000, 500, 280))
        self.view.addSubview(stepsView!)
        
        weightView = WeightView(frame: CGRectMake(100, 1300, 500, 280))
        self.view.addSubview(weightView!)
        
        setupData()
    }
    
    public func setupData() {
        
        heartRateView?.setData([HeartRate(highestbpm:120, lowestbpm:43, all:[HeartRateValue(date:nil, bpm:120), HeartRateValue(date:nil, bpm:43)], description:"", unit:Unit.bpm, date:nil),
            HeartRate(highestbpm:110, lowestbpm:55, all:[HeartRateValue(date:nil, bpm:110), HeartRateValue(date:nil, bpm:55)], description:"", unit:Unit.bpm, date:nil),
            HeartRate(highestbpm:125, lowestbpm:50, all:[HeartRateValue(date:nil, bpm:125), HeartRateValue(date:nil, bpm:50)], description:"", unit:Unit.bpm, date:nil),
            HeartRate(highestbpm:115, lowestbpm:45, all:[HeartRateValue(date:nil, bpm:115), HeartRateValue(date:nil, bpm:45)], description:"", unit:Unit.bpm, date:nil),
            HeartRate(highestbpm:100, lowestbpm:48, all:[HeartRateValue(date:nil, bpm:100), HeartRateValue(date:nil, bpm:48)], description:"", unit:Unit.bpm, date:nil)])
        
        bloodPressureView?.setData([BloodPressure(highest:120, lowest:43, all:[BloodPressureValue(systolic:133, diastolic:80), BloodPressureValue(systolic:133, diastolic:78)], description:"", unit:Unit.mmHg, date:nil),
            BloodPressure(highest:110, lowest:55, all:[BloodPressureValue(systolic:143, diastolic:76), BloodPressureValue(systolic:134, diastolic:55)], description:"", unit:Unit.mmHg, date:nil),
            BloodPressure(highest:125, lowest:50, all:[BloodPressureValue(systolic:122, diastolic:87), BloodPressureValue(systolic:145, diastolic:50)], description:"", unit:Unit.mmHg, date:nil),
            BloodPressure(highest:115, lowest:45, all:[BloodPressureValue(systolic:136, diastolic:76), BloodPressureValue(systolic:134, diastolic:45)], description:"", unit:Unit.mmHg, date:nil),
            BloodPressure(highest:100, lowest:48, all:[BloodPressureValue(systolic:125, diastolic:79), BloodPressureValue(systolic:144, diastolic:48)], description:"", unit:Unit.mmHg, date:nil)])
        
        sleepView?.setData([Sleep(hours:6, description:"", unit:Unit.hours, date:nil),
            Sleep(hours:7, description:"", unit:Unit.hours, date:nil),
            Sleep(hours:8, description:"", unit:Unit.hours, date:nil),
            Sleep(hours:7, description:"", unit:Unit.hours, date:nil),
            Sleep(hours:8, description:"", unit:Unit.hours, date:nil),
            Sleep(hours:6, description:"", unit:Unit.hours, date:nil),
            Sleep(hours:6, description:"", unit:Unit.hours, date:nil)])
        
        stepsView?.setData([Steps(count:6123, description:"", unit:Unit.steps, date:nil),
            Steps(count:8127, description:"", unit:Unit.steps, date:nil),
            Steps(count:3287, description:"", unit:Unit.steps, date:nil),
            Steps(count:2983, description:"", unit:Unit.steps, date:nil),
            Steps(count:9283, description:"", unit:Unit.steps, date:nil),
            Steps(count:2837, description:"", unit:Unit.steps, date:nil),
            Steps(count:7239, description:"", unit:Unit.steps, date:nil)])
        
        weightView?.setData([Weight(value:79.5, description:"", unit:Unit.kg, date:nil),
            Weight(value:80.0, description:"", unit:Unit.kg, date:nil),
            Weight(value:79.0, description:"", unit:Unit.kg, date:nil),
            Weight(value:78.5, description:"", unit:Unit.kg, date:nil),
            Weight(value:80.5, description:"", unit:Unit.kg, date:nil),
            Weight(value:80.0, description:"", unit:Unit.kg, date:nil),
            Weight(value:79.5, description:"", unit:Unit.kg, date:nil),
            Weight(value:79.0, description:"", unit:Unit.kg, date:nil)])
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
