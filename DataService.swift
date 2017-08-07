//
//  DataService.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/15/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService()
    
    private var _REF_USERS = DB_BASE.child("users")
    
}
