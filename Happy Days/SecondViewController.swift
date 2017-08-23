//
//  SecondViewController.swift
//  Happy Days
//
//  Created by surendra kumar on 7/7/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import RealmSwift

class SecondViewController: UIViewController {
    let managerDB = CardsDataBase.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    @IBAction func save(_ sender: Any) {
        
        let data = CardsData()
        data.title = "Surendra"
        data.details = "I M A "
        data.imageName = "httbhf:dmhjs.jpg"
        let d = NSDate()
        data.date = d
        data.id = String(describing: d)
        managerDB.saveCards(cards: data)
    }
    
    @IBAction func fetch(_ sender: Any) {
        managerDB.FetchCardsData { result in
            guard let val = result else{
                print("NIL VALUE")
                return
            }
            print(val)
        }
    }
    
    @IBAction func update(_ sender: Any) {
        
        let data = CardsData()
        data.title = "Surendra UPDATE"
        data.details = "I M A "
        data.imageName = "httbhf:dmhjs.jpg"
        let d = NSDate()
        data.date = d
        data.id = "2017-07-09 06:43:50 +0000"
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(data, update: true)
            }
        
        }
    
    func deleteOBJ(){
        let realm = try! Realm()
        let v = realm.objects(CardsData.self).filter("id = '2017-07-09 06:43:50 +0000'")
        try! realm.write {
            realm.delete(v)
        }
    }
    
    
    
}

