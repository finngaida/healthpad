//
//  WeightView.swift
//  HealthPad
//
//  Created by Finn Gaida on 17.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit

public class WeightView: LineView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.color = .Yellow
        self.titleText = "Weight"
        self.averageText = "79 kg"
        self.todayText = "78.5 kg"
        self.dateText = "Today, 3:14 PM"
    }
    
    public override func majorValueFromHealthObject(obj:HealthObject) -> String {
        if let o = obj as? Weight {
            return "\(o.value)"
        } else {return ""}
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
