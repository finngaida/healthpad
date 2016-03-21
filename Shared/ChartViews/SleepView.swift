//
//  SleepView.swift
//  HealthPad
//
//  Created by Finn Gaida on 17.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit

public class SleepView: BarView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.color = .Purple
        self.titleText = "Sleep Analysis"
        self.averageText = "6h 53m"
        self.todayText = "8h 56m"
        self.dateText = "Yesterday, 3:14 AM"
    }
    
    public override func majorValueFromHealthObject(obj:HealthObject) -> String {
        if let o = obj as? Sleep {
            return "\(o.hours)"
        } else {return ""}
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
