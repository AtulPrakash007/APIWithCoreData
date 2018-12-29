//
//  Request.swift
//  APIWithCoreData
//
//  Created by Atul on 28/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import Foundation
import UIKit

class Request: NSObject {
    static let sharedInstance = Request()
    
    func request(url:String, method: String, params: [String: String], completion: @escaping ([String: Any]?, Error?)->() ){
        if let nsURL = URL(string:url) {
            let request = NSMutableURLRequest(url: nsURL as URL)
            var postString:String = ""
            if method == "POST" {
                // convert key, value pairs into param string
                postString = params.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
                let postData = postString.data(using: .ascii, allowLossyConversion: true)
                let postLength = String(postData!.count)
                request.httpMethod = "POST"
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                request.httpBody = postData
                //                request.setValue("text/json; oe=utf-8", forHTTPHeaderField: "Accept")
                request.setValue(postLength, forHTTPHeaderField: "Content-Length")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
            print("Url: \(nsURL) & param: \(postString)")
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                (data, response, error) in
                do {
                    
                    // what happens if error is not nil?
                    // That means something went wrong.
                    // Make sure there really is some data
                    if let data = data {
//                        let datastring = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//                        print(datastring ?? "default value")
//                        var jsonResultDic:NSDictionary  = [String:AnyObject]() as NSDictionary
                        let jsonResultDic = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: Any]
                        
                        completion(jsonResultDic, nil)
                    }
                    else {
                        print("Data is nil") //pass data as nil or notification of failure
                        completion([:], error)
                    }
                } catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                    completion([:], error)
                }
            }
            task.resume()
        }
        else{
            // Could not make url. Is the url bad?
            // You could call the completion handler (callback) here with some value indicating an error
        }
    }
}

