//
//  LoggedInViewController.swift
//  On the Map
//
//  Created by Adi Li on 8/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

class LoggedInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "On The Map"

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout:")
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshPins:"),
            UIBarButtonItem(image: UIImage(named: "pin")!, style: .Plain, target: self, action: "createPin:"),
        ]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didLoadLocations",
            name: StudentLocationDidFetchNotificationName, object: nil)
        
        refreshPins(nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Trigger didLoadLocations to reload view
        self.didLoadLocations()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Navigation bar button actions

    func logout(sender: UIBarButtonItem?) {
        navigationItem.leftBarButtonItem?.enabled = false

        UdacitySession.currentSession.logOut { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.navigationItem.leftBarButtonItem?.enabled = true
                self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    func createPin(sender: UIBarButtonItem?) {
        let viewController = storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController")
        
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    func refreshPins(sender: UIBarButtonItem?) {
        let forceUpdate = (sender != nil)  // Force update if pressing button
        
        StudentLocation.allLocations(forceUpdate, completion: nil)
    }
    
    // MARK: - Override for custom actions
    
    func didLoadLocations() {
        
    }
}
