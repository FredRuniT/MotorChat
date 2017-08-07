//
//  ChatVC.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/21/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var messageTxt: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    var user: User?
    var messages = [Messages]()
    
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.alwaysBounceVertical = true
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.title = user?.userName
        
        observeUserMessages()
    }
    
    func observeUserMessages() {
        
        let currentUser = FIRAuth.auth()?.currentUser?.uid
        
        let userMessageRef = FIRDatabase.database().reference().child("user-message").child(currentUser!)
        
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messageRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let messageDict = snapshot.value as? Dictionary<String, AnyObject> {
                    let message = Messages(messageDict: messageDict)
                    
                    if message.chatPartnerId() == self.user?.userID {
                        self.messages.append(message)
                    }

                    self.tableView.reloadData()
                }
            })
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height: CGFloat = 1000
        
        if let text = messages[indexPath.row].text {
            height = estimateFrameForText(text: text).height
        }
        return height + 24
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
        cell.configureCell(message: message)
        
        let width = estimateFrameForText(text: message.text!).width + 20
//        let messageWidth = view.frame.size.width - width
        
        cell.bubbleView.frame.size.width = width
        cell.bubbleView.frame.size.height = cell.frame.size.height - 8
        
        cell.textLbl.frame.size.height = cell.frame.size.height - 8
        cell.textLbl.frame.size.width = cell.bubbleView.frame.size.width
        
        bubbleViewLeftAnchor = cell.bubbleView.leftAnchor.constraint(equalTo: cell.profileImageView.rightAnchor, constant: 8)
        bubbleViewRightAnchor = cell.bubbleView.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -8)
        
        
        cell.bubbleView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 8).isActive = true
        
        cell.textLbl.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -4).isActive = true
        cell.textLbl.leftAnchor.constraint(equalTo: cell.bubbleView.leftAnchor, constant: 8).isActive = true
        cell.textLbl.topAnchor.constraint(equalTo: cell.bubbleView.topAnchor).isActive = true
        cell.textLbl.rightAnchor.constraint(equalTo: cell.bubbleView.rightAnchor, constant: 8).isActive = true
        
        cell.profileImageView.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 8).isActive = true
        cell.profileImageView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        cell.profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        cell.profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            //blue messages
            cell.profileImageView.isHidden = true
            
            cell.bubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1.0)
            
//            bubbleViewRightAnchor?.isActive = false
//            bubbleViewLeftAnchor?.isActive = true
        } else {
            //grey message on left side
            cell.profileImageView.isHidden = false
            
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
            cell.textLbl.textColor = UIColor.black
            
//            bubbleViewLeftAnchor = cell.bubbleView.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 44)
//            bubbleViewRightAnchor = cell.bubbleView.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -messageWidth + 36)
            
            bubbleViewRightAnchor?.isActive = true
            bubbleViewLeftAnchor?.isActive = false

        }
        
        
        return cell
    
    }

    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @IBAction func sendClicked(_ sender: Any) {
        
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        let values = ["text": messageTxt.text!, "toId": user?.userID as Any, "fromId": user?.fromId as Any, "timestamp": timestamp]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
            }
            
            let userMessageRef = FIRDatabase.database().reference().child("user-message")
            
            let messageId = childRef.key
            
            let messageByFromId = userMessageRef.child((self.user?.fromId)!)
            messageByFromId.updateChildValues([messageId: 1])
            
            let messageByToId = userMessageRef.child((self.user?.userID)!)
            messageByToId.updateChildValues([messageId: 1])
        }
        messageTxt.text = nil
    }
}
