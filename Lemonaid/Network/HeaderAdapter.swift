//
//  HeaderAdapter.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 7..
//  Copyright © 2018년 박진수. All rights reserved.
//

import Foundation
import Alamofire

class HeaderAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SingleData.instance.deviceId, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    
    
}
