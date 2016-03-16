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

public class Helper: NSObject {
    
    public static let sharedHelper = Helper()
    public let db = CKContainer.defaultContainer().publicCloudDatabase
    public var latestData:Dictionary<String,Array<HealthObject>>?
    
    public let typeSelectedNotification = "typeSelectedNotification"
    public let showLineChartSegue = "showLineChart"
    
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
                                
                                let obj = HealthObject(value: record["content"] as! String, unit: record["unit"] as? String, endDate: record["endDate"] as? NSDate)
                                data[name] = [obj]  // TODO: append to list, if not the first
                                
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
    
    public enum Color {
        case Orange
        case Grey
        case Yellow
        case Purple
        case Blue
    }
    
    public class func gradientForColor(frame: CGRect, color: Color) -> UIView {
        
        let gradient = GradientView(frame: frame)
        
        switch color {
        case .Orange:
            gradient.colors = [UIColor(red: 0.992, green: 0.584, blue: 0.345, alpha: 1.00), UIColor(red: 0.988, green: 0.243, blue: 0.224, alpha: 1.00)]
            break
        case .Grey:
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

public struct HealthObject {
    let value:String    // Todo: respect the unit and make it a double
    let unit:String?    // Todo: make that a HKUnit
    let endDate:NSDate?
}
