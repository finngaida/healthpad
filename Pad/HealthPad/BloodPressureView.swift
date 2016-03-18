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
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}