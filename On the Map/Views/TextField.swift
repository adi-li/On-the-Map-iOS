//
//  TextField.swift
//  On the Map
//
//  Created by Adi Li on 31/10/2015.
//  Copyright © 2015 Adi Li. All rights reserved.
//

import UIKit

// Add padding tuning for UITextField
@IBDesignable
class TextField: UITextField {

    @IBInspectable var paddingX: CGFloat = 0
    @IBInspectable var paddingY: CGFloat = 0
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }
    
    private func rectForBounds(bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: paddingX, dy: paddingY)
    }
    
    
}
