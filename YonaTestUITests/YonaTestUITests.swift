//
//  YonaTestUITests.swift
//  YonaTestUITests
//
//  Created by Ben Smith on 17/03/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import XCTest
import YonaTest
class YonaInitializer: NSObject {
    class func YonaSwiftInit()
    {
        var application : XCUIApplication!
        //A closure that will be executed just before executing any of your features
        beforeStart { () -> Void in
            application = XCUIApplication()
        }
        //A Given step definition
        Given("the VPN has not started") { (args, userInfo) -> Void in
            application.launch()
        }
        //Another step definition
        When("I press the button") { (args, userInfo) -> Void in
            application.buttons["VPNButton"].tap()
        }
        
        Then("the VPN will start") { (args, userInfo) -> Void in
//            CCISAssert(VPNSingleton.sharedInstance.started, "VPN not started") //if what happens upon failure
        }
        //Tell Cucumberish the name of your features folder and let it execute them for you...
        Cucumberish.instance().fixMissingLastScenario = true
        Cucumberish.instance().prettyNamesAllowed = true
        Cucumberish.executeFeaturesInDirectory("Features", featureTags: nil)
    }
}