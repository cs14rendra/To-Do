//
//  CreateViewController.swift
//  Happy Days
//
//  Created by surendra kumar on 7/9/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import DatePickerDialog
import UserNotifications
import SwiftDate


protocol CreateViewControllerDelagte {
    func fromCreateViewController()
}


class CreateViewController: UIViewController {

    @IBOutlet var dateLB: UILabel!
    @IBOutlet var textF: UITextField!
    @IBOutlet var notificationBTN: UIButton!
    @IBOutlet var Priority: UIPickerView!
    
    var pickerData = ["Select Priority","A","B","C","D","E"]
    var task = ""
    var isNotificationON : Bool = false
    
    var taskPriority = 1
    var isDone = false
    var mytextF : UITextField!
    var isRegisterForNotification : Bool = false
    let delegateAPP = UIApplication.shared.delegate as? AppDelegate
    
    var delegate : CreateViewControllerDelagte?
    
    var notificationTime : Date = Date()
    var timeInterVal : TimeInterval = 0.0 {
        didSet{
            
            self.notificationTime = Date.init(timeInterval: -self.timeInterVal, since: self.dateToSave)
            

        }
    }
    var dateToSave = Date(){
        didSet{
            self.notificationTime = Date.init(timeInterval: -self.timeInterVal, since: self.dateToSave)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textF.delegate = self
        self.textF.text = "I want to..."
        self.textF.textColor = UIColor.lightGray
        let dateLBGuesture  = UITapGestureRecognizer(target: self, action: #selector(CreateViewController.dateLBTapped))
        dateLBGuesture.numberOfTapsRequired = 1
        self.dateLB.addGestureRecognizer(dateLBGuesture)
        self.dateLB.isUserInteractionEnabled = true
        self.notificationBTN.tintColor = UIColor.lightGray
        
        let dateString  = self.datestringFromDate(date: Date())
        let timeString = self.timeStringFromDate(date: Date())
        let str : String = ("\(dateString) \(timeString)")
        self.dateLB.text = str
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) { accepted,error in
            if !accepted{
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textF.becomeFirstResponder()
    }
    
    func dateLBTapped(){
        print("Date Tapped")
        
        DatePickerDialog().show(title: "Pick Time", doneButtonTitle: "Done", cancelButtonTitle: "", defaultDate: Date(), minimumDate: Date(), maximumDate: nil, datePickerMode: .dateAndTime) { date in
            guard let _ = date else { return }
            self.dateToSave = date!
            let dateString  = self.datestringFromDate(date: date!)
            let timeString = self.timeStringFromDate(date: date!)
            let str : String = ("\(dateString) \(timeString)")
            self.dateLB.text = str
        }
        
    }
    
    @IBAction func notificationButtonClicked(sender : UIButton){
        
        self.requestforNotificationAuthorisation()
        print("You can register when done Clicked")
        guard isRegisterForNotification else {return}
        
        if self.notificationBTN.tintColor == UIColor.lightGray{
            self.notificationBTN.tintColor = UIColor.blue
            self.notificationBTN.setImage(UIImage(named:"BellFilled"), for: .normal)
            self.isNotificationON = true
            self.setNotification()
        }else{
            self.notificationBTN.tintColor = UIColor.lightGray
            self.notificationBTN.setImage(UIImage(named:"BellEmpty"), for: .normal)
            self.isNotificationON = false
        }
    }

    @IBAction func done(_ sender: Any) {
        self.task = self.textF.text!
        guard  task != "" else {
            let alert = UIAlertController(title: "Error", message: "Task can not be Empty", preferredStyle: .alert)
            let alertaction = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(alertaction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let card = CardsData()
        card.task = task
        card.isDone = self.isDone
        card.priority = self.taskPriority
        card.isNotificationON = self.isNotificationON
        card.date = dateToSave as NSDate
        card.id = String(describing: dateToSave)
        
        CardsDataBase.sharedInstance.saveCards(cards: card)
        self.delegate?.fromCreateViewController()
        self.dismiss(animated: true, completion: nil)
        guard isRegisterForNotification else {return}
        delegateAPP?.scheduleNotification(at: self.notificationTime as Date, task: card.task)
        print("WW:notificationTime : \(self.notificationTime)")
        print("WW:dateToSave       : \(self.dateToSave)")
    }
   
    
    
    @IBAction func cancel(_ sender: Any) {
        self.delegate?.fromCreateViewController()
        self.dismiss(animated: true, completion: nil)
    }
    
  

    
    func setNotification(){
        let alert = UIAlertController(title: "Notification!", message: "Notify me before ... minutes.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
            guard self.mytextF.text! != "" else { return }
            print("VALUE")
            let time : Int = Int(self.mytextF.text!)!
            self.timeInterVal = TimeInterval(time*60)
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func requestforNotificationAuthorisation(){
        let alertN : Bool = (UIApplication.shared.currentUserNotificationSettings?.types.contains(.alert))!
        let badgeN : Bool = (UIApplication.shared.currentUserNotificationSettings?.types.contains(.badge))!
        let soundN = (UIApplication.shared.currentUserNotificationSettings?.types.contains(.sound))!
        if  (alertN || badgeN || soundN){
            print("Resistered")
            self.isRegisterForNotification = true
        }else{
            print(" Not Registered")
            self.showEventsAcessDeniedAlert()
            
        }
    }
    
    func showEventsAcessDeniedAlert() {
        let alertController = UIAlertController(title: "Settings", message: "Please Turm On notification in settings to get notify about Task", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            
            
            if let appSettings = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
            }
        }
        
        
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    
    func configurationTextField(textField: UITextField!){
        self.mytextF = textField
        textField.text = "15"
        textField.keyboardType = .numberPad
           
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches")
        self.view.endEditing(true)
        self.textF.resignFirstResponder()
    }
}



extension CreateViewController : UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textF.textColor == UIColor.lightGray{
            textF.text = nil
            textF.textColor = UIColor.black
        }
    }
    
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = textField.superview?.viewWithTag(textField.tag+1) as? UITextField{
            nextTextField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return false
    }

    
}
extension CreateViewController{
    
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

extension CreateViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    
    // PICKER VIEW DELEGATE
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (row == 0) {
            self.taskPriority = 1
            
        }else{
            self.taskPriority = row
        }
    }
    

}

