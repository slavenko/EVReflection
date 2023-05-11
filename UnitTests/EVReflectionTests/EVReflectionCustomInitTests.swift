//
//  EVReflectionCustomInitTests.swift
//  EVReflection
//
//  Created by Joshua Greene on 4/8/16.
//  Copyright © 2016 evict. All rights reserved.
//

import XCTest
@testable import EVReflection


class EVReflectionCustomInitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        EVReflection.setBundleIdentifier(TestObject.self)
    }
    
    func testConvenienceInitSetsPropertyValue() {
        
        // given
        let expectedValue = 42
        let dictionary = ["number": expectedValue]
        
        // when
        let object = CustomPropertyClass(dictionary: dictionary as NSDictionary)
        
        // then
        XCTAssertEqual(object.number, expectedValue)
    }
}

open class CustomPropertyClass: EVObject {
    
    open var number: Int
    
    /*  
     Note: `init` is the _only_ required initializer inherited from `EVObject`.
     By overriding it, you also get access to _all_ of its convenience initializers, for free!
        
     If you _don't_ want `init` to be called directly on your subclass, you can also use Swift's
     `@available` attribute to "deprecate" it, which will produce a warning message if it's
      used directly but _not_ if a convenience initializer is used. ;)
    */
    @available(*, deprecated, message: "init isn't supported, use init(number:) instead")
    public required init() {
        number = 0
        super.init()
    }
    
    public init(number: Int) {
        self.number = number
        super.init()
    }
}
