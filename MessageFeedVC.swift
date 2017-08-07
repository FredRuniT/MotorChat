//
//  MessageFeedVC.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/15/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase

class MessageFeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    var messages = [Messages]()
    var messagesDictionary = Dictionary<String, Messages>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getUserData()
                
    }
    
    func observeUserMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-message").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let messageDict = snapshot.value as? Dictionary<String, AnyObject> {
                    
                    let message = Messages(messageDict: messageDict)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        
                        
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return message1.timestamp! > message2.timestamp!
                        })
                    }
                    self.tableView.reloadData()
                }
                
            })
        })
        
    }
    
    func getUserData() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let name = userDict["name"]
                self.navBarTitle.title = name as? String
            }
        })
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageFeedCell", for: indexPath) as! MessageFeedCell
        
        cell.configureCell(message: message)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        if let messageId = message.chatPartnerId() {
            let ref = FIRDatabase.database().reference().child("users").child(messageId)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                    
                    let userId = snapshot.key
                    let currentUser = FIRAuth.auth()?.currentUser?.uid
                    let user = User(userID: userId, fromId: currentUser, userData: userDict)
                    self.showChatControllerForUser(user: user)
                }
            })
        }
    }
    
    func showChatControllerForUser(user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    @IBAction func composeClicked(_ sender: Any) {
        performSegue(withIdentifier: "toNewMessageVC", sender: nil)
    }
    

    @IBAction func signOutClicked(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
            print("STEPHAN: Sign out successful!")
        } catch {
            print("STEPHAN: Sign out unsuccesful")
        }

        self.dismiss(animated: true, completion: nil)
    }
}
