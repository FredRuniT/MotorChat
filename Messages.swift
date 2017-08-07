//
//  Messages.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/21/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import Foundation
import Firebase

class Messages {
    
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: Int?
    
    init(messageDict: Dictionary<String, AnyObject>) {
        
        if let text = messageDict["text"] as? String {
            self.text = text
        }
        
        if let toId = messageDict["toId"] as? String {
            self.toId = toId
        }
        
        if let fromId = messageDict["fromId"] as? String {
            self.fromId = fromId
        }
        
        if let timestamp = messageDict["timestamp"] as? Int {
            self.timestamp = timestamp
        }
        
    }
    
    func chatPartnerId() -> String? {
        
        if fromId == FIRAuth.auth()?.currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
}
