//
//  RecordDaoRealm.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import RealmSwift

public class RecordDaoRealm: RecordDao {
    public static let shared = RecordDaoRealm()
    let realm: Realm!

    private init() {
        self.realm = try! Realm()
    }
    
    public func insertOrUpdate(_ record: RecordModel) {
        try! self.realm.write {
            let results = self.realm.objects(Record.self).filter("id == %@", record.id)
            if results.count == 0 {
                let newRecord = Record()
                newRecord.id = record.id
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
    
    public func delete(_ record: RecordModel) {
        guard let target = self.realm.objects(Record.self).filter("id == %@", record.id).first else { return }
        try! self.realm.write {
            realm.delete(target)
        }
    }

    public func find(id: String) -> RecordModel? {
        guard let r = self.realm.objects(Record.self).filter("id == %@", id).first else { return nil }
        return RecordModel(id: r.id, babyId: r.babyId, userId: r.userId, commandId: r.commandId, dateTime: r.dateTime, value1: r.value1, value2: r.value2, value3: r.value3, value4: r.value4, value5: r.value5)
    }
    
    public func find(babyId: String) -> [RecordModel] {
        var records: [RecordModel] = []
        let results = realm.objects(Record.self).filter("babyId == %@", babyId)
        for r in results {
            records.append(RecordModel(id: r.id, babyId: r.babyId, userId: r.userId, commandId: r.commandId, dateTime: r.dateTime, value1: r.value1, value2: r.value2, value3: r.value3, value4: r.value4, value5: r.value5))
        }
        return records
    }
    
    public func deleteAll() {
        try! realm.write {
            realm.delete(realm.objects(Record.self))
        }
    }
    
}
