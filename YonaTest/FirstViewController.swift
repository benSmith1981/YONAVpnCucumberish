//
//  FirstViewController.swift
//  YonaTest
//
//  Created by Ben Smith on 17/03/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import UIKit
import NetworkExtension
import AlamofireJsonToObjects
import Alamofire
import Swifter

class FirstViewController: UIViewController, UITableViewDelegate {
    
    var matchComment: String = "https://feeds.tribehive.co.uk/DigitalStadiumServer/opta?pageType=matchCommentary&value=803294&v=2"
    var matchStats: String = "https://feeds.tribehive.co.uk/DigitalStadiumServer/opta?pageType=match&value=803294&v=2"
    var arrCommentary:[Commentary]? //Array of dictionary
    
    @IBOutlet var tblJSON: UITableView!
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startVPN(sender: AnyObject) {
        //LOAD VPN CERT with SAFARI, WON"T COME BACK TO APP THOUGH!
//        if let requestUrl = NSURL(string: "http://localhost:8888/YonaVPNTest.mobileconfig") {
//            UIApplication.sharedApplication().openURL(requestUrl)
//        }
        
        //LOAD VPN WITH HTTPSERVER, BEST SOLUTION IF I CAN MAKE IT WORK AS IT COMES BACK TO THE APP USING NSURL SCHEME
        //let url:NSURL = NSURL(string: "http://localhost:8888/YonaVPNTest.mobileconfig")!
        let path = NSBundle.mainBundle().pathForResource("YonaVPNTest", ofType: "mobileconfig")
        do {
            let mobileConfigData = try NSData(contentsOfFile: path!, options: NSDataReadingOptions())
            let server: ConfigServer = ConfigServer(configData: mobileConfigData, returnURL: "YonaTest://")
            server.start()
        } catch{}

        
        //Load VPN with networking, NOT WHAT WE NEED FOR YONA
//        VPNSingleton.sharedInstance.manager.loadFromPreferencesWithCompletionHandler { (NSError) -> Void in
//            let newIPSec = NEVPNProtocolIKEv2()
//            let password = "pw";
//            newIPSec.username = "test"
//            newIPSec.passwordReference = password.dataUsingEncoding(NSUTF8StringEncoding)
//            newIPSec.serverAddress = "proxy.yona.nu"
//            newIPSec.disconnectOnSleep = false
//            newIPSec.useExtendedAuthentication = true
//            newIPSec.authenticationMethod = NEVPNIKEAuthenticationMethod.SharedSecret
//            let connectRule = NEOnDemandRuleConnect()
//            connectRule.interfaceTypeMatch = .Any
//            
//            VPNSingleton.sharedInstance.manager.onDemandRules = [connectRule]
//            VPNSingleton.sharedInstance.manager.`protocolConfiguration` = newIPSec
//            VPNSingleton.sharedInstance.manager.enabled = true
//            VPNSingleton.sharedInstance.manager.saveToPreferencesWithCompletionHandler({ (error) -> Void in
//                print(error)
//            })
//            let url = NSURLRequest(URL: NSURL(string: "https://www.google.com")!)
//            self.webView.loadRequest(url)
//        }
        
    }
    
    @IBAction func downloadParseJSON(sender: AnyObject) {
        
        Alamofire.request(.GET, matchComment,parameters:["pageType": "matchCommentary", "value": "803294&v=2"]).responseArray
            {(request: NSURLRequest?,
                HTTPURLResponse: NSHTTPURLResponse?,
                response: Result<[Commentary], NSError>) -> Void in
                
                if let result = response.value {
                    self.arrCommentary = result
                    self.tblJSON.reloadData()
                }
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        let comment = arrCommentary![indexPath.row]
        cell.textLabel?.text = comment.heading
        cell.detailTextLabel?.text = comment.commentDescription
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrCommentary?.count >= 0 {
            return self.arrCommentary!.count
        }
        else {
            return 0
        }
    }
}
