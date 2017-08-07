//
//  BubbleView.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/26/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//
import UIKit

class BubbleView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
    
}
