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
        VPNSingleton.sharedInstance.manager.loadFromPreferencesWithCompletionHandler { (NSError) -> Void in
            let newIPSec = NEVPNProtocolIKEv2()
            let password = "pw";
            newIPSec.username = "test"
            newIPSec.passwordReference = password.dataUsingEncoding(NSUTF8StringEncoding)
            newIPSec.serverAddress = "proxy.yona.nu"
            newIPSec.disconnectOnSleep = false
            newIPSec.useExtendedAuthentication = true
            newIPSec.authenticationMethod = NEVPNIKEAuthenticationMethod.SharedSecret
            let connectRule = NEOnDemandRuleConnect()
            connectRule.interfaceTypeMatch = .Any
            
            VPNSingleton.sharedInstance.manager.onDemandRules = [connectRule]
            VPNSingleton.sharedInstance.manager.`protocolConfiguration` = newIPSec
            VPNSingleton.sharedInstance.manager.enabled = true
            VPNSingleton.sharedInstance.manager.saveToPreferencesWithCompletionHandler({ (error) -> Void in
                print(error)
            })
            let url = NSURLRequest(URL: NSURL(string: "https://www.google.com")!)
            self.webView.loadRequest(url)
        }
        
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
