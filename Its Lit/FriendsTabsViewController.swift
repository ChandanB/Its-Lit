//
//  FriendsTabsViewController.swift
//  Its Lit
//
//  Created by Chandan Brown on 1/13/17.
//  Copyright © 2017 Gaming Recess. All rights reserved.
//

import UIKit

class FriendsTabsViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assign self for delegate for that ViewController can respond to UITabBarControllerDelegate methods
        self.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create Tab one
        let tabOne = FriendsTableViewController()
        let tabOneBarItem = UITabBarItem(title: "Friends", image: UIImage(named: "add friend"), selectedImage: UIImage(named: "add friend"))
        
        tabOne.tabBarItem = tabOneBarItem
        
        
        // Create Tab two
        let tabTwo = ViewController()
        let tabTwoBarItem2 = UITabBarItem(title: "Messages", image: UIImage(named: "defaultImage2.png"), selectedImage: UIImage(named: "selectedImage2.png"))
        
        tabTwo.tabBarItem = tabTwoBarItem2
        
        
        self.viewControllers = [tabOne, tabTwo]
    }
    
    // UITabBarControllerDelegate method
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected \(viewController.title!)")
    }
}
