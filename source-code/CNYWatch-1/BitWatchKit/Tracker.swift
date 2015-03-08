//
//  Tracker.swift
//  BitWatch
//
//  Created by Mic Pringle on 19/11/2014.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import Foundation

public typealias PriceRequestCompletionBlock = (price: NSNumber?, error: NSError?) -> ()

public class Tracker {
  
  let defaults = NSUserDefaults.standardUserDefaults()
  let session: NSURLSession
  let URL = "http://api.k780.com:88/?app=finance.rate&scur=USD&tcur=CNY&appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4&format=json"
  
  public class var dateFormatter: NSDateFormatter {
    struct DateFormatter {
      static var token: dispatch_once_t = 0
      static var instance: NSDateFormatter? = nil
    }
    dispatch_once(&DateFormatter.token) {
      let formatter = NSDateFormatter()
      formatter.dateFormat = "HH:mm"
      DateFormatter.instance = formatter;
    }
    return DateFormatter.instance!
  }
  
  public class var priceFormatter: NSNumberFormatter {
    struct PriceFormatter {
      static var token: dispatch_once_t = 0
      static var instance: NSNumberFormatter? = nil
    }
    dispatch_once(&PriceFormatter.token) {
      let formatter = NSNumberFormatter()
      formatter.currencyCode = "CNY"
      formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
      PriceFormatter.instance = formatter
    }
    return PriceFormatter.instance!
  }
  
  public init() {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    session = NSURLSession(configuration: configuration);
  }
  
  public func cachedDate() -> NSDate {
    if let date = defaults.objectForKey("date") as? NSDate {
      return date
    }
    return NSDate()
  }
  
  public func cachedPrice() -> NSNumber {
    if let price = defaults.objectForKey("price") as? NSNumber {
      return price
    }
    return NSNumber(double: 0.00)
  }
  
  public func requestPrice(completion: PriceRequestCompletionBlock) {
    let request = NSURLRequest(URL: NSURL(string: URL)!)
    let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
      if error == nil {
        var JSONError: NSError?
        let responseDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &JSONError) as NSDictionary
        if JSONError == nil {
          let result = responseDict["result"] as NSDictionary
            let priceStr = result["rate"] as NSString
            let price = NSNumber(double: priceStr.doubleValue)
            
          self.defaults.setObject(price, forKey: "price")
          self.defaults.setObject(NSDate(), forKey: "date")
          self.defaults.synchronize()
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(price: price, error: nil)
          })
        } else {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(price: nil, error: JSONError)
          })
        }
      } else {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          completion(price: nil, error: error)
        })
      }
    })
    task.resume()
  }
  
}