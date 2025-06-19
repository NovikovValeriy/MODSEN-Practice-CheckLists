//
//  CheckListViewController.swift
//  CheckLists
//
//  Created by Валерий Новиков on 17.06.25.
//

import UIKit

struct CheckListValues {
    static let checkImageXPosition: CGFloat = 16
    static let checkImagePadding: CGFloat = 8
    static let cellIdentifier = "CheckListCell"
}

class CheckListViewController: UITableViewController {
    
    private var items: [CheckListItem] = []
    
    init() {
        super.init(style: .plain)
        //dataFill()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        configureNavigationUI()
        loadCheckListItems()
//        print("Documents folder is: \(documentsDirectory())")
//        print("Data file path is: \(dataFilePath())")
    }
    
    // MARK: - Data persistence
    
    func saveChecklistItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(items)
            try data.write(to: dataFilePath(), options: .atomic)
        } catch {
            print("Error encoding item array: \(error)")
        }
    }
    
    func loadCheckListItems() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                items = try decoder.decode([CheckListItem].self, from: data)
            } catch {
                print("Error decoding item array: \(error)")
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
    
    // MARK: - Configuration
    
    private func configureNavigationUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToAddItemScreen))
        title = "CheckLists"
    }
    
    private func configureDataSource() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: CheckListValues.cellIdentifier)
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
        let addItemVC = ItemDetailViewController()
        addItemVC.delegate = self
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CheckListValues.cellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let item = items[indexPath.row]
        content.text = "\(item.text)"
        
        let checkImage = UIImageView()
        checkImage.image = UIImage(systemName: "checkmark")
        checkImage.isHidden = !item.checked
        checkImage.tag = 1
        checkImage.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        checkImage.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = item.text
        textLabel.tag = 2
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(checkImage)
        cell.contentView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            checkImage.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: CheckListValues.checkImageXPosition),
            checkImage.trailingAnchor.constraint(equalTo: textLabel.leadingAnchor, constant: -CheckListValues.checkImagePadding),
            checkImage.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            
            textLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            textLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
        ])
        
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }
    
    //Select row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            items[indexPath.row].checked.toggle()
            (cell.viewWithTag(1) as! UIImageView).isHidden = !items[indexPath.row].checked
            saveChecklistItems()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Delete row by swiping
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        saveChecklistItems()
    }
    
    //Accessory pressed
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let addItemVC = ItemDetailViewController()
        addItemVC.delegate = self
        addItemVC.itemToEdit = items[indexPath.row]
        navigationController?.pushViewController(addItemVC, animated: true)
    }
}

// MARK: - ItemDetailViewCOntroller delegate

extension CheckListViewController: ItemDetailViewControllerDelegate {
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: CheckListItem) {
        let newRowIndex = items.count
        items.append(item)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        navigationController?.popViewController(animated: true)
        saveChecklistItems()
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: CheckListItem) {
        if let index = items.firstIndex(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                (cell.viewWithTag(2) as! UILabel).text = item.text
            }
        }
        navigationController?.popViewController(animated: true)
        saveChecklistItems()
    }
}

#Preview {
    return NavigationViewController(rootViewController: CheckListViewController())
}
