//
//  CheckList.swift
//  CheckLists
//
//  Created by Валерий Новиков on 20.06.25.
//

import UIKit

class CheckList: NSObject, Codable {
    var name: String = ""
    var items: [CheckListItem] = []
    
    init(name: String) {
        self.name = name
    }
    
    func countUncheckedItems() -> Int {
        return items.reduce(0) { cnt, item in cnt + (item.checked ? 0 : 1) }
    }
}
