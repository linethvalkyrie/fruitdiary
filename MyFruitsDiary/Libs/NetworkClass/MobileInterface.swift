//
//  TMNInterface.swift
//  tmnsdkframework
//
//  Created by Dan Allan Bray Santos on 22/06/2016.
//  Copyright © 2016 Dan Allan Bray Santos. All rights reserved.
//

import Foundation

open class MobileInterface {
    
    public init () { }
    
    let webService = WebService()
    
    open func getDataFromTask(_ paramsDic : NSMutableDictionary) -> NSDictionary {
        
        let jsonData:Data = webService.manageMobileRequest(paramsDic)
        var jsonDic:NSDictionary = NSDictionary()
//        var jsonArray:NSArray = NSArray()
    
        do {
            jsonDic = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
        } catch let error as NSError {
            print(error)
        }
        
        
        return jsonDic
    }
    
    open func getDataFromTaskOnly(_ task:NSString) -> NSArray {
        
        let jsonData:Data = webService.manageMobileRequestTaskOnly(task)
//        var jsonDic:NSDictionary = NSDictionary()
        var jsonArray:NSArray = NSArray()
        
        do {
            jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSArray
        } catch let error as NSError {
            print(error)
        }
        
        
        return jsonArray
    }
    
    open func deleteDataFromTaskOnly(_ task:NSString) ->NSDictionary {
        let jsonData:Data = webService.deleteEntryRequest(task)
        var jsonDic:NSDictionary = NSDictionary()
//        var jsonArray:NSArray = NSArray()
        
        do {
            jsonDic = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
        } catch let error as NSError {
            print(error)
        }
        
        return jsonDic
    }
    
    open func deleteDataWithParams(_ paramsDic : NSMutableDictionary) -> NSArray {
        
        let jsonData:Data = webService.deleteEntryRequestWithParams(paramsDic)
//        var jsonDic:NSDictionary = NSDictionary()
        var jsonArray:NSArray = NSArray()
        
        do {
            jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSArray
        } catch let error as NSError {
            print(error)
        }
        
        
        return jsonArray
    }

}
