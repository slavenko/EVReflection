//
//  Issue4Test.swift
//  AlamofireXmlToObjects
//
//  Created by Edwin Vermeer on 8/4/16.
//  Copyright © 2016 evict. All rights reserved.
//


import XCTest
import Alamofire
import XMLDictionary
import EVReflection


class XmlResponse: EVObject {
    var __name: String?
    var qlist: [QList]?
}

class QList: EVObject {
    var piname: String?
    var picell: String?
    var rinum: String?
    var rifunt: String?
    var ridatr: String?
    var riapt: String?
    var riacft: String?
    var rifbo: String?
    var dev: String?
    var rifuel: String?
    var riftyp: String?
    var pihome: String?
}



class Issue4Test: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(JDBOR.self)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    func testIssue() {
        // This is an example of a functional test case.
        let URL: URLConvertible = "http://raw.githubusercontent.com/evermeer/AlamofireXmlToObjects/master/AlamofireXmlToObjectsTests/Issue4_xml"
        let expectation = self.expectation(description: "\(URL)")

        Alamofire.request(URL)
            .responseObjectFromXML { (response: DataResponse<XmlResponse>) in
                if let error = response.result.error {
                    XCTAssert(false, "ERROR: \(error.localizedDescription)")
                } else {
                    if let result = response.result.value {
                        print("\(result.description)")

                    } else {
                        XCTAssert(false, "no result from service")
                    }
                }
                expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error, "\(error?.localizedDescription ?? "")")
        }
    }
}
