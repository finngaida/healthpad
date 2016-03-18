//
//  HeartRateView.swift
//  HealthPad
//
//  Created by Finn Gaida on 18.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit

public class HeartRateView: CandleView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.color = .Gray
        self.titleText = "Heart Rate"
        self.averageText = "Min: 51 Max: 154"
        self.todayText = "69 bpm"
        self.dateText = "Today, 3:15 PM"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
