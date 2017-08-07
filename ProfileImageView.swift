//
//  ProfileImageView.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/27/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {
    override func layoutSubviews() {
        layer.cornerRadius = 16
        layer.masksToBounds = true
        self.contentMode = .scaleAspectFill
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
