//
//  TMNWebService.swift
//  tmnsdkframework
//
//  Created by Dan Allan Bray Santos on 22/06/2016.
//  Copyright © 2016 Dan Allan Bray Santos. All rights reserved.
//

import Foundation

class WebService: NSObject {
    
    var mobileService = "api/";
    var serverUrl = "https://fruitdiary.test.themobilelife.com/";
    var errorMsg = NSString()
    var webConnect = WebConnect()
    
    override init () {
        print("init webservice")
    }
    
    func manageMobileRequest(_ paramsDic:NSMutableDictionary) -> Data {
        var result:NSString = ""
        let urlString:NSString = NSString.init(format: "%@%@%@", self.serverUrl, self.mobileService, paramsDic.value(forKey: "task") as! String)
        
//        print(urlString)
        
        paramsDic.removeObject(forKey: "task")
        
//        print(urlString)
        
        let url:URL = URL(string:urlString as String)!
        
//        print(paramsDic)
        
        let query:Data = convertToJsonQuery(paramsDic)
        
//        print(query)
        
        result = webConnect.connectRequest(url, query: query)
        
//        result = result.stringByReplacingOccurrencesOfString("\\", withString: "")
//        result = result.stringByReplacingOccurrencesOfString("\"[", withString: "[")
//        result = result.stringByReplacingOccurrencesOfString("]\"", withString: "]")
        
//        print(result)
        
//        result = result.substringWithRange(NSMakeRange(1, result.length-2))
        
        return result.data(using: String.Encoding.utf8.rawValue)!
    }
    
    func manageMobileRequestTaskOnly(_ task:NSString) -> Data {
        var result:NSString = ""
        let urlString:NSString = NSString.init(format: "%@%@%@", self.serverUrl, self.mobileService, task)
        
//        print(urlString)
        
        //        paramsDic.removeObject(forKey: "task")
        
//        print(urlString)
        
        let url:URL = URL(string:urlString as String)!
        
        result = webConnect.connectRequestGet(url)
        
        //        result = result.stringByReplacingOccurrencesOfString("\\", withString: "")
        //        result = result.stringByReplacingOccurrencesOfString("\"[", withString: "[")
        //        result = result.stringByReplacingOccurrencesOfString("]\"", withString: "]")
        
//        print(result)
        
        //        result = result.substringWithRange(NSMakeRange(1, result.length-2))
        
        return result.data(using: String.Encoding.utf8.rawValue)!
    }
    
    func deleteEntryRequest(_ task:NSString) ->Data {
        var result:NSString = ""
        let urlString:NSString = NSString.init(format: "%@%@%@", self.serverUrl, self.mobileService, task)
        
//        print(urlString)
        
        //        paramsDic.removeObject(forKey: "task")
        
//        print(urlString)
        
        let url:URL = URL(string:urlString as String)!
        
        result = webConnect.connectRequestDelete(url)
        
        //        result = result.stringByReplacingOccurrencesOfString("\\", withString: "")
        //        result = result.stringByReplacingOccurrencesOfString("\"[", withString: "[")
        //        result = result.stringByReplacingOccurrencesOfString("]\"", withString: "]")
        
//        print(result)
        
        //        result = result.substringWithRange(NSMakeRange(1, result.length-2))
        
        return result.data(using: String.Encoding.utf8.rawValue)!
    }
    
    func deleteEntryRequestWithParams(_ paramsDic:NSMutableDictionary) -> Data {
        var result:NSString = ""
        let urlString:NSString = NSString.init(format: "%@%@%@", self.serverUrl, self.mobileService, paramsDic.value(forKey: "task") as! String)
        
//        print(urlString)
        
        //        paramsDic.removeObject(forKey: "task")
        
//        print(urlString)
        
        let url:URL = URL(string:urlString as String)!
        
        let query:Data = convertToJsonQuery(paramsDic)
        
        result = webConnect.connectRequestDeleteWithParams(url, query: query)
        
        //        result = result.stringByReplacingOccurrencesOfString("\\", withString: "")
        //        result = result.stringByReplacingOccurrencesOfString("\"[", withString: "[")
        //        result = result.stringByReplacingOccurrencesOfString("]\"", withString: "]")
        
//        print(result)
        
        //        result = result.substringWithRange(NSMakeRange(1, result.length-2))
        
        return result.data(using: String.Encoding.utf8.rawValue)!
    }
    
    func urlConnectionFailed(_ error:NSString) {
        errorMsg = error
    }
    
    func convertToJsonQuery(_ params:NSMutableDictionary) -> Data {
        var jsonData:Data = Data()
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch let error as NSError {
            print(error)
        }
        
        return jsonData
    }
}
