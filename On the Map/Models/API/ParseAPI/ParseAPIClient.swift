//
//  ParseAPIClient.swift
//  On the Map
//
//  Created by Adi Li on 25/10/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import Foundation

class ParseAPIClient: APIClient {
    
    static let client = ParseAPIClient()
    
    override class var BaseURL: NSURL { return NSURL(string: "https://api.parse.com/1/")! }
    override class var ErrorDomain: String { return "ParseAPIClientDomain" }
    
    class var AppID: String { return "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr" }
    class var APIKey: String { return "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY" }
    
    // Override addAdditionalHeaderToRequest
    override func addAdditionalHeaderToRequest(request: NSMutableURLRequest) {
        super.addAdditionalHeaderToRequest(request)
        
        request.setValue(self.dynamicType.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.setValue(self.dynamicType.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    }
    
    // Short-hand for getting locations
    func getLocations(completion: CompletionHandler?) {
        getLocationByKey(nil, completion: completion)
    }
    
    // Short-hand for getting location by unique key
    func getLocationByKey(key: String?, completion: CompletionHandler?) {
        var parameters = [
            "order": "-updatedAt",
            "limit": 100,
        ]
        
        if key != nil {
            parameters["where"] = "{\"uniqueKey\":\"\(key!)\"}"
        }
        
        taskForGET(Endpoint.StudentLocationCollection, parameters: parameters, completion: completion)
    }
    
    // Short-hand for creating location
    func createLocation(uniqueKey uniqueKey: String, firstName: String, lastName: String, mapString: String,
        mediaURL: String, latitude: Double, longitude: Double, completion: CompletionHandler?)
    {
        let parameters: [String: AnyObject] = [
            "uniqueKey": uniqueKey,
            "firstName": firstName,
            "lastName": lastName,
            "mapString": mapString,
            "mediaURL": mediaURL,
            "latitude": latitude,
            "longitude": longitude,
        ]
        
        taskForPOST(Endpoint.StudentLocationCollection, parameters: parameters, completion: completion)
    }

    // Short-hand for updating location
    func updateLocation(objectID: String, uniqueKey: String, firstName: String, lastName: String, mapString: String,
        mediaURL: String, latitude: Double, longitude: Double, completion: CompletionHandler?)
    {
        let endpoint = String(format: Endpoint.StudentLocation, objectID)
        let parameters: [String: AnyObject] = [
            "uniqueKey": uniqueKey,
            "firstName": firstName,
            "lastName": lastName,
            "mapString": mapString,
            "mediaURL": mediaURL,
            "latitude": latitude,
            "longitude": longitude,
        ]
        taskForPUT(endpoint, parameters: parameters, completion: completion)
    }
}
