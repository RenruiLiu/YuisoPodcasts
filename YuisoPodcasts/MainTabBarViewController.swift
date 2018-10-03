//
//  MainTabBarViewController.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 3/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .purple
        
        let favoritesController = ViewController()
        favoritesController.tabBarItem.title = "Favorites"
        favoritesController.tabBarItem.image = #imageLiteral(resourceName: "favorites")
        
        let searchNavController = UINavigationController(rootViewController: ViewController())
        searchNavController.tabBarItem.title = "Search"
        searchNavController.tabBarItem.image = #imageLiteral(resourceName: "search")
        
        let downloadController = ViewController()
        downloadController.tabBarItem.title = "Downloads"
        downloadController.tabBarItem.image = #imageLiteral(resourceName: "downloads")
        
        viewControllers = [favoritesController,searchNavController,downloadController]
    }

}
