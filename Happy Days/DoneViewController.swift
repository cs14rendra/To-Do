//
//  DoneViewController.swift
//  To-Do
//
//  Created by surendra kumar on 7/17/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import Koloda
import LGButton
import RealmSwift

class DoneViewController: UIViewController {
    
    @IBOutlet var my: UIView!
    @IBOutlet var cards: KolodaView!
    
    var card = [CardsData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        cards.delegate = self
        cards.dataSource = self
        cards.layer.shadowColor = UIColor.blue.withAlphaComponent(0.4).cgColor
        cards.layer.shadowRadius = 4.0
        cards.layer.shadowOpacity = 1.0
        cards.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.loadCardsFromDB()
       
    }
    
 
    @IBAction func btnClicked(_ sender: Any) {
        self.cards.swipe(.left)
    }
    func loadCardsFromDB(){
        CardsDataBase.sharedInstance.FetchdoneTask{ r in
            guard let result = r else{
                print("card is emptry")
                return
            }
            
            self.card = Array(result)
            DispatchQueue.main.async {
                
                self.cards.reloadData()
            }
        }
    }
    
    func stringFromDateString(date : NSDate) -> String{
        let myDate : Date = date as Date
        let formatter = DateFormatter()
        let dayNumber  = Calendar.current.component(.day, from: myDate)
        let monthNumber = Calendar.current.component(.month, from: myDate)
        let YearNUmber = Calendar.current.component(.year, from: myDate)
        let dayString = String(describing: dayNumber)
        let monthString = formatter.shortMonthSymbols[monthNumber-1]
        let yearString = String(describing: YearNUmber)
        let fomrmattedDate : String = "\(dayString) \(monthString) \(yearString)"
        
        return fomrmattedDate
    }
}

extension DoneViewController : KolodaViewDataSource{
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return card.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        if let customView = Bundle.main.loadNibNamed("CustomCard", owner: self, options: nil)?.first as? CustomCard{
            
            let str : String = self.card[index].task
            let attributedText : NSMutableAttributedString = NSMutableAttributedString(string: str)
                attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributedText.length))
                
                customView.details.attributedText = attributedText
                customView.details.textColor = UIColor.lightGray
    
            customView.dateString.text = self.datestringFromDate(date: card[index].date as Date)
            customView.timeString.text = self.timeStringFromDate(date: card[index].date as Date)
           customView.BellIcon.isHidden = true
            
            switch card[index].priority {
            case 1:
                customView.priorityString.text = "A"
            case 2:
                customView.priorityString.text = "B"
            case 3:
                customView.priorityString.text = "C"
            case 4:
                customView.priorityString.text = "D"
            case 5:
                customView.priorityString.text = "E"
                
            default:
                print("NO value to set")
            }
            
            return customView
        }
        return my
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("DeleteOverLayView", owner: self, options: nil)?.first as? OverlayView
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        let speed = DragSpeed(rawValue: 1.0)
        
        return speed!
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.9
    }
}


// KOLDAVIEW : DATEGATE

extension DoneViewController : KolodaViewDelegate{
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool { return true }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
     
    }
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
       
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection){
       
        switch direction {
        case .left,.bottomLeft,.topLeft:
            print("left")
            // deletefrom DB ..delete from Local Array
             self.deleteFunction(index: index)
             //self.card.remove(at: index)
        case .right,.bottomRight,.topRight:
            print("RIGHT")
        default:
            print("NOTHING")
        }
    }
}


extension DoneViewController {
    
    
    func datestringFromDate(date : Date) -> String{
        let formatter = DateFormatter()
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current,month : components.month,day : components.day, weekday : components.weekday)
        
        let weekNumber = newComponents.weekday!
        let weekString = formatter.shortWeekdaySymbols[weekNumber-1]
        
        let dayNumber  = newComponents.day!
        let dayString = String(describing: dayNumber)
        
        let monthNumber = newComponents.month!
        let monthString = formatter.shortMonthSymbols[monthNumber-1]
        
        var fomrmattedDate : String = "\(weekString), \(dayString) \(monthString)"
        
        if Calendar.current.isDateInToday(date){
            fomrmattedDate = "Today"
        }else if Calendar.current.isDateInTomorrow(date){
            fomrmattedDate = "Tomorrow"
        }else{
            fomrmattedDate = "\(weekString), \(dayString) \(monthString)"
        }
        
        return fomrmattedDate
    }
    
    func timeStringFromDate(date : Date) -> String{
        let formate = DateFormatter()
        formate.dateFormat = "hh:mm a"
        let timeString = formate.string(from: date)
        return timeString
    }
    
    func deleteFunction(index : Int){
        let id : String = self.card[index].id
        let realm = try! Realm()
        let v = realm.objects(CardsData.self).filter("id = '\(id)'")
        if (v.isInvalidated){print("INVALID ITEM")}
        try! realm.write {
            realm.delete(v)
        }
    }
    
}


