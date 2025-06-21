//
//  DataModel.swift
//  CheckLists
//
//  Created by Валерий Новиков on 20.06.25.
//

import Foundation

class DataModel {
    var lists = [CheckList]()
    
    var indexOfSelectedCheckList: Int {
        get {
            return UserDefaults.standard.integer(forKey: "CheckListIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "CheckListIndex")
        }
    }
    
    init() {
        loadCheckLists()
        registerDefaults()
        handleFirstTime()
    }
    
    func sortCheckLists() {
        lists.sort {
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
    
    func saveCheckLists() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(lists)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            print("Error encoding array of lists: \(error)")
        }
    }
    
    func loadCheckLists() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                lists = try decoder.decode([CheckList].self, from: data)
                sortCheckLists()
            } catch {
                print("Error decoding array of lists: \(error)")
            }
        }
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Checklists.plist")
    }
    
    func registerDefaults() {
        let dictionary = ["CheckListIndex": -1, "FirstTime": true] as [String : Any]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    func handleFirstTime() {
        let firstTime = UserDefaults.standard.bool(forKey: "FirstTime")
        if firstTime {
            let checkList = CheckList(name: "List")
            lists.append(checkList)
            indexOfSelectedCheckList = 0
            UserDefaults.standard.set(false, forKey: "FirstTime")
        }
    }
}
