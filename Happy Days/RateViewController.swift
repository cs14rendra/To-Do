//
//  RateViewController.swift
//  Happy Days
//
//  Created by surendra kumar on 7/10/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import LGButton


protocol RateViewContollerDelegate {
    func didRatedAtAppStore()
}


class RateViewController: UIViewController {
    
    @IBOutlet var detalisLB: UILabel!
    @IBOutlet var purchaseBUtton: LGButton!
    var isFromFirstViewController = false
    var delegate : RateViewContollerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromFirstViewController{
            self.purchaseBUtton.titleString = "Purchase"
            self.detalisLB.text = "To save more Card, you need to Purchase it OR you can Rate us and write Review on App Store."
        }
        IAPHelper.sharedInstance.delegate = self
    }

    @IBAction func cancel(_ btn : Any){
        guard !isFromFirstViewController else {
            IAPHelper.sharedInstance.PurchaseItem()
            dismiss(animated: true, completion: nil)
            return
        }
        let defaults = UserDefaults.standard
        defaults.set(-1, forKey: "time")
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func rate(_ btn : Any){
        guard !isFromFirstViewController else {
            print("RATED")
            delegate?.didRatedAtAppStore()
            UserDefaults.standard.set(true, forKey: "purchased")
            let url : URL = URL(string: "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=7")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            dismiss(animated: true, completion: nil)
            return
        }
        
        let url : URL = URL(string: "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=7")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        let defaults = UserDefaults.standard
        defaults.set(-3, forKey: "time")
        dismiss(animated: true, completion: nil)
    }

}


extension RateViewController : IAPHelperDelegate{
    func didItemPurchasedSuccessfully() {
        UserDefaults.standard.set(true, forKey: "purchased")
    }
}
