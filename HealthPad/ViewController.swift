//
//  ViewController.swift
//  HealthPad
//
//  Created by Finn Gaida on 15.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import UIKit
import HealthKit
import CloudKit

public class ViewController: UIViewController {
    
    let store = HKHealthStore()
    let db = CKContainer.defaultContainer().publicCloudDatabase
    var data = Dictionary<String,Array<HKQuantitySample>>()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction public func selectData(sender: AnyObject) {
        
        if HKHealthStore.isHealthDataAvailable() {
            store.requestAuthorizationToShareTypes(nil, readTypes: self.dataTypes(), completion: { (success, error) -> Void in
                if error != nil {
                    print("there was an error : \(error?.description)")
                } else {
                    self.readData()
                }
            })
        } else {
            
            let alert = UIAlertController(title: "Oops", message: "Looks like you don't have any data in your health app. Please make sure you have enough data available and granted all neccessary permissions to HealthPad in order to sync your Data.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
    }
    
    public func readData() {
        
        let arrays: Array<[HKSampleType]> = [quantityTypes, categoryTypes, correlationTypes, workoutTypes]
        for types in arrays {
            
            for type in types {
                
                let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 100, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)], resultsHandler: { (query, samples, error) -> Void in
                    
                    if let samples = samples as? [HKQuantitySample] {
                        
                        for sample in samples {
                            
                            if let _ = self.data[type.description] {
                                self.data[type.description]?.append(sample)
                            } else {
                                self.data[type.description] = [sample]
                            }
                            
                        }
                    }
                })
                
                store.executeQuery(query)
            }
        }
    }
    
    @IBAction func saveData(sender: AnyObject) {
        
        CKContainer.defaultContainer().accountStatusWithCompletionHandler({ (status, error) -> Void in
            if error == nil && status.rawValue == 1 {
                
                for (type, samples) in self.data {
                    
                    for (index, sample) in samples.enumerate() {
                        
                        print("going to upload item \(sample) nr. \(index) of type \(type)")
                        self.uploadData(sample, index: index)
                    }
                }
                
            } else {
                
                let alert = UIAlertController(title: "Oops", message: "Looks like you don't have iCloud set up. Please make sure you have logged into iCloud in Settings and granted all neccessary permissions to HealthPad in order to sync your Data.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        })
        
    }
    
    public func uploadData(sample: HKQuantitySample, index: Int) {
        
        let s = sample.quantityType.description as NSString
        let r = s.rangeOfString("Identifier")
        let tipe = s.substringFromIndex(r.location + r.length)
        
        print("got sample: \(sample.quantity.description) of type: \(tipe)")
        
        // save that to the cloud
        let record = CKRecord(recordType: tipe, recordID: CKRecordID(recordName: "\(index)"))
        record.setObject(sample.quantity.description, forKey: "content")
        print("attempting to save record \(record) of type \(tipe)...")
        
        self.db.saveRecord(record, completionHandler: { (newrecord, error) -> Void in
            if let e = error {
                print("there was an error: \(e) for record: \(record)\n")
                
                if let retryAfterValue = e.userInfo[CKErrorRetryAfterKey] as? NSTimeInterval {
                
                    self.delay(retryAfterValue, closure: { () -> () in
                        self.uploadData(sample, index: index)
                    })
                
                }
                
            } else {
                print("saved record to cloud: \(newrecord!.description)")
            }
        })
        
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
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    let quantityTypes:[HKQuantityType] = [HKQuantityTypeIdentifierBodyMassIndex, HKQuantityTypeIdentifierBodyFatPercentage, HKQuantityTypeIdentifierHeight, HKQuantityTypeIdentifierBodyMass, HKQuantityTypeIdentifierLeanBodyMass, HKQuantityTypeIdentifierStepCount, HKQuantityTypeIdentifierDistanceWalkingRunning, HKQuantityTypeIdentifierDistanceCycling, HKQuantityTypeIdentifierBasalEnergyBurned, HKQuantityTypeIdentifierActiveEnergyBurned, HKQuantityTypeIdentifierFlightsClimbed, HKQuantityTypeIdentifierNikeFuel, HKQuantityTypeIdentifierHeartRate, HKQuantityTypeIdentifierBodyTemperature, HKQuantityTypeIdentifierBasalBodyTemperature, HKQuantityTypeIdentifierBloodPressureSystolic, HKQuantityTypeIdentifierBloodPressureDiastolic, HKQuantityTypeIdentifierRespiratoryRate, HKQuantityTypeIdentifierOxygenSaturation, HKQuantityTypeIdentifierPeripheralPerfusionIndex, HKQuantityTypeIdentifierBloodGlucose, HKQuantityTypeIdentifierNumberOfTimesFallen, HKQuantityTypeIdentifierElectrodermalActivity, HKQuantityTypeIdentifierInhalerUsage, HKQuantityTypeIdentifierBloodAlcoholContent, HKQuantityTypeIdentifierForcedVitalCapacity, HKQuantityTypeIdentifierForcedExpiratoryVolume1, HKQuantityTypeIdentifierPeakExpiratoryFlowRate, HKQuantityTypeIdentifierDietaryFatTotal, HKQuantityTypeIdentifierDietaryFatPolyunsaturated, HKQuantityTypeIdentifierDietaryFatMonounsaturated, HKQuantityTypeIdentifierDietaryFatSaturated, HKQuantityTypeIdentifierDietaryCholesterol, HKQuantityTypeIdentifierDietarySodium, HKQuantityTypeIdentifierDietaryCarbohydrates, HKQuantityTypeIdentifierDietaryFiber, HKQuantityTypeIdentifierDietarySugar, HKQuantityTypeIdentifierDietaryEnergyConsumed, HKQuantityTypeIdentifierDietaryProtein, HKQuantityTypeIdentifierDietaryVitaminA, HKQuantityTypeIdentifierDietaryVitaminB6, HKQuantityTypeIdentifierDietaryVitaminB12, HKQuantityTypeIdentifierDietaryVitaminC, HKQuantityTypeIdentifierDietaryVitaminD, HKQuantityTypeIdentifierDietaryVitaminE, HKQuantityTypeIdentifierDietaryVitaminK, HKQuantityTypeIdentifierDietaryCalcium, HKQuantityTypeIdentifierDietaryIron, HKQuantityTypeIdentifierDietaryThiamin, HKQuantityTypeIdentifierDietaryRiboflavin, HKQuantityTypeIdentifierDietaryNiacin, HKQuantityTypeIdentifierDietaryFolate, HKQuantityTypeIdentifierDietaryBiotin, HKQuantityTypeIdentifierDietaryPantothenicAcid, HKQuantityTypeIdentifierDietaryPhosphorus, HKQuantityTypeIdentifierDietaryIodine, HKQuantityTypeIdentifierDietaryMagnesium, HKQuantityTypeIdentifierDietaryZinc, HKQuantityTypeIdentifierDietarySelenium, HKQuantityTypeIdentifierDietaryCopper, HKQuantityTypeIdentifierDietaryManganese, HKQuantityTypeIdentifierDietaryChromium, HKQuantityTypeIdentifierDietaryMolybdenum, HKQuantityTypeIdentifierDietaryChloride, HKQuantityTypeIdentifierDietaryPotassium, HKQuantityTypeIdentifierDietaryCaffeine, HKQuantityTypeIdentifierDietaryWater, HKQuantityTypeIdentifierUVExposure].map {HKSampleType.quantityTypeForIdentifier($0)!}
    
    let categoryTypes:[HKCategoryType] = [HKCategoryTypeIdentifierSleepAnalysis, HKCategoryTypeIdentifierAppleStandHour, HKCategoryTypeIdentifierCervicalMucusQuality, HKCategoryTypeIdentifierOvulationTestResult, HKCategoryTypeIdentifierMenstrualFlow, HKCategoryTypeIdentifierIntermenstrualBleeding, HKCategoryTypeIdentifierSexualActivity].map {HKSampleType.categoryTypeForIdentifier($0)!}
    
    let characteristicTypes:[HKCharacteristicType] = [HKCharacteristicTypeIdentifierBiologicalSex, HKCharacteristicTypeIdentifierBloodType, HKCharacteristicTypeIdentifierDateOfBirth, HKCharacteristicTypeIdentifierFitzpatrickSkinType].map {HKObjectType.characteristicTypeForIdentifier($0)!}
    
    let correlationTypes:[HKCorrelationType] = [HKCorrelationTypeIdentifierBloodPressure, HKCorrelationTypeIdentifierFood].map {HKSampleType.correlationTypeForIdentifier($0)!}
    
    let workoutTypes:[HKWorkoutType] = [HKSampleType.workoutType()]
}

