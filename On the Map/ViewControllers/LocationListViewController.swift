//
//  LocationListViewController.swift
//  On the Map
//
//  Created by Adi Li on 8/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit
import SafariServices

class LocationListViewController: LoggedInViewController, UITableViewDataSource, UITableViewDelegate {
        
    var tableView: UITableView! { return view as? UITableView }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(LocationCell.self, forCellReuseIdentifier: LocationCell.Identifier)
    }
    
    override func didLoadLocations() {
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocation.locations.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(LocationCell.Identifier, forIndexPath: indexPath) as! LocationCell
        
        cell.nameLabel.text = StudentLocation.locations[indexPath.row].studentName

        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let location = StudentLocation.locations[indexPath.row]
        
        guard let URL = location.mediaURL else {
            return
        }
        
        let safari = SFSafariViewController(URL: URL)
        
        presentViewController(safari, animated: true, completion: nil)
    }

}
