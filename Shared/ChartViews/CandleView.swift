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

public class CandleView: ChartView, ORKGraphChartViewDelegate, ORKGraphChartViewDataSource {
    
    public var chart: CombinedChartView?
    public var testChart: ORKDiscreteGraphChartView?
    private var testChartPoints:[ORKRangedPoint]?
    
    public var shadowVisible: Bool = true {
        didSet {
            self.reload()
        }
    }
    
    public var scatterShape: ScatterChartDataSet.ScatterShape = .Circle {
        didSet {
            self.reload()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override func setupChart() {
        // chart setup
        chart = CombinedChartView(frame: CGRectMake(25, 85, self.frame.width - 40, self.frame.height - 110))
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
        chart?.alpha = 0
        self.addSubview(Helper.gradientForColor(CGRectMake(0, 0, self.frame.width, self.frame.height), color: self.color))
        self.addSubview(chart!)
        
        let average = ChartLimitLine(limit: 17.0)
        average.lineColor = UIColor(white: 1.0, alpha: 0.5)
        average.lineWidth = 1
        average.lineDashLengths = [5.0]
        chart?.rightAxis.addLimitLine(average)
        
        
        // test chart
        testChart = ORKDiscreteGraphChartView(frame: (chart?.frame)!)
        testChart?.delegate = self
        testChart?.dataSource = self
        testChart?.showsVerticalReferenceLines = false
        testChart?.showsHorizontalReferenceLines = false
        testChart?.axisColor = UIColor(white: 1.0, alpha: 1.0)
        testChart?.scrubberLineColor = UIColor(white: 1.0, alpha: 0.5)
        testChart?.referenceLineColor = UIColor(white: 1.0, alpha: 0.7)
        testChart?.scrubberThumbColor = UIColor(white: 1.0, alpha: 0.8)
        testChart?.verticalAxisTitleColor = UIColor(white: 1.0, alpha: 1.0)
        testChart?.tintColor = UIColor(white: 1.0, alpha: 0.5)
        testChart?.alpha = 0
        self.addSubview(testChart!)
    }
    
    public override func setupLabels() {
        super.setupLabels()
        titleLabel?.text = self.titleText ?? "Heart Rate"
        todayLabel?.text = self.todayText ?? "67 bpm"
        averageLabel?.text = self.averageText ?? "Min: 49 Max: 112"
        dateLabel?.text = self.dateText ?? "Today, 6:25 PM"
    }
    
    public override func setData(data:Array<HealthObject>) {
        
        let radius:CGFloat = 2.5
        
        // creating the values for the x-axis
        var xVals = (1...data.count).map({"\($0)"})
        xVals[0] = "Mar \(xVals[0])"   // TODO Real month
        let enddata = CombinedChartData(xVals: xVals)
        
        // y-Values for the white bg bar (heart rate)
        let candleyVals = data.enumerate().map({ (index, obj) -> CandleChartDataEntry in
            return CandleChartDataEntry(xIndex: index, shadowH: (Double(self.majorValueFromHealthObject(obj)) ?? 0) + 10, shadowL: Double(self.majorValueFromHealthObject(obj)) ?? 0, open: 0, close: 0)
        })
        
        // y-Values for the upper+lower entries
        let upperyVals:[ChartDataEntry] = data.enumerate().map { (index: Int, element: HealthObject) -> ChartDataEntry in
            return ChartDataEntry(value: (Double(self.majorValueFromHealthObject(element)) ?? 0), xIndex: index)
        }
        
        let loweryVals:[ChartDataEntry] = data.enumerate().map { (index: Int, element: HealthObject) -> ChartDataEntry in
            return ChartDataEntry(value: Double(self.minorValueFromHealthObject(element)) ?? ((Double(self.majorValueFromHealthObject(element)) ?? 80) - 30), xIndex: index)
        }
        
        // creating the sets
        let candleset = CandleChartDataSet(yVals: candleyVals, label: "")
        let scattersetupper = ScatterChartDataSet(yVals: upperyVals, label: "")
        let scattersetlower = ScatterChartDataSet(yVals: loweryVals, label: "")
        
        // setting some properties
        [candleset, scattersetupper, scattersetlower].forEach({
            $0.drawValuesEnabled = false
            $0.highlightEnabled = false
        })
        
        [scattersetupper, scattersetlower].forEach({
            $0.drawValuesEnabled = false
            $0.scatterShapeHoleColor = (self.color == .Gray) ? UIColor.lightGrayColor() : UIColor.clearColor()
            $0.scatterShapeHoleRadius = radius
            $0.setColor(UIColor(white: 1.0, alpha: 0.9))
            $0.scatterShape = self.scatterShape
        })
        
        candleset.setColor(UIColor(white: 1.0, alpha: self.shadowVisible ? 0.4 : 0.0))
        candleset.shadowWidth = radius * 3.5
        
        if (self.scatterShape == .Custom) {
            scattersetupper.customScatterShape = self.createArrowPath(true, radius: radius)
            scattersetlower.customScatterShape = self.createArrowPath(false, radius: radius)
            chart?.alpha = 1
        } else {
            testChart?.alpha = 1
        }
        
        // aand put that into the chart
        enddata.scatterData = ScatterChartData(xVals: xVals, dataSets: [scattersetupper, scattersetlower])
        enddata.candleData = CandleChartData(xVals: xVals, dataSets: [candleset])
        chart?.data = enddata
        
        
        // send data to test chart
        testChartPoints = data.map({ORKRangedPoint(minimumValue: CGFloat(Float(self.majorValueFromHealthObject($0)) ?? 0) - 10, maximumValue: CGFloat(Float(self.majorValueFromHealthObject($0)) ?? 0))})
        testChart?.reloadData()
        testChart?.animateWithDuration(1.0)
    }
    
    public func createArrowPath(up:Bool, radius:CGFloat) -> CGPathRef {
        let delta:CGFloat = radius * 2
        
        let ctx = UIGraphicsGetCurrentContext()
        let path = CGPathCreateMutable()
        
        if up {
            CGPathMoveToPoint(path, nil, -delta, 0)
            CGPathAddLineToPoint(path, nil, 0, delta)
            CGPathAddLineToPoint(path, nil, delta, 0)
            CGPathMoveToPoint(path, nil, delta-delta/2, 0)
            CGPathAddLineToPoint(path, nil, 0, delta-delta/2)
            CGPathAddLineToPoint(path, nil, delta/2-delta, 0)
        } else {
            CGPathMoveToPoint(path, nil, -delta, 0)
            CGPathAddLineToPoint(path, nil, 0, -delta)
            CGPathAddLineToPoint(path, nil, delta, 0)
            CGPathMoveToPoint(path, nil, delta-delta/2, 0)
            CGPathAddLineToPoint(path, nil, 0, -delta+delta/2)
            CGPathAddLineToPoint(path, nil, delta/2-delta, 0)
        }
        
        CGPathCloseSubpath(path)
        CGContextAddPath(ctx, path)
        CGContextSetStrokeColorWithColor(ctx,UIColor(white: 1.0, alpha: 0.9).CGColor);
        CGContextDrawPath(ctx, .EOFillStroke)
        
        return path
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
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
