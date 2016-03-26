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

class HealthPadTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHelper_updateLoader_shouldChangeText() {
        
        // Arrange
        let app = UIApplication.sharedApplication()
        let vc = app.keyWindow?.rootViewController
        let loader = Loader.showLoader(vc!)
        
        // Act
        Helper.update(loader, s: "This is a test!")
        
        // Assert
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            expect(loader.label?.text).to(equal("This is a test!"))
        }
        
    }
    
    func testHelper_saveRecord_shouldNotFail() {
        // TODO
    }
    
    func testHelper_fetchData_shouldReturnCorrectData() {
        // TODO
    }
    
    func testHelper_daysFromRecords_shouldReturnValidDaysObjects() {
        
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
            
            print("days: \(days)")
            
            // Assert
            expect(days.count).to(equal(2))
            
            days.forEach({ (day) -> () in
                expect(day.minimumValue).to(equal(10.0))
                expect(day.maximumValue).to(equal(20.0))
                expect(day.all?.count).to(equal(2))
            })
            
            
        } else {
            XCTFail("The returned days array should not be nil")
        }
        
    }
    
    func testHelper_convertStepsRecordToHealthObject_shouldReturnValidObject() {
        
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
        expect(obj.value).to(equal(123.0))
        expect(obj.date).to(equal(date))
        
    }
    
    func testHelper_editErrorMessage_shouldOnlyReturnRelevantString() {
        
        // Arrange
        let error = "" // TODO
        
        // Act
        let msg = Helper.editErrorMessage(error)
        
        // Assert
        expect(msg).to(equal(""))  // TODO
        
    }
    
    func testHelper_createGradient_gradientShouldHaveCorrectColors() {
        // TODO (unneccessary?)
    }
    
    func testArrayExtension_totalSum_and_averageValue() {
        
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
        expect(total).to(equal((a + b + c + d)))
        expect(average).to(equal(2.5))
        
    }
    
    func testDateExtension_dayOfDate() {
        
        // Arrange
        let components = NSDateComponents()
        components.day = 31
        let date =  NSCalendar.currentCalendar().dateFromComponents(components)
        
        // Act
        let day = date?.day
        
        // Assert
        expect(day).to(equal(31))
        
    }
    
}
