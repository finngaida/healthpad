//
//  LineChartView.swift
//  HealthPad
//
//  Created by Finn Gaida on 16.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit
import Charts
import ResearchKit

public class LineView: ChartView, ORKGraphChartViewDelegate, ORKGraphChartViewDataSource {
    
    public var chart: LineChartView?
    public var testChart: ORKLineGraphChartView?
    private var testChartPoints:[ORKRangedPoint]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override func setupChart() {
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
        self.addSubview(Helper.gradientForColor(CGRectMake(0, 0, self.frame.width, self.frame.height), color: self.color))
        self.addSubview(chart!)
        
        let average = ChartLimitLine(limit: 12.0)
        average.lineColor = UIColor(white: 1.0, alpha: 0.5)
        average.lineWidth = 1
        average.lineDashLengths = [5.0]
        chart?.rightAxis.addLimitLine(average)
        
        // test chart
        testChart = ORKLineGraphChartView(frame: (chart?.frame)!)
        testChart?.delegate = self
        testChart?.dataSource = self
        testChart?.showsVerticalReferenceLines = false
        testChart?.showsHorizontalReferenceLines = false
        //        testChart?.axisColor = UIColor(white: 1.0, alpha: 0.9)
        //        testChart?.tintColor = UIColor(white: 1.0, alpha: 0.9)
        //        testChart?.scrubberLineColor = UIColor(white: 1.0, alpha: 0.9)
        //        testChart?.referenceLineColor = UIColor(white: 1.0, alpha: 0.9)
        //        testChart?.scrubberThumbColor = UIColor(white: 1.0, alpha: 0.9)
        //        testChart?.verticalAxisTitleColor = UIColor(white: 1.0, alpha: 0.9)
        //        self.addSubview(testChart!)
    }
    
    public override func setupLabels() {
        super.setupLabels()
        titleLabel?.text = self.titleText ?? "Steps"
        todayLabel?.text = self.todayText ?? "Daily average: 4,631"
        averageLabel?.text = self.averageText ?? "1,261 steps"
        dateLabel?.text = self.dateText ?? "Today, 8:18"
    }
    
    public override func setData(data:Array<HealthObject>) {
        self.data = data
        
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
        
        // send data to test chart
        testChartPoints = data.map({ORKRangedPoint(value: CGFloat(Float(self.majorValueFromHealthObject($0))!))})
        testChart?.reloadData()
        testChart?.animateWithDuration(1.0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Research Kit delegate & data source
    public func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 1
    }
    
    public func graphChartView(graphChartView: ORKGraphChartView, pointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKRangedPoint {
        guard let p = testChartPoints else {return ORKRangedPoint(value: 0)}
        return p[pointIndex]
    }
    
    public func graphChartView(graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        guard let p = testChartPoints else {return 0}
        return p.count
    }
    
    public func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return "\(pointIndex + 1)"
    }
    
    
}
