//
//  UIAlertController+Utility.swift
//  On the Map
//
//  Created by Adi Li on 8/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func alertControllerWithTitle(title: String?, message: String?) -> Self {
        let alert = self.init(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        return alert
    }
    
    func showFromViewController(vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            vc.presentViewController(self, animated: animated, completion: completion)
        }
    }
}
