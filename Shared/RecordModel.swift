//
//  RecordModel.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

public class RecordModel: NSObject, Codable {
    public var id: String?
    public var babyId: String?
    public var userId: String?
    public var commandId: String?
    public var dateTime: Date?
    public var value1: String? // note
    public var value2: String? // amount1
    public var value3: String? // unit1
    public var value4: String? // amount2
    public var value5: String? // unit2
    
    override public var description: String {
        return "id=\(self.id ?? ""), babyId=\(self.babyId ?? "")"
    }
    
    public init(id: String?, babyId: String?, userId: String?, commandId: String?, dateTime: Date?, value1: String?, value2: String?, value3: String?, value4: String?, value5: String?) {
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
    
    public convenience init(babyId: String?, commandId: String?) {
        self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: commandId, dateTime: Date(), value1: nil, value2: nil, value3: nil, value4: nil, value5: nil)
    }
}
