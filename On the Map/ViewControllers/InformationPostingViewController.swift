//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by Adi Li on 8/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SafariServices

class InformationPostingViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    @IBOutlet weak var enterURLView: UIView!
    @IBOutlet weak var URLField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var previewURLButton: UIButton!
    
    @IBOutlet weak var enterLocationView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var location = StudentInformation()
    let geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Change question text attributes
        let question = NSMutableAttributedString(string: "Where are you\nstudying\ntoday?",
            attributes: [NSFontAttributeName: UIFont(name: "Roboto-Regular", size: 14)!]
        )
        let range = (question.string as NSString).rangeOfString("studying")
        question.setAttributes([NSFontAttributeName: UIFont(name: "Roboto-Medium", size: 14)!], range: range)
        questionLabel.attributedText = question
        
        locationField.becomeFirstResponder()
    }

    // MARK: - User actions

    @IBAction func nextStep(sender: UIButton) {
        if location.mapString.isEmpty {
            didEnterLocation()
        } else {
            didEnterURL()
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func previewURL(sender: UIButton) {
        guard let URL = URLField.text?.HTTPURL else {
            return
        }
        
        presentViewController(SFSafariViewController(URL: URL), animated: true, completion: nil)
    }
    
    func didEnterLocation() {
        let mapString = locationField.text!
        
        // Show loading view
        loadingView.hidden = false
        
        // Geocoding address
        geocoder.geocodeAddressString(mapString) { (placemarks, error) -> Void in
            // Hide loading view
            self.loadingView.hidden = true
            
            guard error == nil || placemarks?.count > 0 else {
                UIAlertController.alertControllerWithTitle("Geocoding Error", message: "Address not found").showFromViewController(self)
                return
            }
            
            // Generate pins
            self.addPinForPlacemarks(placemarks!)

            // Save map string
            self.location.mapString = mapString
            
            // Switch to enter url
            self.showEnterURLView()
        }
    }
    
    func didEnterURL() {
        guard let URLString = URLField.text where !URLString.isEmpty else {
            UIAlertController.alertControllerWithTitle("Error", message: "Please enter URL.").showFromViewController(self)
            return
        }
        
        guard let URL = URLString.HTTPURL else {
            UIAlertController.alertControllerWithTitle("Error", message: "Please enter valid URL.").showFromViewController(self)
            return
        }
        
        location.mediaURL = URL
        
        saveLocation()
    }
    
    // MARK: - Save location
    
    func saveLocation() {
        // Show loading view
        loadingView.hidden = false
        
        location.save { (error) -> Void in
            // Hide loading view
            self.loadingView.hidden = true
            
            // Check error
            guard error == nil else {
                UIAlertController.alertControllerWithTitle("Error", message: error?.localizedDescription).showFromViewController(self)
                return
            }
            
            // refresh locations and dismiss self
            StudentInformation.allLocations(true, completion: { (locations, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            })
        }
    }
    
    // MARK: - Map view
    
    func addPinForPlacemarks(placemarks: [CLPlacemark]) {
        for placemark in placemarks {
            let pin = MKPointAnnotation()
            pin.coordinate = placemark.location!.coordinate
            pin.title = placemark.name
            pin.subtitle = placemark.locality
            
            mapView.addAnnotation(pin)
        }
        
        let placemark = placemarks.first!
        
        mapView.setRegion(MKCoordinateRegion(center: placemark.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)),
            animated: true)
        
        location.latitude = placemark.location!.coordinate.latitude
        location.longitude = placemark.location!.coordinate.longitude
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let pin = view.annotation else {
            return
        }
        
        location.latitude = pin.coordinate.latitude
        location.longitude = pin.coordinate.longitude
    }
    
    
    // MARK: - View animations
    
    func showEnterURLView() {
        // Show enter URL view
        submitButton.setTitle("Submit", forState: .Normal)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.enterURLView.alpha = 1
            self.enterLocationView.alpha = 0
            self.view.backgroundColor = self.URLField.backgroundColor
            
            }, completion: { (finished) -> Void in
                self.enterLocationView.hidden = true
                self.URLField.becomeFirstResponder()
                
        })
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        previewURLButton.enabled = newText.isValidHTTPURL
        return true
    }
    
}
