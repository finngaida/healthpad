//
//  HealthPadTests.swift
//  HealthPadTests
//
//  Created by Finn Gaida on 16.03.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

import XCTest
import Quick
import Nimble
import CloudKit
@testable import HealthPad

class HelperSpec: QuickSpec {
    
    override func spec() {
        
        context("Helper.swift") {
            describe("updating the status label on the loader") {
                
                // Arrange
                let vc = UIViewController()
                let loader = Loader.showLoader(vc)
                
                // Act
                Helper.update(loader, s: "This is a test!")
                
                // Assert
                it("should show the new text") {
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        expect(loader.label?.text).to(equal("This is a test!"))
                    }
                }
                
            }
            
            describe("saving a record to the cloud") {
                it("should not fail") {
                    
                }
            }
            
            describe("fetch the latest data from iCloud") {
                it("should return correct data") {
                    
                }
            }
            
            describe("converting records into days") {
                
                // Arrange
                let helper = Helper.sharedHelper
                let cal = NSCalendar.currentCalendar()
                let components = cal.components([.Day], fromDate: NSDate())
                
                let date1 = cal.dateFromComponents(components)
                components.day += 1
                let date2 = cal.dateFromComponents(components)
                
                let record1Day1 = CKRecord(recordType: "Test")
                let record2Day1 = CKRecord(recordType: "Test")
                let record1Day2 = CKRecord(recordType: "Test")
                let record2Day2 = CKRecord(recordType: "Test")
                
                record1Day1["endDate"] = date1
                record2Day1["endDate"] = date1
                record1Day2["endDate"] = date2
                record2Day2["endDate"] = date2
                
                record1Day1["content"] = "10.0"
                record2Day1["content"] = "20.0"
                record1Day2["content"] = "10.0"
                record2Day2["content"] = "20.0"
                
                let records = [record1Day1, record2Day1, record1Day2, record2Day2]
                
                // Act
                if let days = helper.daysFromRecords(records, recordType: "Test") {
                    
                    // Assert
                    it("should have correctly created 2 days out of the 4 records") {
                        expect(days.count).to(equal(2))
                    }
                    
                    it("should have correctly set up the values on both days") {
                        days.forEach({ (day) -> () in
                            expect(day.minimumValue).to(equal(10.0))
                            expect(day.maximumValue).to(equal(20.0))
                            expect(day.all?.count).to(equal(2))
                        })
                    }
                    
                    
                } else {
                    XCTFail("The returned days array should not be nil")
                }
                
            }
            
            describe("converts steps record to health object") {
                
                // Arrange
                let record = CKRecord(recordType: "StepCount")
                record["content"] = "123.0"
                let date = NSDate()
                record["endDate"] = date
                //        record["unit"] = "steps"
                record["type"] = "StepCound"
                
                // Act
                guard let obj = Helper.sharedHelper.healthObjectFromRecord(record) else {XCTFail("The method should only return nil, when the record type is unknown"); return}
                
                // Assert
                it("should correctly transscribe the values") {
                    expect(obj.value).to(equal(123.0))
                    expect(obj.date).to(equal(date))
                }
                
            }
            
            describe("editing the error message") {
                
                // Arrange
                let error = "This is some <rather unneccessary> interesting information"
                
                // Act
                let msg = Helper.editErrorMessage(error)
                
                // Assert
                it("should only return the relevant information") {
                    expect(msg).to(equal("This is some interesting information"))
                }
                
            }
            
            describe("testing the array extensions `total` and `sum`") {
                
                // Arrange
                let a = 1
                let b = 2
                let c = 3
                let d = 4
                let array = [a, b, c, d]
                
                // Act
                let total = array.total
                let average = array.average
                
                // Assert
                it("should make the same result") {
                    expect(total).to(equal((a + b + c + d)))
                    expect(average).to(equal(2.5))
                }
                
            }
            
            describe("testing the date extension") {
                
                // Arrange
                let components = NSDateComponents()
                components.day = 31
                let date =  NSCalendar.currentCalendar().dateFromComponents(components)
                
                // Act
                let day = date?.day
                
                // Assert
                it("should get the day from the date") {
                    expect(day).to(equal(31))
                }
            }
        }
    }
}
