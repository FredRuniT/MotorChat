//
//  MessageFeedCell.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/20/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase

class MessageFeedCell: UITableViewCell {
    
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var img: CircleView!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(message: Messages) {

        if let id = message.chatPartnerId() {
            let ref = FIRDatabase.database().reference()
            let userRef = ref.child("users")
            let userId = userRef.child(id)
            
            userId.observe(.value, with: { (snapshot) in
                if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                    
                    if let profileImageUrl = userDict["profileImageURL"] as? String {
                        self.img.loadImagesUsingCacheWith(urlString: profileImageUrl)
                    }
                    
                    if let userName = userDict["name"] as? String {
                        self.messageLbl.text = userName
                    }
                    
                    if let seconds = message.timestamp {
                        let timeStampDate = NSDate(timeIntervalSince1970: TimeInterval(seconds))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "h:mm a"
                        self.timeLbl.text = dateFormatter.string(from: timeStampDate as Date)
                    }
                }
            })
        }
        subtitleLbl.text = message.text
    }
}
