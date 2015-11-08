//
//  UdacitySession.swift
//  On the Map
//
//  Created by Adi Li on 8/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class UdacitySession: NSObject {
    
    class var ErrorDomain: String { return "UdacitySessionErrorDomain" }
    
    static let currentSession = UdacitySession()
    
    // MARK: - Properties
    
    var sessionID: String?
    var user: UdacityUser?
    
    var loggedIn: Bool { return sessionID != nil }
    
    // MARK: - Login methods
    
    class func loginWithEmail(email: String, password: String, completion: ((UdacitySession?, NSError?) -> Void)?) {
        UdacityAPIClient.client.createSessionWithUsername(email, password: password) { (data, error) -> Void in
            processCreateSessionData(data, error: error, completion: completion)
        }
    }
    
    class func loginWithFacebook(accessToken: String, completion: ((UdacitySession?, NSError?) -> Void)?) {
        UdacityAPIClient.client.createSessionWithAccessToken(accessToken) { (data, error) -> Void in
            processCreateSessionData(data, error: error, completion: completion)
        }
    }
    
    private class func processCreateSessionData(data: AnyObject?, error: NSError?, completion: ((UdacitySession?, NSError?) -> Void)?) {
        guard error == nil else {
            completion?(nil, error)
            return
        }
        
        guard let dict = data as? [String: AnyObject]  else {
            completion?(nil, NSError(domain: ErrorDomain, code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Cannot parse data."
            ]))
            return
        }
        
        guard let sessionID = dict["session"]?["id"] as? String else {
            completion?(nil, NSError(domain: ErrorDomain, code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Cannot parse data[session][id]."
            ]))
            return
        }
        
        guard let userKey = dict["account"]?["key"] as? String else {
            completion?(nil, NSError(domain: ErrorDomain, code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Cannot parse data[account][key]."
            ]))
            return
        }
        
        currentSession.sessionID = sessionID
        currentSession.user = UdacityUser(key: userKey)
        completion?(currentSession, nil)
    }
    
    // MARK: - Logout methods
    
    func logOut(completion: (() -> Void)?) {
        self.sessionID = nil
        self.user = nil
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKLoginManager().logOut()
        }
        
        UdacityAPIClient.client.deleteSession(nil)
        completion?()
    }
}
