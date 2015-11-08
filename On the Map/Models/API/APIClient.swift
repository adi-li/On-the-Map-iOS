//
//  APIClient.swift
//  On the Map
//
//  Created by Adi Li on 25/10/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import UIKit

class APIClient: NSObject {
    
    var session = NSURLSession.sharedSession()

    // dummy URL, should be overwirte by sub class
    class var BaseURL: NSURL { return NSURL(string: "http://www.example.com")! }
        
    // MARK: - Creat tasks
    
    func taskForMethod(method: Method, endpoint: String, parameters: [String: AnyObject]?, completion: CompletionHandler?) -> NSURLSessionTask? {
        
        // Build the URL for request
        guard let URL = NSURL(string: endpoint, relativeToURL: self.dynamicType.BaseURL) else {
            completion?(data: nil, error: NSError(domain: self.dynamicType.ErrorDomain, code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Invalid URL with \(endpoint) relative to \(self.dynamicType.BaseURL)"]))
            return nil
        }
        
        // Build the request with details
        let request: NSURLRequest
        do {
            try request = requestWithURL(URL, parameters: parameters ?? [String: AnyObject](), method: method)
        } catch let error {
            completion?(data: nil, error: error as NSError)
            return nil
        }
        
        // Create data task
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            // Hide network activity indicator if no task is pending
            self.session.getAllTasksWithCompletionHandler({ (tasks) -> Void in
                if tasks.count == 0 {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            })
            
            // Error handle
            if error != nil {
                completion?(data: nil, error: error)
                return
            }
            
            // Parse data into JSON object
            let parsedData: AnyObject
            do {
                try parsedData = self.parseData(data!)
            } catch let error {
                // Parsing error
                completion?(data: nil, error: NSError(domain: self.dynamicType.ErrorDomain, code: -2, userInfo: [
                    NSLocalizedDescriptionKey: "Cannot parse response data into JSON",
                    NSUnderlyingErrorKey: error as NSError,
                    "Response": response!
                ]))
                return
            }
            
            // Non success response
            if let HTTPResponse = response as? NSHTTPURLResponse {
                if HTTPResponse.statusCode < 200 || HTTPResponse.statusCode > 299 {
                    completion?(data: nil, error: NSError(domain: self.dynamicType.ErrorDomain, code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "Non success response",
                        "Response": HTTPResponse,
                        "Data": parsedData,
                    ]))
                    return
                }
            }
            
            // Call back the completion
            completion?(data: parsedData, error: nil)
        }
        
        // Show network activity indicator and start the task
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        task.resume()

        return task
    }
    
    // Short-hand for GET request
    func taskForGET(endpoint: String, parameters: [String: AnyObject]?, completion: CompletionHandler?) -> NSURLSessionTask? {
        return taskForMethod(.GET, endpoint: endpoint, parameters: parameters, completion: completion)
    }
    
    // Short-hand for POST request
    func taskForPOST(endpoint: String, parameters: [String: AnyObject]?, completion: CompletionHandler?) -> NSURLSessionTask? {
        return taskForMethod(.POST, endpoint: endpoint, parameters: parameters, completion: completion)
    }
    
    // Short-hand for PUT request
    func taskForPUT(endpoint: String, parameters: [String: AnyObject]?, completion: CompletionHandler?) -> NSURLSessionTask? {
        return taskForMethod(.PUT, endpoint: endpoint, parameters: parameters, completion: completion)
    }
    
    // Short-hand for DELETE request
    func taskForDELETE(endpoint: String, parameters: [String: AnyObject]?, completion: CompletionHandler?) -> NSURLSessionTask? {
        return taskForMethod(.DELETE, endpoint: endpoint, parameters: parameters, completion: completion)
    }
    
    // Build request object
    // Throws error if it cannot build the request
    func requestWithURL(URL: NSURL, parameters: [String: AnyObject], method: Method) throws -> NSURLRequest {
        
        let request = NSMutableURLRequest(URL: URL)
        
        // Set HTTP method
        request.HTTPMethod = method.rawValue
        
        // Add addtional headers
        addAdditionalHeaderToRequest(request)
        
        // Append parameters base on which method is going to use
        switch method {
        case .GET:
            // GET method
            // Append the parameters as query items to the URL
            let finalURL = NSURLComponents(string: URL.absoluteString)!
            var items = finalURL.queryItems ?? [NSURLQueryItem]()
            for (name, value) in parameters {
                items.append(NSURLQueryItem(name: name, value: "\(value)"))
            }
            finalURL.queryItems = items
            
            // Replace the request URL
            request.URL = finalURL.URL!
            
        default:
            // Other HTTP methods
            // Serialize the parameters into JSON data,
            // And append it to the HTTPBody
            do {
                try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: [])
            } catch {
                throw NSError(domain: self.dynamicType.ErrorDomain, code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Cannot parse requst data into JSON: \(parameters)",
                ])
            }
        }
        
        // Reture the request and make it non mutable
        return request.copy() as! NSURLRequest
    }
    
    // MARK: - Overridable
    
    // Add additional Header to a request, used for subclassing
    func addAdditionalHeaderToRequest(request: NSMutableURLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("OnTheMap/1.0 (Mobile;)", forHTTPHeaderField: "User-Agent")
    }
    
    // Parse the data, may throws error if cannot be parsed
    func parseData(data: NSData) throws -> AnyObject {
        let object: AnyObject
        
        do {
            try object = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch let error {
            throw error
        }
        
        return object
    }
}
