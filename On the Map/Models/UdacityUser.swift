//
//  UdacityUser.swift
//  On the Map
//
//  Created by Adi Li on 8/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

class UdacityUser : NSObject {
    
    class var ErrorDomain: String { return "UdacityUserErrorDomain" }
    
    // MARK: - Properties
    
    var key: String
    var firstName = ""
    var lastName = ""
    
    
    // MARK: - init
    
    init(key: String) {
        self.key = key
        super.init()
    }
    
    class func fetchUserByKey(key: String, completion: ((UdacityUser?, NSError?) -> Void)?) {
        let user = UdacityUser(key: key)
        user.refresh { (error) -> Void in
            guard error == nil else {
                completion?(nil, error)
                return
            }
            completion?(user, nil)
        }
    }
    
    func updateWithDictionary(dictionary: [String: AnyObject]) {
        firstName = dictionary["user"]?["first_name"] as? String ?? ""
        lastName = dictionary["user"]?["last_name"] as? String ?? ""
    }
    
    func refresh(completion: ((NSError?) -> Void)?) {
        UdacityAPIClient.client.getUserData(key) { (data, error) -> Void in
            guard error == nil else {
                completion?(error)
                return
            }
            
            guard let dict = data as? [String: AnyObject] else {
                completion?(NSError(domain: self.dynamicType.ErrorDomain, code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Cannot parse user"
                ]))
                return
            }
            
            self.updateWithDictionary(dict)
            
            completion?(nil)
        }
    }
}
