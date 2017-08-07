//
//  NewMessageVC.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/16/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase

class NewMessageVC: UITableViewController {
        
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchUserData()
    }
    
    func fetchUserData() {
        let ref = FIRDatabase.database().reference()
        let userRef = ref.child("users")
        userRef.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    if let userDict = snap.value as? Dictionary<String, AnyObject> {
                        let currentUserID = FIRAuth.auth()?.currentUser?.uid
                        
                        if snap.key == currentUserID {
                            print("STEPHAN: Found current user")
                        } else {
                            let user = User(userID: snap.key, userData: userDict)
                            user.fromId = currentUserID
                            self.users.append(user)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = users[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NewMessageCell", for: indexPath) as? NewMessageCell {
            if let img = imageCache.object(forKey: (user.profileImageUrl as NSString)) {
                cell.configureCell(user: user, img: img)
                return cell
            } else {
                cell.configureCell(user: user)
            }
        }
        return NewMessageCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        print("STEPHAN: \(user.userName)")
        showChatControllerForUser(user: user)
    }
    
    func showChatControllerForUser(user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
}
