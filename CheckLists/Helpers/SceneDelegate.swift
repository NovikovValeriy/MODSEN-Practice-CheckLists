//
//  SceneDelegate.swift
//  CheckLists
//
//  Created by Валерий Новиков on 17.06.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let dataModel = DataModel()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let rootVC = AllListsViewController()
        let navigationVC = UINavigationController(rootViewController: rootVC)
        
        window.rootViewController = navigationVC
        window.tintColor = UIColor.globalTint()
        window.makeKeyAndVisible()
        
        self.window = window
        
        let controller = navigationVC.viewControllers.first as! AllListsViewController
        controller.dataModel = dataModel
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        saveData()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        saveData()
    }
    
    func saveData() {
        dataModel.saveCheckLists()
    }
}

