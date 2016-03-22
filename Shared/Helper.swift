//
//  Helper.swift
//  HealthPad Companion
//
//  Created by Finn Gaida on 16.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import Async
import HealthKit
import GradientView
import ResearchKit

public class Helper: NSObject {
    
    public static let sharedHelper = Helper()
    public let db = CKContainer.defaultContainer().publicCloudDatabase
    public var latestData:Dictionary<String,Array<HealthObject>>?
    
    public let typeSelectedNotification = "typeSelectedNotification"
    public let showLineChartSegue = "showLineChart"
    public let showStepsSegue = "showSteps"
    public let showWeightSegue = "showWeight"
    public let showSleepSegue = "showSleep"
    public let showHeartRateSegue = "showHeartRate"
    public let showBloodPressureSegue = "showBloodPressure"
    
    public override init() {
        super.init()
        
    }
    
    public class func update(l:Loader, s: String) {
        print(s)
        Async.main { () -> Void in
            l.label!.text = s
        }
    }
    
    public func save(record: CKRecord, loader: Loader) {
        self.db.saveRecord(record, completionHandler: { (newrecord, error) -> Void in
            if let e = error {
                Helper.update(loader, s: "\(Helper.editErrorMessage(e.localizedDescription))")
                
                if let retryAfterValue = e.userInfo[CKErrorRetryAfterKey] as? NSTimeInterval {
                    
                    Async.background(after: retryAfterValue, block: { () -> Void in
                        self.save(record, loader: loader)
                    })
                    
                }
                
            } else {
                Helper.update(loader, s: "saved record to cloud: \(newrecord!.description)")
            }
        })
    }
    
