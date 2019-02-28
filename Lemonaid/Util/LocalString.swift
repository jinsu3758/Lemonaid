//
//  LocalString.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 31..
//  Copyright © 2018년 박진수. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
