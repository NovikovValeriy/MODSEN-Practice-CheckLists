//
//  CheckListItem.swift
//  CheckLists
//
//  Created by Валерий Новиков on 17.06.25.
//

import Foundation
import UserNotifications

class CheckListItem: NSObject, Codable {
    var text = ""
    var checked = true
    var dueDate = Date()
    var shouldRemind = false
    var itemID = -1
    
    override init() {
        super.init()
        self.itemID = DataModel.nextCheckListItemID()
    }
    
    init(text: String = "", checked: Bool = true) {
        self.text = text
        self.checked = checked
        self.itemID = DataModel.nextCheckListItemID()
    }
    
    func scheduleNotification() {
        removeNotification()
        if shouldRemind && dueDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Reminder"
            content.body = text
            content.sound = .default
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func removeNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
    }
    
    deinit() {
        removeNotification()
    }
}
