//
//  FirstViewController.swift
//  Happy Days
//
//  Created by surendra kumar on 7/7/17.
//  Copyright © 2017 weza. All rights reserved.
// this is version 1.1

import UIKit
import Koloda
import pop
import LGButton
import AlertOnboarding
import RealmSwift
import SwiftDate
import UserNotifications

class FirstViewController: UIViewController {

    @IBOutlet var my: UIView!
    @IBOutlet var cards: KolodaView!
    
    var doneCardIndex = [Int]()
    var card = [CardsData]()
    var isCardseizemorethanThreshHold : Bool = false
    var threshHold = 10
    
    // Alert
    
    var alertView: AlertOnboarding!
    var arrayOfImage = ["item1", "item2", "item3","item4"]
    var arrayOfTitle = ["ADD TASK", "MISSED TASK", "DONE TASK","PRIORITY"]
    var arrayOfDescription = ["Add task by clicking on plus button, enter task name and notification time etc",
                              "if you missed a task then it will be change to orange color text ",
                              "All your done task will be listed on another screen. just tap top-left button and see the list.you have option to delete recent tasks","in the Setting, you can sort task based on their priority. Otherwise it will be sorted based on Date"]
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cards.delegate = self
        cards.dataSource = self
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
       
        UserDefaults.standard.register(defaults: ["purchased":false])
        self.alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
        cards.layer.shadowColor = UIColor.blue.withAlphaComponent(0.4).cgColor
        cards.layer.shadowRadius = 4.0
        cards.layer.shadowOpacity = 1.0
        cards.layer.shadowOffset = CGSize(width: 1, height: 1)
        UserDefaults.standard.register(defaults: ["sortbyP":true])
        // CHECK FOR OLD USER OF APP
        UserDefaults.standard.register(defaults: ["olduser":true])
        print("VIEWDIDLOAD")
        self.loadCardsFromDB()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isAppAlreadyLaunchedOnce(){
            self.cutomizeAlertView()
            self.alertView.show()
            
        }
    }
    
    
    @IBAction func create(_ sender: Any) {
//        if isCardseizemorethanThreshHold{
//            if UserDefaults.standard.bool(forKey: "purchased"){
//              self.performSegue(withIdentifier: "create", sender: self)
//            }else{
//                self.performSegue(withIdentifier: "purchase", sender: self)
//                }
//        }else{
//            self.performSegue(withIdentifier: "create", sender: self)
//        }
        
        self.performSegue(withIdentifier: "create", sender: self)
    }
    
    
    @IBAction func reloadData(_ sender: UIButton) {
        print("Undo")
        self.cards.revertAction()
    }
    
    
    @IBAction func left(_ sender: Any) {
        
        self.cards.swipe(.left)
    }
    
    @IBAction func right(_ sender: Any) {
        self.cards.swipe(.right)
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "update"{
//            let dst = segue.destination as! UpdateViewController
//            dst.card = card[cards.currentCardIndex]
//            dst.delegate = self
//            print("segtoupdate")
//        }
        
        if segue.identifier == "create"{
            let dst = segue.destination as! CreateViewController
            dst.delegate = self
            print("createdelegate")
        }
        
        if segue.identifier == "purchase"{
            let dst = segue.destination as! RateViewController
            dst.isFromFirstViewController = true
            dst.delegate = self
        }
    }
    
    func loadCardsFromDB(){
        CardsDataBase.sharedInstance.FetchUndoneTask{ r in
            var sortedData = r
            
            if UserDefaults.standard.bool(forKey: "sortbyP") {
                sortedData = r?.sorted(byKeyPath: "priority", ascending: true)
                
            }else{
                sortedData = r?.sorted(byKeyPath: "date", ascending: true)
            }
            
            guard let result = sortedData else{
            print("card is emptry")
                return
            }
            
            self.card = Array(result)
            
            if(self.card.count >= self.threshHold){
                print("Greather than ThreshHold")
                self.isCardseizemorethanThreshHold = true
            }else{
                self.isCardseizemorethanThreshHold = false
                print("Less than Threshhold")
            }
            //self.card.shuffle()
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

    

    func  updateRealmAndAtttributeString(at  index : Int){
        let card = CardsData()
        card.task = self.card[index].task
        card.isDone = true
        card.priority = self.card[index].priority
        card.isNotificationON = self.card[index].isNotificationON
        card.date = self.card[index].date
        let primaryKey = self.card[index].id
        print(primaryKey )
        card.id = primaryKey
        let realm = try! Realm()
        try! realm.write {
            realm.add(card, update: true)
        }
       self.card[index] = card
    }
    
    func deleteAllNotification(index : Int){
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.card[index].task])
    }
    
}



