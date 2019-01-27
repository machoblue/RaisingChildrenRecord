//
//  RecordModel+Realm.swift
//  Shared
//
//  Created by 松島勇貴 on 2019/01/27.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import Foundation

extension RecordModel {
    public convenience init(from record: Record) {
        self.init(
            id: record.id,
            babyId: record.babyId,
            userId: record.userId,
            commandId: record.commandId,
            dateTime: record.dateTime,
            note: record.note,
            number1: record.number1,
            number2: record.number2,
            decimal1: record.decimal1,
            decimal2: record.decimal2,
            text1: record.text1,
            text2: record.text2)
    }
    
    public var realmRecord: Record {
        let newRecord = Record()
        newRecord.id = id
        newRecord.babyId = babyId
        newRecord.commandId = commandId
        newRecord.userId = userId
        newRecord.dateTime = dateTime
        newRecord.note = note
        newRecord.number1 = number1
        newRecord.number2 = number2
        newRecord.decimal1 = decimal1
        newRecord.decimal2 = decimal2
        newRecord.text1 = text1
        newRecord.text2 = text2
        return newRecord
    }
}
