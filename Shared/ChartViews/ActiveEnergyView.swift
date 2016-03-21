//
//  ActiveEnergyView.swift
//  HealthPad
//
//  Created by Finn Gaida on 20.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit

public class ActiveEnergyView: LineView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.color = .Orange
        self.titleText = "Active Energy"
        self.averageText = "Daily Average: 343.21"
        self.todayText = "763.06 kcal"
        self.dateText = "Today, 4:40 PM"
    }
    
    public override func majorValueFromHealthObject(obj:HealthObject) -> String {
        if let o = obj as? Energy {
            return "\(o.value)"
        } else {return ""}
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
