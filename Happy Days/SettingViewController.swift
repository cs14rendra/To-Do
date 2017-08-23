//
//  SettingViewController.swift
//  Happy Days
//
//  Created by surendra kumar on 7/9/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    
    var shouldIShowRateDialog : Bool = false
    var isApearedOnce = false
    
    @IBOutlet var mySwicthLB: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tracker()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "sortbyP"){
            print("sort by priority")
            self.mySwicthLB.setOn(true, animated: false)
        }else {
            print("sort by date")
            self.mySwicthLB.setOn(false, animated: false)
        }
        guard shouldIShowRateDialog else {return}
        if !isApearedOnce{
            isApearedOnce = true
            self.performSegue(withIdentifier: "pop", sender: self)
        }
    }
    
    
    @IBAction func mySwitch(_ sender: Any) {
        if (sender as! UISwitch).isOn{
            print("BYP")
            UserDefaults.standard.setValue(true, forKey: "sortbyP")
        }else{
            print("BYD")
            UserDefaults.standard.setValue(false, forKey: "sortbyP")
        }
        let alert = UIAlertController(title: "Done", message: "Cards will be sorted in preferred order when you launch App next time ", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func rate(_ btn : Any){
        let url : URL = URL(string: "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=7")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func share(_ btn : Any){
        let acivity1 = DESCRIPTION
        let activity2 = APP_URL
        let activity = UIActivityViewController(activityItems: [acivity1,activity2], applicationActivities: nil)
        
        
        activity.popoverPresentationController?.sourceView = self.view
        
        present(activity, animated: true, completion: nil)
        

    }
}


extension  SettingViewController {
    
    func tracker(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: ["time":1])
        let oldtime = defaults.integer(forKey: "time")
        if (oldtime <= 3){
            let newtime = oldtime + 1
            defaults.set(newtime, forKey: "time")
        }else{
            shouldIShowRateDialog = true
        }
    }
}
