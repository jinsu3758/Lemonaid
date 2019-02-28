//
//  ViewBorder.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 16..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

extension UIView {
    enum ViewBorder {
        case left
        case right
        case top
        case bottom
    }
    
    func addBorder(toSide side: ViewBorder, withColor color: CGColor, andThickness thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
            case .left:
                border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height)
            case .right:
                border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height)
            case .top:
                border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness)
            case .bottom:
                border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness)
        }
        
        layer.addSublayer(border)
    }
    
}
