//
//  EVReflectionMapping.swift
//  EVReflection
//
//  Created by Edwin Vermeer on 11/21/15.
//  Copyright © 2015 evict. All rights reserved.
//
import XCTest
@testable import EVReflection

/**
 Testing EVReflection
 */
class EVReflectionMappingTests: XCTestCase {
    
    /**
     For now nothing to setUp
     */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(TestObject.self)
    }
    
    /**
     For now nothing to tearDown
     */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
     Get the string name for a clase and then generate a class based on that string
     */
    func testSimpleMapping() {
        let player = GamePlayer()
        player.name = "It's Me"
        player.memberSince = Date()
        player.gamesPlayed = 123
        player.rating = 76
        
        NSLog("\n\n===> This will output a warning because GameAdministrator does not have the propery gamesPlayed")
        let administrator: GameAdministrator = player.mapObjectTo()
        
        let administrator2 = GameAdministrator(usingValuesFrom: player)
        
        // Remember that printing will use the property converter and multiply the administrator level with 4. So it will print the same as the player.
        NSLog("player = \(player)")
        NSLog("administrator = \(administrator)")
        NSLog("administrator2 = \(administrator2)")

        XCTAssertEqual(administrator.name, player.name, "The names should be the same")
        XCTAssertEqual(administrator.memberSince, player.memberSince, "The member since dates should be the same.")
        XCTAssertEqual(administrator.level, 19, "When creatinga an administrator, it's level should be a quarter of the player's rating")
    }
    
    func testNonmatchingPropertyTypeInDictionarySilentlySkipsPropertySettingWithoutThrowingAnError() {
        
        let name = "It's Me"
        let gamesPlayed = 42
        
        let json = "{ \"name\": \"\(name)\", \"objectIsNotAValue\": \"shouldBeObject\", \"memberSince\": \"NoDate\", \"gamesPlayed\": \(gamesPlayed)," +
                      "\"rating\": {\"score\": 111, \"rank\": 122 } }"
        print("==> You will now get 2 warnings. (rating should be a number but we are getting an object and aa is not a date)")
        let player = GamePlayer(json: json)
        XCTAssertEqual(player.name, name)
        XCTAssertEqual(player.gamesPlayed, gamesPlayed)
        
        XCTAssertNil(player.memberSince)
        XCTAssertEqual(player.rating, 0)
    }
    
    func testValidationFunction() {
        let user = GameUser(json: "{\"name\":\"Yo\"}")
        XCTAssertNil(user.name, "Name should not have been set to Yo")
        let user2 = GameUser(json: "{\"name\":\"Yol\"}")
        XCTAssertEqual(user2.name, "Yol", "Name should have been set to Yol")
    }
}

enum MyValidationError: Error {
    case typeError,
    lengthError
}

open class GameUser: EVObject {
    var name: String?
    var memberSince: Date?
    var objectIsNotAValue: TestObject?
    
    func validateName(_ value: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        if let theValue = value.pointee as? String {
            if theValue.lengthOfBytes(using: String.Encoding.utf8) < 3 {
                NSLog("Validating name is not long enough \(theValue)")
                throw MyValidationError.lengthError
            }
            NSLog("Validating name OK: \(theValue)")
        } else {
            NSLog("Validating name is not a string: \(value.pointee.debugDescription )")
            throw MyValidationError.typeError
        }
    }
}

open class GamePlayer: GameUser {
    var gamesPlayed: Int = 0
    var rating: Int = 0

    // This way we can solve that the JSON has arbitrary keys or wrong values
    override open func setValue(_ value: Any!, forUndefinedKey key: String) {
        NSLog("---> setValue for key '\(key)' should be handled or the value is of the wrong type: \(value).")
    }
}

open class GameAdministrator: GameUser {
    var usersBanned: Int = 0
    var level: Int = 0
    
    override open func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "level", keyInResource: "rating")]
    }

    override open func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            ( // We want a custom converter for the field isGreat
                key: "level",
                // isGreat will be true if the json says 'Sure'
                decodeConverter: { self.level = ((($0 as? Int) ?? 0) / 4) },
                // The json will say 'Sure  if isGreat is true, otherwise it will say 'Nah'
                encodeConverter: {
                    return self.level * 4
            })]
    }
}
