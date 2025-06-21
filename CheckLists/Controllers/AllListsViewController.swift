//
//  AllListsViewController.swift
//  CheckLists
//
//  Created by Валерий Новиков on 19.06.25.
//

import UIKit

class AllListsViewController: UITableViewController {
    
    private let cellIdentifier = "AllListsCell"
    var dataModel: DataModel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        configureNavigatioUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        let index = dataModel.indexOfSelectedCheckList
        if index >= 0 && index < dataModel.lists.count {
            let checkListVC = CheckListViewController()
            checkListVC.checklist = dataModel.lists[index]
            navigationController?.pushViewController(checkListVC, animated: true)
        }
    }
    
    // MARK: - Configuration
    
    private func configureDataSource() {
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
    }
    
    private func configureNavigatioUI() {
        title = "CheckLists"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToListDetail))
    }
    
    // MARK: - Actions
    
    @objc private func goToListDetail() {
        let listDetailVC = ListDetailViewController()
        listDetailVC.delegate = self
        navigationController?.pushViewController(listDetailVC, animated: true)
    }
    
    // MARK: - Table view data source
    
    //Number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.lists.count
    }
    
    //Cell template
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let tap = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) {
            cell = tap
        } else {
            cell = UITableViewCell(
                style: .subtitle,
                reuseIdentifier: self.cellIdentifier
            )
        }
        let checkList = dataModel.lists[indexPath.row]
        var text = ""
        if checkList.items.count == 0 {
            text = "No items"
        } else {
            let count = checkList.countUncheckedItems()
            text = count == 0 ? "All done!" : "\(count) Remaining"
        }
        cell.textLabel!.text = "\(checkList.name)"
        cell.detailTextLabel!.text = text
        
        cell.accessoryType = .detailDisclosureButton
        return cell
    }
    
    //Select row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let checkListVC = CheckListViewController()
        checkListVC.checklist = dataModel.lists[indexPath.row]
        navigationController?.pushViewController(checkListVC, animated: true)
        dataModel.indexOfSelectedCheckList = indexPath.row
    }
    
    //Delete row by swiping
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dataModel.lists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    //Accessory pressed
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let listDetailVC = ListDetailViewController()
        listDetailVC.delegate = self
        listDetailVC.listToEdit = dataModel.lists[indexPath.row]
        navigationController?.pushViewController(listDetailVC, animated: true)
    }
    
}

// MARK: - ItemDetailViewController delegate

extension AllListsViewController: ListDetailViewControllerDelegate {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    
    //Added new list
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding list: CheckList) {
        dataModel.lists.append(list)
        dataModel.sortCheckLists()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    //Edited a list
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing list: CheckList) {
        dataModel.sortCheckLists()
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UINavigationController delegate
extension AllListsViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController === self {
            dataModel.indexOfSelectedCheckList = -1
        }
    }
}

#Preview {
    NavigationViewController(rootViewController: AllListsViewController())
}
