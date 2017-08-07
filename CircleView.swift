//
//  CircleView.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/21/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }
}
