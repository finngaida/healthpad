//
//  BloodPressureView.swift
//  HealthPad
//
//  Created by Finn Gaida on 18.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit

public class BloodPressureView: CandleView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.color = .Gray
        self.titleText = "Blood Pressure"
        self.averageText = "v 133-156 / ^ 67-82 mmHg"
        self.todayText = "133/72"
        self.dateText = "Today, 3:15 PM"
        self.shadowVisible = false
        self.scatterShape = .Custom
    }
    
    public override func majorValueFromHealthObject(obj:HealthObject) -> String {
        if let o = obj as? BloodPressure {
            return "\(o.highest)"
        } else {return ""}
    }
    
    public override func minorValueFromHealthObject(obj:HealthObject) -> String {
        if let o = obj as? BloodPressure {
            return "\(o.lowest)"
        } else {return ""}
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}