//
//  StepsView.swift
//  HealthPad
//
//  Created by Finn Gaida on 17.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit

public class StepsView: LineView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.color = .Orange
        self.titleText = "Steps"
        self.averageText = "6238 steps"
        self.todayText = "9237 steps"
        self.dateText = "Today, 3:14 PM"
    }
    
    public override func majorValueFromHealthObject(obj:HealthObject) -> String {
        if let o = obj as? Steps {
            return "\(o.count)"
        } else {return ""}
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
