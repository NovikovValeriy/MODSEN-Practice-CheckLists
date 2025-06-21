//
//  ListDetailViewController.swift
//  CheckLists
//
//  Created by Валерий Новиков on 20.06.25.
//

import UIKit

struct ListDetailValues {
    static let textFieldXPosition: CGFloat = 16
    static let iconPadding: CGFloat = 8
    static let accessoryButtonTrailingConstant: CGFloat = 16
}

protocol ListDetailViewControllerDelegate: AnyObject {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAdding list: CheckList)
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditing list: CheckList)
}

class ListDetailViewController: UITableViewController {
    
    weak var delegate: ListDetailViewControllerDelegate?
    var listToEdit: CheckList?
    var iconName = "Folder"
    
    private let cellIdentifier = "ListDetailCell"
    
    //User Interface Elements
    private var textField: UITextField!
    private var doneBarButton: UIBarButtonItem!
    private var iconImageView: UIImageView!
    private var accessoryButton: UIButton!
    
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
        configureIconImageView()
        configureAccessoryButton()
        configureNavBar()
    }
    
    private func configureTextField() {
        textField = UITextField()
        textField.font = UIFont(name: "System", size: 17)
        textField.placeholder = "Name of the List"
        textField.adjustsFontSizeToFitWidth = false
        textField.autocapitalizationType = .sentences
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(done), for: .editingDidEndOnExit)
        textField.delegate = self
        
        if let list = listToEdit {
            textField.text = list.name
        }
    }
    
    private func configureDoneBarButton() {
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        if listToEdit == nil {
            doneBarButton.isEnabled = false
        }
    }
    
    private func configureIconImageView() {
        iconImageView = UIImageView()
        if let list = listToEdit {
            iconName = list.iconName
        }
        iconImageView.image = UIImage(named: iconName)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.isUserInteractionEnabled = false
    }
    
    private func configureAccessoryButton() {
        accessoryButton = UIButton()
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(weight: .medium)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        accessoryButton.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: accessoryButton.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: accessoryButton.centerYAnchor),
        ])
        accessoryButton.tintColor = .placeholderText
        accessoryButton.isUserInteractionEnabled = false
    }
    
    private func configureNavBar() {
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        if listToEdit != nil {
            navigationItem.title = "Edit List"
        } else {
            navigationItem.title = "Add List"
        }
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - Actions
    
    @objc private func done() {
        if let list = listToEdit {
            list.name = textField.text!
            list.iconName = iconName
            delegate?.listDetailViewController(self, didFinishEditing: list)
        } else {
            let list = CheckList(name: textField.text!)
            list.iconName = iconName
            delegate?.listDetailViewController(self, didFinishAdding: list)
        }
    }
    
    @objc private func cancel() {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    // MARK: - Table view data source
    
    //Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //Number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //Cell template
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.contentView.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: ListDetailValues.textFieldXPosition),
                textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -ListDetailValues.textFieldXPosition),
                textField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                textField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                textField.heightAnchor.constraint(equalToConstant: cell.contentView.frame.height)
            ])
            cell.selectionStyle = .none
        default:
            cell.textLabel!.text = "Icon"
            cell.contentView.addSubview(iconImageView)
            cell.contentView.addSubview(accessoryButton)
            NSLayoutConstraint.activate([
                iconImageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                iconImageView.heightAnchor.constraint(equalTo: cell.heightAnchor, constant: -ListDetailValues.iconPadding),
                iconImageView.widthAnchor.constraint(equalTo: cell.heightAnchor, constant: -ListDetailValues.iconPadding),
                accessoryButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -ListDetailValues.accessoryButtonTrailingConstant),
                accessoryButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                iconImageView.trailingAnchor.constraint(equalTo: accessoryButton.leadingAnchor)
            ])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let iconPickerVC = IconPickerViewController()
        iconPickerVC.delegate = self
        navigationController?.pushViewController(iconPickerVC, animated: true)
    }
    
    //Text field selection disabling
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 1 ? indexPath : nil
    }
}

extension ListDetailViewController: UITextFieldDelegate {
    
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

extension ListDetailViewController: IconPickerViewControllerDelegate {
    func iconPicker(_ controller: IconPickerViewController, didPick iconName: String) {
        self.iconName = iconName
        iconImageView.image = UIImage(named: iconName)
        navigationController?.popViewController(animated: true)
    }
}

#Preview {
    NavigationViewController(rootViewController: ListDetailViewController())
}
