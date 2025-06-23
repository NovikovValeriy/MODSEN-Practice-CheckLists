//
//  ItemDetailViewController.swift
//  CheckLists
//
//  Created by Валерий Новиков on 18.06.25.
//

import UIKit

struct ItemDetailValues {
    static let textFieldXPosition: CGFloat = 16
}

protocol ItemDetailViewControllerDelegate: AnyObject {
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: CheckListItem)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: CheckListItem)
}

class ItemDetailViewController: UITableViewController {
    
    weak var delegate: ItemDetailViewControllerDelegate?
    var itemToEdit: CheckListItem?
    
    private let cellIdentifier = "ItemDetailCell"
    
    //User Interface Elements
    private var textField: UITextField!
    private var doneBarButton: UIBarButtonItem!
    private var shouldRemindSwitch: UISwitch!
    private var datePicker: UIDatePicker!
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK: = Configuration
    
    private func configureDataSource() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
    }
    
    private func configureUI() {
        configureTextField()
        configureDoneBarButton()
        configureSwitch()
        configureDatePicker()
        configureNavBar()
    }
    
    private func configureTextField() {
        textField = UITextField()
        textField.font = UIFont(name: "System", size: 17)
        textField.placeholder = "Name of the Item"
        textField.adjustsFontSizeToFitWidth = false
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(done), for: .editingDidEndOnExit)
        textField.delegate = self
        
        if let item = itemToEdit {
            textField.text = item.text
        }
    }
    
    private func configureDoneBarButton() {
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        if itemToEdit == nil {
            doneBarButton.isEnabled = false
        }
    }
    
    private func configureNavBar() {
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        if itemToEdit != nil {
            navigationItem.title = "Edit Item"
        } else {
            navigationItem.title = "Add Item"
        }
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureSwitch() {
        shouldRemindSwitch = UISwitch()
        shouldRemindSwitch.onTintColor = UIColor.globalTint()
        if let item = itemToEdit {
            shouldRemindSwitch.isOn = item.shouldRemind
        }
        
        shouldRemindSwitch.addTarget(self, action: #selector(shouldRemindToggled), for: .valueChanged)
    }
    
    private func configureDatePicker() {
        datePicker = UIDatePicker()
        if let item = itemToEdit {
            datePicker.date = item.dueDate
        } else {
            let calendar = Calendar.current
            datePicker.date = calendar.date(byAdding: .day, value: 1, to: .now) ?? Date.now
        }
    }
    
    // MARK: - Actions
    
    @objc private func done() {
        if var item = itemToEdit {
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = datePicker.date
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishEditing: item)
        } else {
            let item = CheckListItem()
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.isOn
            item.dueDate = datePicker.date
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishAdding: item)
        }
    }
    
    @objc private func cancel() {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    @objc private func shouldRemindToggled() {
        if shouldRemindSwitch.isOn {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] (granted, error) in
                guard let self = self else { return }
                if !granted {
                    self.shouldRemindSwitch.isOn = false
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    //Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //Number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default:
            break
        }
        return 1
    }
    
    //Cell template
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.contentView.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: ItemDetailValues.textFieldXPosition),
                textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -ItemDetailValues.textFieldXPosition),
                textField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                textField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                textField.heightAnchor.constraint(equalToConstant: cell.contentView.frame.height)
            ])
            cell.selectionStyle = .none
        case 1:
            switch indexPath.row {
            case 0:
                cell.accessoryView = shouldRemindSwitch
                cell.textLabel!.text = "Remind Me"
                break
            case 1:
                cell.accessoryView = datePicker
                cell.textLabel!.text = "Due Date"
                break
            default :
                break
            }
        default:
            break
        }
        
        return cell
    }
    
    //Selection disabling
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension ItemDetailViewController: UITextFieldDelegate {
    
    //Disabling Done button when text changes to empty
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
    
    //Disabling Done button when text clears with a Clear button
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }
}

#Preview {
    NavigationViewController(rootViewController: ItemDetailViewController())
}
