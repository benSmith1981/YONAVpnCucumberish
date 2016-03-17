//
//  VPNSingleton.swift
//  YonaTest
//
//  Created by Ben Smith on 17/03/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//
import NetworkExtension
import UIKit

public class VPNSingleton:NSObject{
    var manager:NEVPNManager!
    public    var started = false
    public static let sharedInstance = VPNSingleton()
    
    private override init() {}
    
    
    func startVPN (){
        self.manager = NEVPNManager.sharedManager()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "vpnConnectionStatusChanged",
            name: NEVPNStatusDidChangeNotification,
            object: self)
    }
    
    func vpnConnectionStatusChanged(notification: NSNotification){
        //Take Action on Notification
        started = true
//        let alertView = UIAlertController(title: "VPN Change", message: "\(notification.description)" , preferredStyle: UIAlertControllerStyle.Alert)
//        self.presentViewController(alertView, animated: true, completion: nil)
    }
}