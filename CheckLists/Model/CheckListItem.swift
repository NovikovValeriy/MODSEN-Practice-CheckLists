//
//  CheckListItem.swift
//  CheckLists
//
//  Created by Валерий Новиков on 17.06.25.
//

import Foundation

class CheckListItem: NSObject, Codable {
    var text = ""
    var checked = true
    
    init(text: String = "", checked: Bool = true) {
        self.text = text
        self.checked = checked
    }
}
