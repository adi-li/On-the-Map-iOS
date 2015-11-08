//
//  LocationCell.swift
//  On the Map
//
//  Created by Adi Li on 8/11/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

extension LocationListViewController {
    
    class LocationCell: UITableViewCell {
        
        class var Identifier: String { return "LocationCell" }
        
        lazy var pinView = UIImageView(image: UIImage(named: "pin"))
        lazy var nameLabel = UILabel()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setup()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }
        
        func setup() {
            contentView.addSubview(pinView)
            contentView.addSubview(nameLabel)
            
            pinView.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["pinView": pinView, "nameLabel": nameLabel]
            
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-8-[pinView(27)]-8-[nameLabel]-|", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
            
            contentView.addConstraints([
                NSLayoutConstraint(item: pinView, attribute: .Height, relatedBy: .Equal,
                    toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 27),
                NSLayoutConstraint(item: pinView, attribute: .CenterY, relatedBy: .Equal,
                    toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: nameLabel, attribute: .CenterY, relatedBy: .Equal,
                    toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0),
            ])
            
            separatorInset.left = 43
        }
    }
}