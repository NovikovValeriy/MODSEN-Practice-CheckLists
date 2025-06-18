//
//  CheckListViewController.swift
//  CheckLists
//
//  Created by Валерий Новиков on 17.06.25.
//

import UIKit

class CheckListViewController: UITableViewController {
    
    private var items: [CheckListItem] = []
    static let cellIdentifier = "CheckListCell"
    
    init() {
        super.init(style: .plain)
        dataFill()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        configureNavigationUI()
    }
    
    // MARK: - Configuration
    
    private func configureNavigationUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToAddItemScreen))
        title = "CheckLists"
    }
    
    private func configureDataSource() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CheckListViewController.cellIdentifier)
    }
    
    private func dataFill() {
        items.append(CheckListItem(text: "Walk the dog", checked: true))
        items.append(CheckListItem(text: "Brush my teeth", checked: true))
        items.append(CheckListItem(text: "Learn iOS development", checked: true))
        items.append(CheckListItem(text: "Soccer practice", checked: true))
        items.append(CheckListItem(text: "Eat ice cream", checked: true))
    }
    
    // MARK: - Actions
    
    @objc private func goToAddItemScreen() {
        let addItemVC = AddItemViewController()
        navigationController?.pushViewController(addItemVC, animated: true)
    }
    
    // MARK: - Table view data source
    
    //Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Nmber of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    //Cell template
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CheckListViewController.cellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let item = items[indexPath.row]
        content.text = "\(item.text)"
        cell.contentConfiguration = content
        cell.accessoryType = item.checked ? .checkmark : .none
        
        return cell
    }
    
    //Select row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            items[indexPath.row].checked.toggle()
            cell.accessoryType = items[indexPath.row].checked ? .checkmark : .none
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Delete row by swiping
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
}

#Preview {
    return NavigationViewController(rootViewController: CheckListViewController())
}
