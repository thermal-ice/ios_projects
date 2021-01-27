//
//  Actual_foodtrackerTests.swift
//  Actual_foodtrackerTests
//
//  Created by Carlos Huang on 2020-04-05.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import XCTest
@testable import Actual_foodtracker

class Actual_foodtrackerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //MARK: Meal Class tests
    
    //confirms tht Meal iniialier returns a Meal object when passed valid paramters
    
    func testMealInitializationSucceeds(){
        //Zero case
        
        let zeroRatingMeal = Meal.init(name: "Zero", photo: nil, rating: 0)
        XCTAssertNotNil(zeroRatingMeal != nil)
        
        let positiveRatingMeal = Meal.init(name: "Positive", photo: nil, rating: 5)

        XCTAssertNotNil(positiveRatingMeal)
        
        
        
        
    }
    
    func testMealInitializationFails(){
        
        let negativeRatingMeal = Meal.init(name: "Negative", photo: nil, rating: -1)
        
        XCTAssertNil(negativeRatingMeal)
        
        let emptyStringMeal = Meal.init(name: "", photo: nil, rating: 0)
        
        XCTAssertNil(emptyStringMeal)
        
        let ratingExceededMeal = Meal.init(name: "Large", photo: nil, rating: 6)
        
        XCTAssertNil(ratingExceededMeal)
    }

}
