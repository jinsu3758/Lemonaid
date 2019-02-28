//
//  UIColor.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 30..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            a: a
        )
    }

}
