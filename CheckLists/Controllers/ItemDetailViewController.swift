//
//  ItemDetailViewController.swift
//  CheckLists
//
//  Created by Валерий Новиков on 18.06.25.
//

import UIKit

struct ItemDetailValues {
    static let textFieldXPosition: CGFloat = 16
    static let cellIdentifier = "ItemDetailCell"
}

protocol ItemDetailViewControllerDelegate: AnyObject {
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: CheckListItem)
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: CheckListItem)
}

class ItemDetailViewController: UITableViewController {
    
    weak var delegate: ItemDetailViewControllerDelegate?
    var itemToEdit: CheckListItem?
    
    //User Interface Elements
    private var textField: UITextField!
    private var doneBarButton: UIBarButtonItem!
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ItemDetailValues.cellIdentifier)
    }
    
    private func configureUI() {
        configureTextField()
        configureDoneBarButton()
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
    
    // MARK: - Actions
    
    @objc private func done() {
        if var item = itemToEdit {
            item.text = textField.text!
            delegate?.itemDetailViewController(self, didFinishEditing: item)
        } else {
            let item = CheckListItem(text: textField.text!)
            delegate?.itemDetailViewController(self, didFinishAdding: item)
        }
    }
    
    @objc private func cancel() {
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    // MARK: - Table view data source
    
    //Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Cell template
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemDetailValues.cellIdentifier, for: indexPath)
        
        cell.contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: ItemDetailValues.textFieldXPosition),
            textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -ItemDetailValues.textFieldXPosition),
            textField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: cell.contentView.frame.height)
        ])
        cell.selectionStyle = .none
        
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