// KOLDAVIEW : DATASOURCE

extension FirstViewController : KolodaViewDataSource{
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return card.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {

        if let customView = Bundle.main.loadNibNamed("CustomCard", owner: self, options: nil)?.first as? CustomCard{
            
            let savedDate : Date = self.card[index].date as Date
            if card[index].isDone{
                print("PRESENT")
                let str : String = self.card[index].task
                let attributedText : NSMutableAttributedString = NSMutableAttributedString(string: str)
                attributedText.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributedText.length))
                
                customView.details.attributedText = attributedText
                customView.details.textColor = UIColor.lightGray
            }else if (savedDate < Date().addingTimeInterval(-40)){
                customView.details.textColor = UIColor.red
                customView.details.text = "Missed: \(card[index].task)"
            }else{
                customView.details.textColor = UIColor.black
                customView.details.text = card[index].task
            }
           
            
            
            customView.dateString.text = self.datestringFromDate(date: card[index].date as Date)
            customView.timeString.text = self.timeStringFromDate(date: card[index].date as Date)
            if !card[index].isNotificationON {
                customView.BellIcon.isHidden = true
            }
            
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
        return Bundle.main.loadNibNamed("myOverLayView", owner: self, options: nil)?.first as? OverlayView
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

extension FirstViewController : KolodaViewDelegate{
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool { return true }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
        self.cards.resetCurrentCardIndex()
    }
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection){
        print("called")
        switch direction {
        case .left,.bottomLeft,.topLeft:
            print("left")
            
        case .right,.bottomRight,.topRight:
            print("RIGHT")
             // UPDATE isDone HERE and appy text Attribute
            self.updateRealmAndAtttributeString(at : index)
            self.deleteAllNotification(index: index)
        default:
            print("NOTHING")
        }
    }
}


extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}


extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}


extension FirstViewController : CreateViewControllerDelagte{
    func fromCreateViewController() {
        print("fromCreate")
        self.loadCardsFromDB()
    }
}


//extension FirstViewController : UpdateViewControllerDelegate{
//    func fromUpdateViewController() {
//        print("fromUpdate : \(isCardseizemorethanThreshHold)")
////        self.card.remove(at: cards.currentCardIndex)
////        self.cards.resetCurrentCardIndex()
//        
//        self.card.remove(at: cards.currentCardIndex)
//        self.cards.resetCurrentCardIndex()
//    }
//    func fromUpdatedAcrs(upddatedCard : CardsData){
//        self.card[cards.currentCardIndex] = upddatedCard
//        self.cards.resetCurrentCardIndex()
//    }
//}


extension FirstViewController : RateViewContollerDelegate{
    func didRatedAtAppStore() {
        print("called")
        self.isCardseizemorethanThreshHold = false
    }
}

extension FirstViewController {
    
    func cutomizeAlertView(){
        self.alertView.colorForAlertViewBackground = UIColor.white
        self.alertView.percentageRatioWidth = 0.95
        self.alertView.percentageRatioHeight = 0.93
        self.alertView.colorButtonText = RED
        self.alertView.colorCurrentPageIndicator = RED
        self.alertView.colorPageIndicator = RED.withAlphaComponent(0.30)
        self.alertView.colorTitleLabel = RED.withAlphaComponent(0.70)
        self.alertView.colorButtonBottomBackground = RED.withAlphaComponent(0.27)
        
        
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
            print("App already launched")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }
}

extension FirstViewController {
    
        
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
        
    
}
