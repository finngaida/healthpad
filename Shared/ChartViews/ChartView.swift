//
//  LineChartView.swift
//  HealthPad
//
//  Created by Finn Gaida on 20.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit
import Charts

public class ChartView: UIView, ChartViewDelegate {
    
    public var data:Array<HealthObject>? {
        didSet {
            self.reload()
        }
    }
    
    public var color: FGColor = .Gray {
        didSet {
            self.reload()
        }
    }
    
    public var titleText: String? {
        didSet {
            self.reload()
        }
    }
    
    public var averageText: String? {
        didSet {
            self.reload()
        }
    }
    
    public var todayText: String? {
        didSet {
            self.reload()
        }
    }
    
    public var dateText: String? {
        didSet {
            self.reload()
        }
    }
    
    public var titleLabel: UILabel?
    public var averageLabel: UILabel?
    public var todayLabel: UILabel?
    public var dateLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        
    }
    
    public func reload() {
        
        self.setupChart()
        self.setupLabels()
        
        let separator = UIView(frame: CGRectMake(20, 65, self.frame.width - 40, 1))
        separator.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        self.addSubview(separator)
        
    }
    
    public func setupChart() {
        // handled by subclass
    }
    
    public func setupLabels() {
        
        // upper labels
        titleLabel = UILabel(frame: CGRectMake(20, 10, self.frame.width / 2 - 30, 30))
        todayLabel = UILabel(frame: CGRectMake(self.frame.width / 2 + 10, 10, self.frame.width / 2 - 30, 30))
        todayLabel?.textAlignment = .Right
        
        [titleLabel, todayLabel].forEach({
            $0?.textColor = UIColor.whiteColor()
            $0?.font = UIFont(name: "HelveticaNeue", size: 25)
            self.addSubview($0!)
        })
        
        // lower labels
        averageLabel = UILabel(frame: CGRectMake(20, 40, self.frame.width / 2 - 30, 20))
        dateLabel = UILabel(frame: CGRectMake(self.frame.width / 2 + 10, 40, self.frame.width / 2 - 30, 20))
        dateLabel?.textAlignment = .Right
        
        [averageLabel, dateLabel].forEach({
            $0?.textColor = UIColor(white: 1.0, alpha: 0.6)
            $0?.font = UIFont(name: "HelveticaNeue", size: 15)
            self.addSubview($0!)
        })
        
    }
    
    public func setData(data:Array<HealthObject>) {
        
    }
    
    public func majorValueFromHealthObject(obj:HealthObject) -> String {
        return ""
    }
    
    public func minorValueFromHealthObject(obj:HealthObject) -> String {
        return ""
    }
    
    // MARK: Chart delegate
    public func chartValueNothingSelected(chartView: ChartViewBase) {
        
    }
    
    public func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
    
    public func chartScaled(chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    public func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
