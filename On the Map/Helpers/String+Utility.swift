//
//  String+Utility.swift
//  On the Map
//
//  Created by Adi Li on 8/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation

extension String {
    
    var isValidHTTPURL: Bool {
        guard !isEmpty else {
            return false
        }
        
        // Regex Ref: http://code.tutsplus.com/tutorials/8-regular-expressions-you-should-know--net-6149
        let regex = "^https?:\\/\\/([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
        let predicate = NSPredicate(format:"SELF MATCHES [c] %@", regex)
        
        return predicate.evaluateWithObject(self)
    }
    
    var HTTPURL: NSURL? {
        guard isValidHTTPURL else {
            return nil
        }
        
        return NSURL(string: self)
    }
}