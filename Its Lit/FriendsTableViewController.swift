//
//  ViewController.swift
//  PlayerGround 5.0
//
//  Created by Chandan Brown on 7/22/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//


import UIKit
import Firebase

class FriendsTableViewController: UITableViewController, UISearchControllerDelegate {
    var location = CGPoint.zero
    var cellIndexPath: IndexPath!
   
    var profileViewController: ProfileViewController? = nil
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var searchBar: UISearchBar = UISearchBar()
    
    let cellId = "cellId"
    
    var users = [User]()
    
    var searchActive : Bool = false
    var filtered = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        navigationController?.navigationItem.title = "Search For Friends"
        
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        

        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
        searchController.searchBar.placeholder = " Search..."
        searchController.searchBar.sizeToFit()
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.tintColor = UIColor.rgb(51, green: 21, blue: 1)
   //     searchController.searchBar.backgroundColor = UIColor.rgb(254, green: 209, blue: 67)
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.delegate = self
      //  navigationItem.titleView = searchController.searchBar
        
        fetchUser()
        
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            profileViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ProfileViewController
        }

    }
    
    func showChatControllerForUser(_ user: User) {
        let profileController = ProfileViewController()
        profileController.user = user
        navigationController?.pushViewController(profileController, animated: true)
        
    }
    
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            }
            
            }, withCancel: nil)
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != ""  {
            return filtered.count
        } else {
        return users.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        var user: User
       
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filtered[(indexPath as NSIndexPath).row]
         
        } else {
            user = users[(indexPath as NSIndexPath).row]
         }
    
       
        cell.textLabel?.text = user.name
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }

        return cell
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filtered = users.filter({( user : User) -> Bool in
            let categoryMatch = (scope == "All") || (user.name == scope)
            return categoryMatch && (user.name?.lowercased().contains(searchText.lowercased()))!
        })
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var viewController: ViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileController = ProfileViewController()
        let navController = UINavigationController(rootViewController: profileController)
        present(navController, animated: true, completion: nil)
        var user: User
        if searchController.isActive && searchController.searchBar.text != ""  {
             user = self.filtered[(indexPath as NSIndexPath).row]
        } else {
             user = self.users[(indexPath as NSIndexPath).row]
        }
        profileController.setupNavBarWithUser(user)

        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let user: User
                if searchController.isActive && searchController.searchBar.text != "" {
                    user = filtered[(indexPath as NSIndexPath).row]
                } else {
                    user = users[(indexPath as NSIndexPath).row]
                }
                let controller = (segue.destination as! UINavigationController).topViewController as! ProfileViewController
                controller.user = user
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

}


extension FriendsTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
        self.tableView.reloadData()
    }
}

extension FriendsTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
       // let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}










