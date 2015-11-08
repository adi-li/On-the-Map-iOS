//
//  APIConstants.swift
//  On the Map
//
//  Created by Adi Li on 25/10/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation

extension APIClient {
    
    typealias CompletionHandler = (data: AnyObject?, error: NSError?) -> Void
    
    enum Method: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    class var ErrorDomain: String { return "APIClientDomain" }
}
