//
//  RoundedShadowButton.swift
//  SayIt
//
//  Created by Ahmed AlOtaibi on 11/25/17.
//  Copyright © 2017 Ahmed AlOtaibi. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {

    // Apply shadow to the flashButton
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.orange.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }

}
