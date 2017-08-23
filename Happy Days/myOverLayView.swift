//
//  myOverLayView.swift
//  To-Do
//
//  Created by surendra kumar on 7/17/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import Koloda

private let overlayRightImageName = "overlay_like"
private let overlayLeftImageName = "overlay_skip"

class myOverLayView: OverlayView {
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                overlayImageView.image = nil
            }
            
        }
    }
    
}
