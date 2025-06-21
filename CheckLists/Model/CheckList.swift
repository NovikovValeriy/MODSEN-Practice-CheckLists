//
//  CheckList.swift
//  CheckLists
//
//  Created by Валерий Новиков on 20.06.25.
//

import UIKit

class CheckList: NSObject, Codable {
    var name: String = ""
    var iconName: String = "No Icon"
    var items: [CheckListItem] = []
    
    init(name: String, iconName: String = "No Icon") {
        self.name = name
        self.iconName = iconName
    }
    
    func countUncheckedItems() -> Int {
        return items.reduce(0) { cnt, item in cnt + (item.checked ? 0 : 1) }
    }
}
