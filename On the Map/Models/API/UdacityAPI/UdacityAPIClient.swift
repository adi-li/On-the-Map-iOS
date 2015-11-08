//
//  UdacityAPIClient.swift
//  On the Map
//
//  Created by Adi Li on 25/10/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation

class UdacityAPIClient: APIClient {
    
    static let client = UdacityAPIClient()
    
    override class var BaseURL: NSURL { return NSURL(string: "https://www.udacity.com/api/")! }
    override class var ErrorDomain: String { return "UdacityAPIClientDomain" }
    
    // Override addAdditionalHeaderToRequest
    override func addAdditionalHeaderToRequest(request: NSMutableURLRequest) {
        super.addAdditionalHeaderToRequest(request)
        
        // Add XSRF token to Header if it exists
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        guard let cookies = sharedCookieStorage.cookies else {
            return
        }
        
        var xsrfCookie: NSHTTPCookie? = nil
        
        for cookie in cookies {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
    }
    
    // Override parseData
    override func parseData(data: NSData) throws -> AnyObject {
        // Skip first 5 characters
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        
        let object: AnyObject
        do {
            try object = super.parseData(newData)
        } catch let error {
            throw error
        }
        
        return object
    }
    
    // Short-hand for creating session using username and password
    func createSessionWithUsername(username: String, password: String, completion: CompletionHandler?) {
        let parameters = [
            "udacity": [
                "username": username,
                "password": password,
            ]
        ]
        taskForPOST(Endpoint.Session, parameters: parameters, completion: completion)
    }
    
    // Short-hand for creating session using Facebook
    func createSessionWithAccessToken(accessToken: String, completion: CompletionHandler?) {
        let parameters = [
            "facebook_mobile": [
                "access_token": accessToken,
            ]
        ]
        taskForPOST(Endpoint.Session, parameters: parameters, completion: completion)
    }
    
    // Short-hand for deleting session
    func deleteSession(completion: CompletionHandler?) {
        taskForDELETE(Endpoint.Session, parameters: nil, completion: completion)
    }
    
    // Short-hand for getting user data
    func getUserData(userID: String, completion: CompletionHandler?) {
        let endpoint = String(format: Endpoint.UserData, userID)
        taskForGET(endpoint, parameters: nil, completion: completion)
    }

}
