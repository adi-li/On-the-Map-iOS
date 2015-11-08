//
//  MapViewController.swift
//  On the Map
//
//  Created by Adi Li on 1/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class MapViewController: LoggedInViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
        
    // MARK: - Adding Pin
    
    override func didLoadLocations() {
        mapView.removeAnnotations(mapView.annotations)
        for location in StudentInformation.locations {
            self.addPinWithLocation(location)
        }
    }
    
    func addPinWithLocation(location: StudentInformation) {
        let pin = MKPointAnnotation()
        pin.coordinate = location.coordinate
        pin.title = location.studentName
        pin.subtitle = location.mediaURLString
        
        mapView.addAnnotation(pin)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for pinView in views {
            // Add (i) icon if there is no accessory view
            // Also add tap gesture recognizer for showing safari if tapped the view
            if pinView.rightCalloutAccessoryView == nil {
                let button = UIButton(type: .InfoLight)
                button.userInteractionEnabled = false
                pinView.rightCalloutAccessoryView = button
                pinView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didSelectAnnotationView:"))
            }
        }
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        selectedView = view
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        selectedView = nil
    }
    
    // MARK: - Show Safari
    
    var selectedView: MKAnnotationView?
    
    func didSelectAnnotationView(sender: UITapGestureRecognizer) {
        guard let pinView = sender.view as? MKAnnotationView else {
            return
        }
        
        // Show Safari if pinView == selectedView and has a valid HTTP URL string
        if pinView == selectedView {
            guard let URLString = pinView.annotation?.subtitle else {
                return
            }
            guard let URL = URLString?.HTTPURL else {
                return
            }
            
            let safari = SFSafariViewController(URL: URL)
            presentViewController(safari, animated: true, completion: nil)
        }
    }

}
