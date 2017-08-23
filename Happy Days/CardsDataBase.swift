//
//  CardsDataBase.swift
//  Happy Days
//
//  Created by surendra kumar on 7/9/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import RealmSwift

class CardsDataBase {
    
    public static let sharedInstance = CardsDataBase()
    
    func saveCards(cards : CardsData){
        //try! FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        
        do{
            let realm = try Realm()
            try realm.write {
                realm.add(cards)
                print("DATA SAVED")
            }
            
        }catch{
            print(error.localizedDescription)
        }
        
    }
    
    func FetchUndoneTask(completion : @escaping (_ result : Results<CardsData>?) -> ()){
        var  result : Results<CardsData>? = nil
        DispatchQueue.main.async {
            
            do{
                
                let realm = try Realm()
                result = realm.objects(CardsData.self).filter("isDone = 0")
                completion(result)
            }catch{
                completion(result)
                print("DATABASE ERROR")
                print(error.localizedDescription)
                
            }
        }
    }
    
    func FetchdoneTask(completion : @escaping (_ result : Results<CardsData>?) -> ()){
        var  result : Results<CardsData>? = nil
        DispatchQueue.main.async {
            
            do{
                
                let realm = try Realm()
                result = realm.objects(CardsData.self).filter("isDone = 1")
                completion(result)
            }catch{
                completion(result)
                print("DATABASE ERROR")
                print(error.localizedDescription)
                
            }
        }
    }
    
}
