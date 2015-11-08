//
//  StudentLocation.swift
//  On the Map
//
//  Created by Adi Li on 25/10/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation
import MapKit


let StudentInformationDidFetchNotificationName = "StudentInformationDidFetchNotification"

struct StudentInformation {
    
    static let ErrorDomain = "StudentInformationErrorDomain"
    
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
    
    init() {
        
    }
    
    init(dictionary: [String: AnyObject]) {
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
    
    mutating func save(completion: ((NSError?) -> Void)?) {
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
    
    private mutating func _saveToParse(completion: ((NSError?) -> Void)?) {
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
    
    private(set) static var locations = [StudentInformation]()
    
    static func allLocations(completion: (([StudentInformation]?, NSError?) -> Void)?) {
        allLocations(false, completion: completion)
    }
    
    static func allLocations(forceUpdate: Bool, completion: (([StudentInformation]?, NSError?) -> Void)?) {
            
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
                let location = StudentInformation(dictionary: locationDict)
                locations.append(location)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                NSNotificationCenter.defaultCenter().postNotification(
                    NSNotification(name: StudentInformationDidFetchNotificationName, object: nil))
            })
            
            completion?(locations, nil)
        }
    }
}
