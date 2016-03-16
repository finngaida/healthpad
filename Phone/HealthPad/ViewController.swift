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
import SwitchLoader
import Async

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
        
        // start loader
        let loader = Loader.showLoader(self)
        
        let arrays: Array<[HKSampleType]> = [quantityTypes, categoryTypes, correlationTypes, workoutTypes]
        for (index1, types) in arrays.enumerate() {
            
            for (index2, type) in types.enumerate() {
                
                update(loader, s: "Reading \(index2) of \(type.description)")
                
                let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 100/*TODO*/, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)], resultsHandler: { (query, samples, error) -> Void in
                    
                    if let samples = samples as? [HKQuantitySample] {
                        
                        for (index3, sample) in samples.enumerate() {
                            
                            if let _ = self.data[type.description] {
                                self.data[type.description]?.append(sample)
                            } else {
                                self.data[type.description] = [sample]
                            }
                            
                            self.update(loader, s: "Reading \(index3) of \(type.description)")
                            
                            print("1: \(index1), 2: \(index2), 3: \(index3)")
                            
                            if index1 == arrays.count-1 && index2 == types.count-1 && index3 == samples.count-1 {
                                Async.main(after: 1.0, block: { () -> Void in
                                    Loader.hideLoader(self)
                                })
                            }
                        }
                    }
                })
                
                store.executeQuery(query)
            }
        }
    }
    
    func update(l:Loader, s: String) {
        print(s)
        Async.main { () -> Void in
            l.label!.text = s
        }
    }
    
    @IBAction func saveData(sender: AnyObject) {
        
        CKContainer.defaultContainer().accountStatusWithCompletionHandler({ (status, error) -> Void in
            if error == nil && status.rawValue == 1 {
                
                self.uploadData()
                
            } else {
                
                let alert = UIAlertController(title: "Oops", message: "Looks like you don't have iCloud set up. Please make sure you have logged into iCloud in Settings and granted all neccessary permissions to HealthPad in order to sync your Data.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        })
        
    }
    
    public func uploadData() {
        
        // start loader
        let loader = Loader.showLoader(self)
        
        for (_, samples) in self.data {
            
            for (index, sample) in samples.enumerate() {
                
                let s = sample.quantityType.description as NSString
                let r = s.rangeOfString("Identifier")
                let tipe = s.substringFromIndex(r.location + r.length)
                
                // save that to the cloud
                let record = CKRecord(recordType: tipe, recordID: CKRecordID(recordName: "\(index)"))
                let parts = sample.quantity.description.componentsSeparatedByString(" ")
                
                if parts.count >= 1 {
                    record.setObject(parts[0], forKey: "content")
                    record.setObject(parts[1], forKey: "unit")
                } else {
                    record.setObject(sample.quantity.description, forKey: "content")
                }
                
                record.setObject(sample.endDate, forKey: "endDate")
                record.setObject(tipe, forKey: "type")
                
                update(loader, s: "saving record \(record.description) of type \(tipe)")
                save(record, loader: loader)
            }
        }
    }
    
    private func save(record: CKRecord, loader: Loader) {
        self.db.saveRecord(record, completionHandler: { (newrecord, error) -> Void in
            if let e = error {
                self.update(loader, s: "there was an error: \(e.localizedDescription)")
                
                if let retryAfterValue = e.userInfo[CKErrorRetryAfterKey] as? NSTimeInterval {
                    
                    Async.background(after: retryAfterValue, block: { () -> Void in
                        self.save(record, loader: loader)
                    })
                    
                }
                
            } else {
                self.update(loader, s: "saved record to cloud: \(newrecord!.description)")
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
    
    let quantityTypes:[HKQuantityType] = [HKQuantityTypeIdentifierBodyMassIndex, HKQuantityTypeIdentifierBodyFatPercentage, HKQuantityTypeIdentifierHeight, HKQuantityTypeIdentifierBodyMass, HKQuantityTypeIdentifierLeanBodyMass, HKQuantityTypeIdentifierStepCount, HKQuantityTypeIdentifierDistanceWalkingRunning, HKQuantityTypeIdentifierDistanceCycling, HKQuantityTypeIdentifierBasalEnergyBurned, HKQuantityTypeIdentifierActiveEnergyBurned, HKQuantityTypeIdentifierFlightsClimbed, HKQuantityTypeIdentifierNikeFuel, HKQuantityTypeIdentifierHeartRate, HKQuantityTypeIdentifierBodyTemperature, HKQuantityTypeIdentifierBasalBodyTemperature, HKQuantityTypeIdentifierBloodPressureSystolic, HKQuantityTypeIdentifierBloodPressureDiastolic, HKQuantityTypeIdentifierRespiratoryRate, HKQuantityTypeIdentifierOxygenSaturation, HKQuantityTypeIdentifierPeripheralPerfusionIndex, HKQuantityTypeIdentifierBloodGlucose, HKQuantityTypeIdentifierNumberOfTimesFallen, HKQuantityTypeIdentifierElectrodermalActivity, HKQuantityTypeIdentifierInhalerUsage, HKQuantityTypeIdentifierBloodAlcoholContent, HKQuantityTypeIdentifierForcedVitalCapacity, HKQuantityTypeIdentifierForcedExpiratoryVolume1, HKQuantityTypeIdentifierPeakExpiratoryFlowRate, HKQuantityTypeIdentifierDietaryFatTotal, HKQuantityTypeIdentifierDietaryFatPolyunsaturated, HKQuantityTypeIdentifierDietaryFatMonounsaturated, HKQuantityTypeIdentifierDietaryFatSaturated, HKQuantityTypeIdentifierDietaryCholesterol, HKQuantityTypeIdentifierDietarySodium, HKQuantityTypeIdentifierDietaryCarbohydrates, HKQuantityTypeIdentifierDietaryFiber, HKQuantityTypeIdentifierDietarySugar, HKQuantityTypeIdentifierDietaryEnergyConsumed, HKQuantityTypeIdentifierDietaryProtein, HKQuantityTypeIdentifierDietaryVitaminA, HKQuantityTypeIdentifierDietaryVitaminB6, HKQuantityTypeIdentifierDietaryVitaminB12, HKQuantityTypeIdentifierDietaryVitaminC, HKQuantityTypeIdentifierDietaryVitaminD, HKQuantityTypeIdentifierDietaryVitaminE, HKQuantityTypeIdentifierDietaryVitaminK, HKQuantityTypeIdentifierDietaryCalcium, HKQuantityTypeIdentifierDietaryIron, HKQuantityTypeIdentifierDietaryThiamin, HKQuantityTypeIdentifierDietaryRiboflavin, HKQuantityTypeIdentifierDietaryNiacin, HKQuantityTypeIdentifierDietaryFolate, HKQuantityTypeIdentifierDietaryBiotin, HKQuantityTypeIdentifierDietaryPantothenicAcid, HKQuantityTypeIdentifierDietaryPhosphorus, HKQuantityTypeIdentifierDietaryIodine, HKQuantityTypeIdentifierDietaryMagnesium, HKQuantityTypeIdentifierDietaryZinc, HKQuantityTypeIdentifierDietarySelenium, HKQuantityTypeIdentifierDietaryCopper, HKQuantityTypeIdentifierDietaryManganese, HKQuantityTypeIdentifierDietaryChromium, HKQuantityTypeIdentifierDietaryMolybdenum, HKQuantityTypeIdentifierDietaryChloride, HKQuantityTypeIdentifierDietaryPotassium, HKQuantityTypeIdentifierDietaryCaffeine, HKQuantityTypeIdentifierDietaryWater, HKQuantityTypeIdentifierUVExposure].map {HKSampleType.quantityTypeForIdentifier($0)!}
    
    let categoryTypes:[HKCategoryType] = [HKCategoryTypeIdentifierSleepAnalysis, HKCategoryTypeIdentifierAppleStandHour, HKCategoryTypeIdentifierCervicalMucusQuality, HKCategoryTypeIdentifierOvulationTestResult, HKCategoryTypeIdentifierMenstrualFlow, HKCategoryTypeIdentifierIntermenstrualBleeding, HKCategoryTypeIdentifierSexualActivity].map {HKSampleType.categoryTypeForIdentifier($0)!}
    
    let characteristicTypes:[HKCharacteristicType] = [HKCharacteristicTypeIdentifierBiologicalSex, HKCharacteristicTypeIdentifierBloodType, HKCharacteristicTypeIdentifierDateOfBirth, HKCharacteristicTypeIdentifierFitzpatrickSkinType].map {HKObjectType.characteristicTypeForIdentifier($0)!}
    
    let correlationTypes:[HKCorrelationType] = [HKCorrelationTypeIdentifierBloodPressure, HKCorrelationTypeIdentifierFood].map {HKSampleType.correlationTypeForIdentifier($0)!}
    
    let workoutTypes:[HKWorkoutType] = [HKSampleType.workoutType()]
}

