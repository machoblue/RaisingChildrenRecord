//
//  RecordModel.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

class RecordModel: NSObject {
    var id: String?
    var babyId: String?
    var userId: String?
    var commandId: String?
    var dateTime: Date?
    var value1: String?
    var value2: String?
    var value3: String?
    var value4: String?
    var value5: String?
    
    override var description: String {
        return "id=\(self.id ?? ""), babyId=\(self.babyId ?? "")"
    }
    
    init(id: String?, babyId: String?, userId: String?, commandId: String?, dateTime: Date?, value1: String?, value2: String?, value3: String?, value4: String?, value5: String?) {
        self.id = id
        self.babyId = babyId
        self.userId = userId
        self.commandId = commandId
        self.dateTime = dateTime
        self.value1 = value1
        self.value2 = value2
        self.value3 = value3
        self.value4 = value4
        self.value5 = value5
    }
}
