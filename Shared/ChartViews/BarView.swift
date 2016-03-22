//
//  LineChartView.swift
//  HealthPad
//
//  Created by Finn Gaida on 16.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit
import Charts

public class BarView: ChartView {
    
    public var chart: BarChartView?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override func setupChart() {
        chart = BarChartView(frame: CGRectMake(25, 85, self.frame.width - 40, self.frame.height - 110))
        chart?.delegate = self
        chart?.setScaleEnabled(false)
        chart?.dragEnabled = false
        chart?.pinchZoomEnabled = false
        chart?.drawGridBackgroundEnabled = false
        chart?.leftAxis.enabled = false
        chart?.rightAxis.enabled = true
        chart?.legend.enabled = false
        chart?.descriptionText = ""
        chart?.rightAxis.gridColor = UIColor.whiteColor()
        chart?.rightAxis.showOnlyMinMaxEnabled = true
        chart?.xAxis.enabled = true
        
        chart?.backgroundColor = UIColor.clearColor()
        chart?.layer.masksToBounds
        chart?.layer.cornerRadius = 10
        self.addSubview(Helper.gradientForColor(CGRectMake(0, 0, self.frame.width, self.frame.height), color: self.color))
        self.addSubview(chart!)
        
        let average = ChartLimitLine(limit: 12.0)
        average.lineColor = UIColor(white: 1.0, alpha: 0.5)
        average.lineWidth = 1
        average.lineDashLengths = [5.0]
        chart?.rightAxis.addLimitLine(average)
    }
    
    public override func setupLabels() {
        super.setupLabels()
        titleLabel?.text = self.titleText ?? "Sleep Analysis"
        todayLabel?.text = self.todayText ?? "Daily average: 7h 33m"
        averageLabel?.text = self.averageText ?? "7h 22m"
        dateLabel?.text = self.dateText ?? "Yesterday, 6:24 AM"
    }
    
    public override func setData(data:Array<HealthObject>) {
        let set = BarChartDataSet(yVals: data.enumerate().map({BarChartDataEntry(value: Double(self.majorValueFromHealthObject($1)) ?? 0, xIndex: $0)}), label: "")
        set.drawValuesEnabled = false
        set.highlightEnabled = false
        set.colors = [UIColor(white: 1.0, alpha: 0.5)]
        
        var xVals = (1...data.count).map({"\($0)"})
        xVals[0] = "Mar \(xVals[0])"   // TODO Real month
        chart?.data = BarChartData(xVals: xVals, dataSet: set)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
