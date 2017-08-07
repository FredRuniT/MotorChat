//
//  NewMessageCell.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/16/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase

class NewMessageCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(user: User, img: UIImage? = nil) {
        
        titleLbl.text = user.userName!
        subtitleLbl.text = user.email!
        
        if let profileImageUrl = user.profileImageUrl {
            userImg.loadImagesUsingCacheWith(urlString: profileImageUrl)
        }
    }
}
