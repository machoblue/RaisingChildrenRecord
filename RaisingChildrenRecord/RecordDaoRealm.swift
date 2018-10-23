//
//  RecordDaoRealm.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import RealmSwift

import CustomRealmObject

class RecordDaoRealm: RecordDao {
    static let shared = RecordDaoRealm()
    let realm: Realm!

    private init() {
        self.realm = try! Realm()
    }
    
    func insertOrUpdate(_ record: RecordModel) {
        try! self.realm.write {
            guard let id = record.id else { return }
            let results = self.realm.objects(Record.self).filter("id == %@", id)
            if results.count == 0 {
                let newRecord = Record()
                newRecord.id = id
                newRecord.babyId = record.babyId
                newRecord.commandId = record.commandId
                newRecord.userId = record.userId
                newRecord.dateTime = record.dateTime
                newRecord.value1 = record.value1
                newRecord.value2 = record.value2
                newRecord.value3 = record.value3
                newRecord.value4 = record.value4
                newRecord.value5 = record.value5
                self.realm.add(newRecord)
            } else {
                let existRecord = results.first!
                existRecord.babyId = record.babyId
                existRecord.commandId = record.commandId
                existRecord.userId = record.userId
                existRecord.dateTime = record.dateTime
                existRecord.value1 = record.value1
                existRecord.value2 = record.value2
                existRecord.value3 = record.value3
                existRecord.value4 = record.value4
                existRecord.value5 = record.value5
            }
        }
    }
    
    func delete(_ record: RecordModel) {
        guard let id = record.id else { return }
        guard let target = self.realm.objects(Record.self).filter("id == %@", id).first else { return }
        try! self.realm.write {
            realm.delete(target)
        }
    }

}
