//
//  WebConnect.swift
//  braysdkframework
//
//  Created by Dan Allan Bray Santos on 22/06/2016.
//  Copyright © 2016 Dan Allan Bray Santos. All rights reserved.
//

import Foundation
import UIKit

class WebConnect: NSObject {
    
    var responseData = NSMutableData()
    var conditionLock = NSCondition()
    var errorString = NSString()
    
    override init() {
        print("init connect")
    }
    
    func connectRequest(_ url:URL, query:Data) -> NSString{
        var result:NSString = ""
        
        conditionLock.lock()
        
        let urlReq:URL = url
        let request = NSMutableURLRequest(url: urlReq)
//        let username = "atin_to"
//        let password = "6dffd8dbd8560c405662fec842671456b48176ae"
//        let username = "admin"
//        let password = "1234"
//        let loginString = NSString (format: "%@:%@", username, password)
//        let loginData:Data = loginString.data(using: String.Encoding.utf8.rawValue)!
//        let base64LoginString = loginData.base64EncodedString(options: [])
        
        request.httpMethod = "POST"
        request.httpBody = query
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let q = DispatchQueue(label: "com.bray.santos", attributes: [])
        
        q.async(execute: {
            let conn = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
            conn!.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            conn!.start()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            CFRunLoopRun()
        })
        
        conditionLock.wait()
        conditionLock.unlock()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if query.count == 0 && errorString.length > 0 {
            let webService = WebService()
            
            webService.urlConnectionFailed(errorString)
        }
        else
        {
            result = NSMutableString.init(data: responseData as Data, encoding: String.Encoding.utf8.rawValue)!
        }
        
        return result
    }
    
    func connectRequestGet(_ url:URL) -> NSString{
        var result:NSString = ""
        
        conditionLock.lock()
        
        let urlReq:URL = url
        let request = NSMutableURLRequest(url: urlReq)
//        let username = "atin_to"
//        let password = "6dffd8dbd8560c405662fec842671456b48176ae"
//        let username = "admin"
//        let password = "1234"
//        let loginString = NSString (format: "%@:%@", username, password)
//        let loginData:Data = loginString.data(using: String.Encoding.utf8.rawValue)!
//        let base64LoginString = loginData.base64EncodedString(options: [])
        
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let q = DispatchQueue(label: "com.bray.santos", attributes: [])
        
        q.async(execute: {
            let conn = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
            conn!.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            conn!.start()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            CFRunLoopRun()
        })
        
        conditionLock.wait()
        conditionLock.unlock()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if errorString.length > 0 {
            let webService = WebService()
            
            webService.urlConnectionFailed(errorString)
        }
        else
        {
            result = NSMutableString.init(data: responseData as Data, encoding: String.Encoding.utf8.rawValue)!
        }
        
        return result
    }
    
    func connectRequestDeleteWithParams(_ url:URL, query:Data) -> NSString{
        var result:NSString = ""
        
        conditionLock.lock()
        
        let urlReq:URL = url
        let request = NSMutableURLRequest(url: urlReq)
        //        let username = "atin_to"
        //        let password = "6dffd8dbd8560c405662fec842671456b48176ae"
        let username = "admin"
        let password = "1234"
        let loginString = NSString (format: "%@:%@", username, password)
        let loginData:Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: [])
        
        request.httpMethod = "DELETE"
        request.httpBody = query
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let q = DispatchQueue(label: "com.bray.santos", attributes: [])
        
        q.async(execute: {
            let conn = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
            conn!.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            conn!.start()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            CFRunLoopRun()
        })
        
        conditionLock.wait()
        conditionLock.unlock()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if query.count == 0 && errorString.length > 0 {
            let webService = WebService()
            
            webService.urlConnectionFailed(errorString)
        }
        else
        {
            result = NSMutableString.init(data: responseData as Data, encoding: String.Encoding.utf8.rawValue)!
        }
        
        return result
    }
    
    func connectRequestDelete(_ url:URL) -> NSString{
        var result:NSString = ""
        
        conditionLock.lock()
        
        let urlReq:URL = url
        let request = NSMutableURLRequest(url: urlReq)
        //        let username = "atin_to"
        //        let password = "6dffd8dbd8560c405662fec842671456b48176ae"
        let username = "admin"
        let password = "1234"
        let loginString = NSString (format: "%@:%@", username, password)
        let loginData:Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: [])
        
        request.httpMethod = "DELETE"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let q = DispatchQueue(label: "com.bray.santos", attributes: [])
        
        q.async(execute: {
            let conn = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
            conn!.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            conn!.start()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            CFRunLoopRun()
        })
        
        conditionLock.wait()
        conditionLock.unlock()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if errorString.length > 0 {
            let webService = WebService()
            
            webService.urlConnectionFailed(errorString)
        }
        else
        {
            result = NSMutableString.init(data: responseData as Data, encoding: String.Encoding.utf8.rawValue)!
        }
        
        return result
    }
    
    func connection(_ didReceiveResponse: NSURLConnection!, didReceiveResponse response: URLResponse!) {
        print("didReceiveResponse")
    }
    
    func connection(_ connection: NSURLConnection!, didReceiveData conData: Data!) {
        print("didReceiveData")
        responseData.append(conData)
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection!) {
        print("connectionDidFinishLoading")
        
        conditionLock.lock()
        conditionLock.signal()
        conditionLock.unlock()
        
        CFRunLoopStop(CFRunLoopGetCurrent())
    }
    
    func connection(_ connection: NSURLConnection!, dicReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge!) {
        
    }
    
    func connection(_ connection: NSURLConnection!, didFailWithError error:NSError) {
        
        if errorString.length <= 0 {
            errorString = "Network Error – Please try again while ensuring a strong network signal"
            print(errorString)
        }
        
        conditionLock.lock()
        conditionLock.signal()
        conditionLock.unlock()
        
        CFRunLoopStop(CFRunLoopGetCurrent())
    }
    
    deinit {
        print("deiniting")
    }
    
}
