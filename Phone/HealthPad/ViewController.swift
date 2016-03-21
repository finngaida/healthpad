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
import Async

public class ViewController: UIViewController {
    
    let store = HKHealthStore()
    var data = Dictionary<String,Array<HKQuantitySample>>()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction public func selectData(sender: AnyObject) {
        
        if HKHealthStore.isHealthDataAvailable() {
            store.requestAuthorizationToShareTypes(nil, readTypes: Helper.sharedHelper.dataTypes(), completion: { (success, error) -> Void in
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
        
        let arrays: Array<[HKSampleType]> = [Helper.sharedHelper.quantityTypes, Helper.sharedHelper.categoryTypes, Helper.sharedHelper.correlationTypes, Helper.sharedHelper.workoutTypes]
        for (index1, types) in arrays.enumerate() {
            
            for (index2, type) in types.enumerate() {
                
                Helper.update(loader, s: "Reading \(index2) of \(type.description)")
                
                let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 100/*TODO*/, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)], resultsHandler: { (query, samples, error) -> Void in
                    
                    if let samples = samples as? [HKQuantitySample] {
                        
                        for (index3, sample) in samples.enumerate() {
                            
                            if let _ = self.data[type.description] {
                                self.data[type.description]?.append(sample)
                            } else {
                                self.data[type.description] = [sample]
                            }
                            
                            Helper.update(loader, s: "Reading \(index3) of \(type.description)")
                            
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
                
                Helper.update(loader, s: Helper.editErrorMessage("saving record \(record.description) of type \(tipe)"))
                Helper.sharedHelper.save(record, loader: loader)
            }
        }
    }
    
}

