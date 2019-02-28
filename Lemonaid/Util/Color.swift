//
//  Color.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 30..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

extension UIColor {

    static let darkBlue = UIColor(hex: 0x34495e)
    static let mainColor = UIColor(hex: 0xfad748)
    static let orange = UIColor(hex: 0xf39c12)
    static let customRed = UIColor(hex: 0xe74c3c)
    static let customLightGray = UIColor(hex: 0x7f7f7f)
    static let customGray = UIColor(hex: 0x5e5e5e)
    static let backColor = UIColor(hex: 0xF4F4F4)
    static let colors = [UIColor.customRed, UIColor.darkBlue, UIColor.red, UIColor.green, UIColor.yellow, UIColor.brown, UIColor.purple]

    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }

    convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            a: a
        )
    }
}
