//
//  StudentLocation.swift
//  On the Map
//
//  Created by Adi Li on 25/10/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import MapKit


let StudentLocationDidFetchNotificationName = "StudentLocationDidFetchNotification"

class StudentLocation: NSObject {
    
    class var ErrorDomain: String { return "StudentLocationErrorDomain" }
    
    // MARK: - Properties
    
    var objectID: String?
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var mediaURLString = ""
    var latitude: Double = 0
    var longitude: Double = 0
    
    // MARK: - Init
    
    convenience init(dictionary: [String: AnyObject]) {
        self.init()
        objectID = dictionary["objectId"] as? String
        
        uniqueKey = dictionary["uniqueKey"] as? String ?? ""
        firstName = dictionary["firstName"] as? String ?? ""
        lastName = dictionary["lastName"] as? String ?? ""
        mapString = dictionary["mapString"] as? String ?? ""
        mediaURLString = dictionary["mediaURL"] as? String ?? ""
        latitude = dictionary["latitude"] as? Double ?? 0
        longitude = dictionary["longitude"] as? Double ?? 0
    }
    
    // MARK: - Computed properties
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var studentName: String {
        return [firstName, lastName].joinWithSeparator(" ")
    }
    
    var mediaURL: NSURL? {
        get {
            return mediaURLString.HTTPURL
        }
        set {
            guard newValue != nil || newValue!.absoluteString.isValidHTTPURL else {
                mediaURLString = ""
                return
            }
            mediaURLString = newValue!.absoluteString
        }
    }
    
    // MARK: - Save
    
    func save(completion: ((NSError?) -> Void)?) {
        // Add user detail
        UdacitySession.currentSession.user!.refresh() { (error) -> Void in
            guard error == nil else {
                completion?(error)
                return
            }
            
            let user = UdacitySession.currentSession.user!
            self.uniqueKey = user.key
            self.firstName = user.firstName
            self.lastName = user.lastName
            
            // Save to Parse
            self._saveToParse(completion)
        }
    }
    
    private func _saveToParse(completion: ((NSError?) -> Void)?) {
        // Check existing location
        ParseAPIClient.client.getLocationByKey(uniqueKey) { (data, error) -> Void in
            guard error == nil else {
                completion?(error)
                return
            }
            
            guard let dict = data as? [String: AnyObject] else {
                completion?(NSError(domain: self.dynamicType.ErrorDomain, code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Cannot parse location"
                ]))
                return
            }
            
            guard let results = dict["results"] as? [[String: AnyObject]] else {
                completion?(NSError(domain: self.dynamicType.ErrorDomain, code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Cannot parse location results"
                ]))
                return
            }
            
            self.objectID = results.first?["objectId"] as? String
            self._createOrUpdate(completion)
        }
    }
    
    private func _createOrUpdate(completion: ((NSError?) -> Void)?) {
        let wrappedCompletion = { (data: AnyObject?, error: NSError?) -> Void in
            guard error == nil else {
                completion?(error)
                return
            }
            
            completion?(nil)
        }
        
        if objectID == nil {
            // Create new location if object ID not exists
            ParseAPIClient.client.createLocation(uniqueKey: uniqueKey,
                firstName: firstName, lastName: lastName,
                mapString: mapString, mediaURL: mediaURLString,
                latitude: latitude, longitude: longitude,
                completion: wrappedCompletion)
        } else {
            // Update location otherwise
            ParseAPIClient.client.updateLocation(objectID!, uniqueKey: uniqueKey,
                firstName: firstName, lastName: lastName,
                mapString: mapString, mediaURL: mediaURLString,
                latitude: latitude, longitude: longitude,
                completion: wrappedCompletion)
        }
    }
    
    
    // MARK: - Get locations
    
    private(set) static var locations = [StudentLocation]()
    
    class func allLocations(completion: (([StudentLocation]?, NSError?) -> Void)?) {
        allLocations(false, completion: completion)
    }
    
    class func allLocations(forceUpdate: Bool, completion: (([StudentLocation]?, NSError?) -> Void)?) {
            
        // If there is cached results, return it immediately
        if locations.count > 0 && !forceUpdate {
            completion?(locations, nil)
            return
        }
        
        ParseAPIClient.client.getLocations { (data, error) -> Void in
            guard error == nil else {
                completion?(nil, error)
                return
            }
            
            guard let results = data?["results"] as? [[String: AnyObject]] else {
                completion?(nil, NSError(domain: ErrorDomain, code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Cannot parse data[results]."
                ]))
                return
            }
            
            locations.removeAll()
            
            for locationDict in results {
                let location = StudentLocation(dictionary: locationDict)
                locations.append(location)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                NSNotificationCenter.defaultCenter().postNotification(
                    NSNotification(name: StudentLocationDidFetchNotificationName, object: self))
            })
            
            completion?(locations, nil)
        }
    }
}