    public func fetchData(loader: Loader, completion: (Dictionary<String,Array<HealthObject>> -> ())) {
        
        var data = Dictionary<String,Array<HealthObject>>()
        
        let predicate = NSPredicate(value: true)
        db.performQuery(CKQuery(recordType: "Index", predicate: predicate), inZoneWithID: nil) { (records, error) -> Void in
            if let e = error {
                Helper.update(loader, s: Helper.editErrorMessage(e.localizedDescription))
            } else if let r = records {
                
                Helper.update(loader, s: "Got index, loading items...")
                
                for (index, record) in r.enumerate() {
                    
                    let name = record.recordID.recordName
                    Helper.update(loader, s: "Found section \(name)")
                    
                    let predicate = NSPredicate(value: true)
                    self.db.performQuery(CKQuery(recordType: name, predicate: predicate), inZoneWithID: nil, completionHandler: { (records, error) -> Void in
                        if let e = error {
                            Helper.update(loader, s: Helper.editErrorMessage(e.localizedDescription))
                        } else if let r2 = records {
                            Helper.update(loader, s: Helper.editErrorMessage("got record: \(r)"))
                            
                            for (index2, record) in r2.enumerate() {
                                
                                if let obj = self.healthObjectFromRecord(record) {
                                    data[name] = [obj]
                                } else {
                                    
                                    let obj = GeneralHealthObject(value:record["content"] ?? "", description: "General Health data", unit:nil, date:record["endDate"] as? NSDate)
                                    
                                    if data[name] == nil {
                                        data[name] = [obj]
                                    } else {
                                        data[name]?.append(obj)
                                    }
                                }
                                
                                if index == r.count - 1 && index2 == r2.count - 1 {
                                    self.latestData = data
                                    completion(data)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    public func healthObjectFromRecord(record: CKRecord) -> HealthObject? {
        
        let content = record["content"]
        let unit = record["unit"] ?? ""
        let date:NSDate? = record["endDate"] as? NSDate
        let type = record["type"] ?? ""
        
        print("trying to convert record of type \(type) with value \(content)\(unit) from \(date)")
        
        switch record.recordType {
        case "StepCount":
            guard let count = content as? Int else {return nil}
            return Steps(count:count, description: "Number of steps", unit:Unit.steps, date:date)
            
        case "HeartRate":
            guard let values = content as? Array<Int> else {return nil}
            return HeartRate(highestbpm:values.maxElement() ?? 0, lowestbpm:values.minElement() ?? 0, all:values.map({HeartRateValue(date:nil, bpm: $0)}), description: "Heart rate in beats perminute", unit:Unit.bpm, date:date)
            
        case "BloodPressure":
            guard let values = content as? Array<(Int,Int)> else {return nil}
            
            let high = values.map({$0.0}).maxElement()
            let low = values.map({$0.1}).minElement()
            
            return BloodPressure(highest:high ?? 0, lowest: low ?? 0, all:values.map({BloodPressureValue(systolic:$0, diastolic:$1)}), description: "Blood Presure in mm of a Hg scale", unit:Unit.mmHg, date:date)
            
        case "Weight":
            guard let weight = content as? Double else {return nil}
            return Weight(value:weight, description: "Weight in kg", unit:Unit.kg, date:date)
            
        default:
            return GeneralHealthObject(value:content ?? "", description: "General health object", unit:nil, date:date)
        }
        
    }
    
    public class func editErrorMessage(e:String) -> String {
        
        let s = e as NSString
        let start = s.rangeOfString("<").location
        let end = s.rangeOfString(">").location
        
        if s.length - 2 > end {
            return s.stringByReplacingCharactersInRange(NSMakeRange(start, end-start+2), withString: "")
        } else {
            return e
        }
    }
    
    public class func gradientForColor(frame: CGRect, color: FGColor) -> UIView {
        
        let gradient = GradientView(frame: frame)
        
        switch color {
        case .Orange:
            gradient.colors = [UIColor(red: 0.992, green: 0.584, blue: 0.345, alpha: 1.00), UIColor(red: 0.988, green: 0.243, blue: 0.224, alpha: 1.00)]
            break
        case .Gray:
            gradient.colors = [UIColor(red: 0.820, green: 0.820, blue: 0.839, alpha: 1.00), UIColor(red: 0.549, green: 0.549, blue: 0.573, alpha: 1.00)]
            break
        case .Yellow:
            gradient.colors = [UIColor(red: 0.992, green: 0.831, blue: 0.212, alpha: 1.00), UIColor(red: 0.988, green: 0.635, blue: 0.161, alpha: 1.00)]
            break
        case .Purple:
            gradient.colors = [UIColor(red: 0.859, green: 0.651, blue: 0.988, alpha: 1.00), UIColor(red: 0.545, green: 0.263, blue: 0.980, alpha: 1.00)]
            break
        case .Blue:
            gradient.colors = []
            break
        }
        
        return gradient
    }
    
    public func dataTypes() -> Set<HKObjectType> {
        
        var readset:Set<HKObjectType> = Set()
        
        quantityTypes.forEach { (type) -> () in
            readset.insert(type)
        }
        
        categoryTypes.forEach { (type) -> () in
            readset.insert(type)
        }
        
        characteristicTypes.forEach { (type) -> () in
            readset.insert(type)
        }
        
        correlationTypes.forEach { (type) -> () in
            //            readset.insert(type)
        }
        
        workoutTypes.forEach { (type) -> () in
            readset.insert(type)
        }
        
        return readset
        
    }
    
    public let quantityTypes:[HKQuantityType] = [HKQuantityTypeIdentifierBodyMassIndex, HKQuantityTypeIdentifierBodyFatPercentage, HKQuantityTypeIdentifierHeight, HKQuantityTypeIdentifierBodyMass, HKQuantityTypeIdentifierLeanBodyMass, HKQuantityTypeIdentifierStepCount, HKQuantityTypeIdentifierDistanceWalkingRunning, HKQuantityTypeIdentifierDistanceCycling, HKQuantityTypeIdentifierBasalEnergyBurned, HKQuantityTypeIdentifierActiveEnergyBurned, HKQuantityTypeIdentifierFlightsClimbed, HKQuantityTypeIdentifierNikeFuel, HKQuantityTypeIdentifierHeartRate, HKQuantityTypeIdentifierBodyTemperature, HKQuantityTypeIdentifierBasalBodyTemperature, HKQuantityTypeIdentifierBloodPressureSystolic, HKQuantityTypeIdentifierBloodPressureDiastolic, HKQuantityTypeIdentifierRespiratoryRate, HKQuantityTypeIdentifierOxygenSaturation, HKQuantityTypeIdentifierPeripheralPerfusionIndex, HKQuantityTypeIdentifierBloodGlucose, HKQuantityTypeIdentifierNumberOfTimesFallen, HKQuantityTypeIdentifierElectrodermalActivity, HKQuantityTypeIdentifierInhalerUsage, HKQuantityTypeIdentifierBloodAlcoholContent, HKQuantityTypeIdentifierForcedVitalCapacity, HKQuantityTypeIdentifierForcedExpiratoryVolume1, HKQuantityTypeIdentifierPeakExpiratoryFlowRate, HKQuantityTypeIdentifierDietaryFatTotal, HKQuantityTypeIdentifierDietaryFatPolyunsaturated, HKQuantityTypeIdentifierDietaryFatMonounsaturated, HKQuantityTypeIdentifierDietaryFatSaturated, HKQuantityTypeIdentifierDietaryCholesterol, HKQuantityTypeIdentifierDietarySodium, HKQuantityTypeIdentifierDietaryCarbohydrates, HKQuantityTypeIdentifierDietaryFiber, HKQuantityTypeIdentifierDietarySugar, HKQuantityTypeIdentifierDietaryEnergyConsumed, HKQuantityTypeIdentifierDietaryProtein, HKQuantityTypeIdentifierDietaryVitaminA, HKQuantityTypeIdentifierDietaryVitaminB6, HKQuantityTypeIdentifierDietaryVitaminB12, HKQuantityTypeIdentifierDietaryVitaminC, HKQuantityTypeIdentifierDietaryVitaminD, HKQuantityTypeIdentifierDietaryVitaminE, HKQuantityTypeIdentifierDietaryVitaminK, HKQuantityTypeIdentifierDietaryCalcium, HKQuantityTypeIdentifierDietaryIron, HKQuantityTypeIdentifierDietaryThiamin, HKQuantityTypeIdentifierDietaryRiboflavin, HKQuantityTypeIdentifierDietaryNiacin, HKQuantityTypeIdentifierDietaryFolate, HKQuantityTypeIdentifierDietaryBiotin, HKQuantityTypeIdentifierDietaryPantothenicAcid, HKQuantityTypeIdentifierDietaryPhosphorus, HKQuantityTypeIdentifierDietaryIodine, HKQuantityTypeIdentifierDietaryMagnesium, HKQuantityTypeIdentifierDietaryZinc, HKQuantityTypeIdentifierDietarySelenium, HKQuantityTypeIdentifierDietaryCopper, HKQuantityTypeIdentifierDietaryManganese, HKQuantityTypeIdentifierDietaryChromium, HKQuantityTypeIdentifierDietaryMolybdenum, HKQuantityTypeIdentifierDietaryChloride, HKQuantityTypeIdentifierDietaryPotassium, HKQuantityTypeIdentifierDietaryCaffeine, HKQuantityTypeIdentifierDietaryWater, HKQuantityTypeIdentifierUVExposure].map {HKSampleType.quantityTypeForIdentifier($0)!}
    
    public let categoryTypes:[HKCategoryType] = [HKCategoryTypeIdentifierSleepAnalysis, HKCategoryTypeIdentifierAppleStandHour, HKCategoryTypeIdentifierCervicalMucusQuality, HKCategoryTypeIdentifierOvulationTestResult, HKCategoryTypeIdentifierMenstrualFlow, HKCategoryTypeIdentifierIntermenstrualBleeding, HKCategoryTypeIdentifierSexualActivity].map {HKSampleType.categoryTypeForIdentifier($0)!}
    
    public let characteristicTypes:[HKCharacteristicType] = [HKCharacteristicTypeIdentifierBiologicalSex, HKCharacteristicTypeIdentifierBloodType, HKCharacteristicTypeIdentifierDateOfBirth, HKCharacteristicTypeIdentifierFitzpatrickSkinType].map {HKObjectType.characteristicTypeForIdentifier($0)!}
    
    public let correlationTypes:[HKCorrelationType] = [HKCorrelationTypeIdentifierBloodPressure, HKCorrelationTypeIdentifierFood].map {HKSampleType.correlationTypeForIdentifier($0)!}
    
    public let workoutTypes:[HKWorkoutType] = [HKSampleType.workoutType()]
    
}

public class ResearchKitGraphHelper:NSObject, ORKGraphChartViewDataSource, ORKGraphChartViewDelegate {
    
    public static let sharedHelper = ResearchKitGraphHelper()
    public var lineChart:ORKLineGraphChartView?
    public var candleChart:ORKDiscreteGraphChartView?
    public var data:[ORKRangedPoint]? {
        didSet {
            if let line = lineChart {
                line.reloadData()
                line.animateWithDuration(0.5)
            }
            
            if let candle = candleChart {
                candle.reloadData()
                candle.animateWithDuration(0.5)
            }
        }
    }
    
    public func lineChart(frame: CGRect) -> ORKLineGraphChartView {
        lineChart = ORKLineGraphChartView(frame: frame)
        lineChart?.delegate = self
        lineChart?.dataSource = self
        lineChart?.showsVerticalReferenceLines = false
        lineChart?.showsHorizontalReferenceLines = false
        lineChart?.axisColor = UIColor(white: 1.0, alpha: 0.9)
        lineChart?.tintColor = UIColor(white: 1.0, alpha: 0.9)
        lineChart?.scrubberLineColor = UIColor(white: 1.0, alpha: 0.9)
        lineChart?.referenceLineColor = UIColor(white: 1.0, alpha: 0.9)
        lineChart?.scrubberThumbColor = UIColor(white: 1.0, alpha: 0.9)
        lineChart?.verticalAxisTitleColor = UIColor(white: 1.0, alpha: 0.9)
        return lineChart!
    }
    
    public func candleChart(frame: CGRect) -> ORKDiscreteGraphChartView {
        candleChart = ORKDiscreteGraphChartView(frame: frame)
        candleChart?.delegate = self
        candleChart?.dataSource = self
        candleChart?.showsVerticalReferenceLines = false
        candleChart?.showsHorizontalReferenceLines = false
        candleChart?.axisColor = UIColor(white: 1.0, alpha: 1.0)
        candleChart?.scrubberLineColor = UIColor(white: 1.0, alpha: 0.5)
        candleChart?.referenceLineColor = UIColor(white: 1.0, alpha: 0.7)
        candleChart?.scrubberThumbColor = UIColor(white: 1.0, alpha: 0.8)
        candleChart?.verticalAxisTitleColor = UIColor(white: 1.0, alpha: 1.0)
        candleChart?.tintColor = UIColor(white: 1.0, alpha: 0.5)
        return candleChart!
    }
    
    public func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 1
    }
    
    public func graphChartView(graphChartView: ORKGraphChartView, pointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKRangedPoint {
        guard let p = data else {return ORKRangedPoint(value: 0)}
        return p[pointIndex]
    }
    
    public func graphChartView(graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        guard let p = data else {return 0}
        return p.count
    }
    
    public func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return "\(pointIndex + 1)"
    }
    
    public func graphChartViewTouchesBegan(graphChartView: ORKGraphChartView) {
        
    }
    
    public func graphChartView(graphChartView: ORKGraphChartView, touchesMovedToXPosition xPosition: CGFloat) {
        
    }
    
    public func graphChartViewTouchesEnded(graphChartView: ORKGraphChartView) {
        
    }
    
//    public func maximumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
//        
//    }
    
    public func minimumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return 0
    }
    
    public func scrubbingPlotIndexForGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 0
    }
    
//    public func numberOfDivisionsInXAxisForGraphChartView(graphChartView: ORKGraphChartView) -> Int {
//        
//    }
    
    public func graphChartView(graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
        return UIColor(white: 1.0, alpha: 0.8)
    }
    
    public func graphChartView(graphChartView: ORKGraphChartView, drawsVerticalReferenceLineAtPointIndex pointIndex: Int) -> Bool {
        return false
    }

}
