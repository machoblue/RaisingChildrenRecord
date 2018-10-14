//
//  BabyModel.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/09.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

class BabyModel {
    var id: String
    var name: String
    var born: Date
    var female: Bool
    init(id: String, name: String, born: Date, female: Bool) {
        self.id = id
        self.name = name
        self.born = born
        self.female = female
    }
}
