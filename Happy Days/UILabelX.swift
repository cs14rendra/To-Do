//
//  UILabelX.swift
//  DesignableXTesting
//
//  Created by Mark Moeykens on 1/28/17.
//  Copyright © 2017 Moeykens. All rights reserved.
//

import UIKit

@IBDesignable
class UILabelX: UILabel {
    
    @IBInspectable var shadoOpacity : CGFloat = 0{
        didSet{
            self.layer.shadowOpacity = Float(shadoOpacity)
        }
    }
    
    @IBInspectable var shadoColorLayer :UIColor = UIColor.clear{
        didSet{
            self.layer.shadowColor = shadoColorLayer.cgColor
        }
    }
    @IBInspectable var shadoRadious : CGFloat = 0{
        didSet{
            self.layer.shadowOpacity = Float(shadoRadious)
        }
    }
    
    @IBInspectable var shadoOffsetLayer : CGSize = CGSize(width:0, height : 0)   {
        didSet{
            self.layer.shadowOffset = shadoOffsetLayer
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var rotationAngle: CGFloat = 0 {
        didSet {
            self.transform = CGAffineTransform(rotationAngle: rotationAngle * .pi / 180)
        }
    }
}
