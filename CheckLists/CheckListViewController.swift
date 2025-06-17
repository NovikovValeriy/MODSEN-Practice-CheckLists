//
//  ViewController.swift
//  CheckLists
//
//  Created by Валерий Новиков on 17.06.25.
//

import UIKit

class CheckListViewController: UIViewController {
    
    private var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        view.backgroundColor = .systemBackground
        
        label = UILabel()
        label.text = "Hello, World!"
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

#Preview {
    return CheckListViewController()
}
