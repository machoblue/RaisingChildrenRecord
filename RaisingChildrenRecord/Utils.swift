//
//  Utils.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

class Utils {
    static func convertNilIfEmpty(_ value: String?) -> String? {
        return value == "" ? nil : value
    }
}
