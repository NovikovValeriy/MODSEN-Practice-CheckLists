//
//  SceneDelegate.swift
//  CheckLists
//
//  Created by Валерий Новиков on 17.06.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let checkListVC = CheckListViewController()
        let navigationVC = UINavigationController(rootViewController: checkListVC)
        
        window.rootViewController = navigationVC
        window.makeKeyAndVisible()
        
        self.window = window
    }
}

