//
//  LineChartView.swift
//  HealthPad
//
//  Created by Finn Gaida on 16.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit
import Charts
import GradientView

public class LineView: UIView, ChartViewDelegate {
    
    public var chart: LineChartView?
    public var color: FGColor? {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        
    }
    
    public func reload() {
        
        chart = LineChartView(frame: CGRectMake(25, 85, self.frame.width - 40, self.frame.height - 110))
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
        self.addSubview(Helper.gradientForColor(CGRectMake(0, 0, self.frame.width, self.frame.height), color: self.color!))
        self.addSubview(chart!)
        
        let average = ChartLimitLine(limit: 12.0)
        average.lineColor = UIColor(white: 1.0, alpha: 0.5)
        average.lineWidth = 1
        average.lineDashLengths = [5.0]
        chart?.rightAxis.addLimitLine(average)
        
        let titleLabel = UILabel(frame: CGRectMake(20, 10, self.frame.width / 2 - 30, 30))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "HelveticaNeue", size: 25)
        titleLabel.text = self.titleText ?? "Steps"
        self.addSubview(titleLabel)
        
        let averageLabel = UILabel(frame: CGRectMake(20, 40, self.frame.width / 2 - 30, 20))
        averageLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        averageLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        averageLabel.text = self.averageText ?? "Daily average: 4,631"
        self.addSubview(averageLabel)
        
        let todayLabel = UILabel(frame: CGRectMake(self.frame.width / 2 + 10, 10, self.frame.width / 2 - 30, 30))
        todayLabel.textColor = UIColor.whiteColor()
        todayLabel.textAlignment = .Right
        todayLabel.font = UIFont(name: "HelveticaNeue", size: 25)
        todayLabel.text = self.todayText ?? "1,261 steps"
        self.addSubview(todayLabel)
        
        let dateLabel = UILabel(frame: CGRectMake(self.frame.width / 2 + 10, 40, self.frame.width / 2 - 30, 20))
        dateLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        dateLabel.textAlignment = .Right
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        dateLabel.text = self.dateText ?? "Today, 8:18"
        self.addSubview(dateLabel)
        
        let separator = UIView(frame: CGRectMake(20, 65, self.frame.width - 40, 1))
        separator.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        self.addSubview(separator)
        
    }
    
    public func setData(data:Array<HealthObject>) {
        let set = LineChartDataSet(yVals: data.enumerate().map({ChartDataEntry(value: Double(self.majorValueFromHealthObject($1)) ?? 0, xIndex: $0)}), label: "")
        set.lineWidth = 2
        set.circleRadius = 5
        set.setCircleColor(UIColor.whiteColor())
        set.circleHoleColor = UIColor.orangeColor()
        set.drawCircleHoleEnabled = true
        set.setColor(UIColor.whiteColor())
        set.drawValuesEnabled = false
        set.highlightEnabled = false
        set.drawCubicEnabled = false
        set.drawFilledEnabled = true
        set.drawCirclesEnabled = true
        set.fillAlpha = 1.0
        set.fill = ChartFill(linearGradient: CGGradientCreateWithColors(nil, [UIColor(white: 1.0, alpha: 0.0).CGColor, UIColor(white: 1.0, alpha: 0.4).CGColor], nil)!, angle: 90.0)
        
        var xVals = (1...data.count).map({"\($0)"})
        xVals[0] = "Mar \(xVals[0])"   // TODO Real month
        chart?.data = LineChartData(xVals: xVals, dataSet: set)
    }
    
    public func majorValueFromHealthObject(obj:HealthObject) -> String {
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
        fatalError("init(coder:) has not been implemented")
    }
    
}
