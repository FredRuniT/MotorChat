//
//  User.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/16/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import Foundation

class User {
    
    var userName: String!
    var email: String!
    var userID: String!
    var profileImageUrl: String!
    var fromId: String?
    
    init(userID: String, fromId: String? = nil, userData: Dictionary<String, AnyObject>) {
        self.userID = userID
        
        if let fromId = fromId {
            self.fromId = fromId
        }
        
        if let userName = userData["name"] as? String {
            self.userName = userName
        }
        
        if let email = userData["email"] as? String {
            self.email = email
        }
        
        if let profileImageUrl = userData["profileImageURL"] as? String {
            self.profileImageUrl = profileImageUrl
        }
        
    }
}
