//
//  LogInViewController.swift
//  On the Map
//
//  Created by Adi Li on 31/10/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit
import SafariServices
import FBSDKCoreKit
import FBSDKLoginKit

let errorTitle = "Log in error"

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: - Validation
    
    // Validate input text is an email.
    // Reference: http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
    func isValidEmail(text:String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(text)
    }
    
    // MARK: - User actions

    @IBAction func login(sender: UIButton) {

        // Ensure email is entered
        guard let email = emailField.text where !email.isEmpty else {
            UIAlertController.alertControllerWithTitle(errorTitle, message: "Please enter email.").showFromViewController(self)
            emailField.becomeFirstResponder()
            return
        }
        
        // Ensure email is valid
        if !isValidEmail(email) {
            UIAlertController.alertControllerWithTitle(errorTitle, message: "Please enter valid email.").showFromViewController(self)
            emailField.becomeFirstResponder()
            return
        }
        
        // Ensure password is entered
        guard let password = passwordField.text where !password.isEmpty else {
            UIAlertController.alertControllerWithTitle(errorTitle, message: "Please enter password.").showFromViewController(self)
            passwordField.becomeFirstResponder()
            return
        }
        
        dismissKeyboard(view)
        
        // Prevent button tapped again during the api calling
        sender.enabled = false
        sender.setTitle("Loading...", forState: .Normal)
        
        // Start create session
        UdacitySession.loginWithEmail(email, password: password) { (session, error) -> Void in
            
            // Change back to login button
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                sender.setTitle("Log in", forState: .Normal)
                sender.enabled = true
            })
            
            // Show error message if error exists
            guard error == nil else {
                var message = "Unexpected error"
                
                switch error!.domain {
                case UdacityAPIClient.ErrorDomain:
                    if let err = error?.userInfo["Data"]?["error"] as? String {
                        message = err
                    }
                default:
                    message = error!.localizedDescription
                }
                
                UIAlertController.alertControllerWithTitle(errorTitle, message: message).showFromViewController(self)
                return
            }
            
            // Show error message if data is nil
            guard session != nil else {
                UIAlertController.alertControllerWithTitle(errorTitle, message: "Unexpected error").showFromViewController(self)
                return
            }
            
            // Save the session into user default
            self.userDidLogin()
        }
    }

    @IBAction func loginWithFacebook(sender: UIButton) {
        let manager = FBSDKLoginManager()
        
        manager.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) -> Void in
            
            guard error == nil else {
                UIAlertController.alertControllerWithTitle(errorTitle, message: error.localizedDescription).showFromViewController(self)
                return
            }
            
            if !result.isCancelled {
                // Facebook login success
                
                // Prevent button tapped again during the api calling
                sender.enabled = false
                sender.setTitle("Loading...", forState: .Normal)
                
                // Create session with access token
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                UdacitySession.loginWithFacebook(accessToken, completion: { (session, error) -> Void in
                    // Change back to login button
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        sender.setTitle("Log in", forState: .Normal)
                        sender.enabled = true
                    })
                    
                    // Show error message if error exists
                    guard error == nil else {
                        var message = "Invalid Facebook access token"
                        if let err = error?.userInfo["Data"]?["error"] as? String {
                            message = err
                        }
                        UIAlertController.alertControllerWithTitle(errorTitle, message: message).showFromViewController(self)
                        return
                    }
                    
                    // Show error message if data is nil
                    guard session != nil else {
                        UIAlertController.alertControllerWithTitle(errorTitle, message: "Unexpected error").showFromViewController(self)
                        return
                    }
                    
                    self.userDidLogin()
                })
            }
        }
    }
    
    @IBAction func signUp(sender: AnyObject) {
        // Open Safari with Udacity sign up page
        let URL = NSURL(string: "https://www.udacity.com/account/auth#!/signup")!
        let safari = SFSafariViewController(URL: URL)
        
        presentViewController(safari, animated: true, completion: nil)
    }
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        view.endEditing(true)
    }
    
    // Log in success
    func userDidLogin() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.performSegueWithIdentifier("UserDidLogin", sender: self)
        }
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            login(loginButton)
        }
        return true
    }
}
