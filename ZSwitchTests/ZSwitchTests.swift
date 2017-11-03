//
//  ZSwitchTests.swift
//  ZSwitchTests
//
//  Created by zhangshibo on 10/25/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import XCTest

class ZSwitchTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testReorderAppByDistance() {
        let appModels = ["app1", "app2", "app3"]
        let newModels = appModels.sorted { (a, b) -> Bool in
            a.lcsDistance("2") < b.lcsDistance("2")
        }
        for (index, app) in appModels.enumerated() {
             XCTAssertEqual(app, appModels[index])
        }
        
        XCTAssertEqual("app2", newModels[0])
        XCTAssertEqual("app1", newModels[1])
        XCTAssertEqual("app3", newModels[2])

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

