//
//  Services.swift
//  SVUServiceManager
//
//  Created by Wee, David G. on 5/10/16.
//  Copyright © 2016 supervalu. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit


open class Services
{
    
    open class func callRestfulWebService(_ url:String, httpMethod:String, authHeaders:Dictionary<String, String>?, parameters:Dictionary<String, Any>?, completionBlock: ((_ resultCode:Int, _ data:AnyObject?, _ response:AnyObject?)->())?)
    {
        // if no connection return
        if !Reachability.isConnectedToNetwork()
        {
            completionBlock!(-999, nil, "No Network")
            return
        }
        
        let urlString = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let request = NSMutableURLRequest(url: urlString!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)

        print("URL Called -> \(urlString)")
        request.httpMethod = httpMethod.uppercased()
        
        // Setting parameters if any
        if let _ = authHeaders
        {
            for key in authHeaders!.keys
            {
                request.setValue(authHeaders![key], forHTTPHeaderField: key)
            }
        }
        
        // Setting parameters if any
        if let _ = parameters
        {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters!, options: .prettyPrinted)
                request.httpBody = jsonData
                SVPrint.print(s: "Parameters -> \(parameters)")
                print("Parameters -> \(parameters)")
            } catch  {
                print("JSON Serilization failed")
                return
            }
        }
        
        
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.urlCache = URLCache.shared
        config.requestCachePolicy = .reloadRevalidatingCacheData
        
        let session = URLSession(configuration: config)
        let sesisionTask = session.dataTask(with: request as URLRequest, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in

            print("Response: \((response as? HTTPURLResponse)?.statusCode) code, \n repsonse: \(response)")
            if let _ = completionBlock
            {
                    completionBlock!((response as? HTTPURLResponse).statusCode, data, response)
            }
        })
        sesisionTask.resume()
    }
    

    open class func basicAuth(username:String, password:String) -> String
    {
        let loginString = String(format: "%@:%@", username, password)
        let loginData : Data = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString(options: .lineLength76Characters)
        return "Basic \(base64LoginString)"
    }
    
    
}


public class Reachability {
    
    class func isConnectedToNetwork() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}


