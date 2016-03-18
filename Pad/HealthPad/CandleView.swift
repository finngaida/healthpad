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

public class CandleView: UIView, ChartViewDelegate {
    
    public var chart: CombinedChartView?
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
        titleLabel.text = self.titleText ?? "Heart Rate"
        self.addSubview(titleLabel)
        
        let averageLabel = UILabel(frame: CGRectMake(20, 40, self.frame.width / 2 - 30, 20))
        averageLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        averageLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        averageLabel.text = self.averageText ?? "Min: 49 Max: 112"
        self.addSubview(averageLabel)
        
        let todayLabel = UILabel(frame: CGRectMake(self.frame.width / 2 + 10, 10, self.frame.width / 2 - 30, 30))
        todayLabel.textColor = UIColor.whiteColor()
        todayLabel.textAlignment = .Right
        todayLabel.font = UIFont(name: "HelveticaNeue", size: 25)
        todayLabel.text = self.todayText ?? "67 bpm"
        self.addSubview(todayLabel)
        
        let dateLabel = UILabel(frame: CGRectMake(self.frame.width / 2 + 10, 40, self.frame.width / 2 - 30, 20))
        dateLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        dateLabel.textAlignment = .Right
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        dateLabel.text = self.dateText ?? "Today, 6:25 PM"
        self.addSubview(dateLabel)
        
        let separator = UIView(frame: CGRectMake(20, 65, self.frame.width - 40, 1))
        separator.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        self.addSubview(separator)
        
    }
    
    public func setData(data:Array<HealthObject>) {
        
        var xVals = (1...data.count).map({"\($0)"})
        xVals[0] = "Mar \(xVals[0])"   // TODO Real month
        let enddata = CombinedChartData(xVals: xVals)
        
        let yVals = data.enumerate().map({ (index, obj) -> CandleChartDataEntry in
            return CandleChartDataEntry(xIndex: index, shadowH: (Double(obj.value) ?? 0) + 10, shadowL: Double(obj.value) ?? 0, open: (Double(obj.value) ?? 0) + 10, close: Double(obj.value) ?? 0)
        })
        
        let candleset = CandleChartDataSet(yVals: yVals, label: "")
        
        candleset.drawValuesEnabled = false
        candleset.highlightEnabled = false
        candleset.colors = [UIColor(white: 1.0, alpha: 0.5)]
        candleset.shadowColor = UIColor(white: 1.0, alpha: 0.7)
        candleset.shadowWidth = 0.7
        candleset.decreasingColor = UIColor.clearColor()
        candleset.decreasingFilled = false
        candleset.increasingColor = UIColor.clearColor()
        candleset.increasingFilled = false
        candleset.neutralColor = UIColor.clearColor()
        candleset.barSpace = 0.3
        
        
        let newyVals:[ChartDataEntry] = data.enumerate().map { (index: Int, element: HealthObject) -> ChartDataEntry in
            return ChartDataEntry(value: (Double(element.value) ?? 0) + 10, xIndex: index)
        }
        
        let scattersetupper = ScatterChartDataSet(yVals: newyVals, label: "")
        scattersetupper.scatterShape = .Circle
        scattersetupper.scatterShapeHoleColor = UIColor.clearColor()
        scattersetupper.scatterShapeHoleRadius = 2.5
        scattersetupper.setColor(UIColor(white: 1.0, alpha: 0.8))
        
        let neweryVals:[ChartDataEntry] = data.enumerate().map { (index: Int, element: HealthObject) -> ChartDataEntry in
            return ChartDataEntry(value: Double(element.value) ?? 0, xIndex: index)
        }
        
        let scattersetlower = ScatterChartDataSet(yVals: neweryVals, label: "")
        scattersetlower.scatterShape = .Circle
        scattersetlower.scatterShapeHoleColor = UIColor.clearColor()
        scattersetlower.scatterShapeHoleRadius = 2.5
        scattersetlower.setColor(UIColor(white: 1.0, alpha: 0.8))
        
        enddata.scatterData = ScatterChartData(xVals: xVals, dataSets: [scattersetupper, scattersetlower])
        enddata.candleData = CandleChartData(xVals: xVals, dataSets: [candleset])
        
        chart?.data = enddata
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
