//
//  ViewController.swift
//  It's Lit
//
//  Created by Chandan Brown on 7/22/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//


import UIKit
import Firebase

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class FriendsTableViewController: UITableViewController, UISearchControllerDelegate {
    
    // Index
    var cellIndexPath: IndexPath!
    var location = CGPoint.zero
    
    // Search
    let searchController = UISearchController(searchResultsController: nil)
    lazy var searchBar : UISearchBar = UISearchBar()
    var searchActive   : Bool = false
    
    // Instance
    var chatLogController : ChatLogController?
    var viewController    : ViewController?
    
    // Data to go in cells
    var messagesDictionary = [String: Message]()
    var messages = [Message]()
    var filtered = [User]()
    var currentUser: User?
    let cellId = "cellId"
    var users  = [User]()
    var timer: Timer?
    var lit = [Lit]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        navigationController?.navigationItem.title  = "Search For Friends"
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        searchController.searchBar.tintColor = UIColor.rgb(51, green: 21, blue: 1)
        searchController.searchBar.searchBarStyle = UISearchBarStyle.prominent
        searchController.searchBar.placeholder = " Search For Friends"
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        fetchUser()
        observeUserMessages()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        if let splitViewController = splitViewController {
            let controllers = splitViewController.viewControllers
            chatLogController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ChatLogController
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let message = self.messages[(indexPath as NSIndexPath).row]
        if let chatPartnerId = message.chatPartnerId() {
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("Failed to delete message:", error as Any)
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
            })
        }
    }
    
    
    func observeUserMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            print(snapshot.key)
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
            
        }, withCancel: nil)
        
    }
    
    fileprivate func fetchMessageWithMessageId(_ messageId: String) {
        let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
        })
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func showChatControllerForUser(_ user: User, _ currentUser: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        chatLogController.currentUser = currentUser
        navigationController?.pushViewController(chatLogController, animated: true)
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
            return messages.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        var user: User
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filtered[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = user.name
            cell.timeLabel.text = ""
            if let profileImageUrl = user.profileImageUrl {
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            }
            cell.message = nil
            
        } else {
            let message = messages[(indexPath as NSIndexPath).row]
            cell.message = message
        }
        return cell
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filtered = users.filter({( user : User) -> Bool in
            let categoryMatch = (scope == "All") || (user.name == scope)
            return categoryMatch && (user.name?.lowercased().contains(searchText.lowercased()))!
        })
        self.attemptReloadOfTable()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.isActive && searchController.searchBar.text != ""  {
            var user: User
            
            user = self.filtered[(indexPath as NSIndexPath).row]
            self.showChatControllerForUser(user, self.currentUser!)
            
        } else {
            let message = messages[(indexPath as NSIndexPath).row]
            
            guard let chatPartnerId = message.chatPartnerId() else {
                return
            }
            
            let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let user = User()
                user.id = chatPartnerId
                user.setValuesForKeys(dictionary)
                self.showChatControllerForUser(user, self.currentUser!)
                
            }, withCancel: nil)
        }
        
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
                let controller = (segue.destination as! UINavigationController).topViewController as! ChatLogController
                controller.user = user
                controller.currentUser = self.currentUser
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
        self.attemptReloadOfTable()
    }
}

extension FriendsTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Search For Friends"
        // let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
