//
//  Image.swift
//  Happy Days
//
//  Created by surendra kumar on 7/13/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation

let image: [String] = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]

class Image{
    public static let sharedInstance = Image()
    
    func getRandomImageName() -> String{
        let randomNumber = Int(arc4random_uniform(14))
        return image[randomNumber]
    }
}
