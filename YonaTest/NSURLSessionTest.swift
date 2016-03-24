//
//  ConfigServer.swift
//  YonaTest
//
//  Created by Ben Smith on 23/03/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
class NSURLSessionTest {
    
    func getConfigCertificate()
    {
        //create a NSURL
        let url:NSURL = NSURL(string: "http://localhost:8888/YonaVPNTest.mobileconfig")!
        //create a session
        let session = NSURLSession.sharedSession()
        
        //create the request
        let request = NSMutableURLRequest(URL:url)
        request.HTTPMethod = "GET"
        // set cache polict to ignore cache data
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let task = session.downloadTaskWithRequest(request) {
            (let location, let response, let error) in
            
            guard let _:NSURL = location, let _:NSURLResponse = response where error == nil else {
                print("error")
                return
            }
            
            let urlContents = try! NSString(contentsOfURL: location!, encoding: NSUTF8StringEncoding)
            
            guard let _:NSString = urlContents else {
                print("error")
                return
            }
            
            print(urlContents)
        }
        task.resume()
    }
}