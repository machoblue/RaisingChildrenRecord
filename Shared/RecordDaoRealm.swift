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
                self.realm.add(record.realmRecord)
            } else {
                let existRecord = results.first!
                existRecord.babyId = record.babyId
                existRecord.commandId = record.commandId
                existRecord.userId = record.userId
                existRecord.dateTime = record.dateTime
                existRecord.note = record.note
                existRecord.number1 = record.number1
                existRecord.number2 = record.number2
                existRecord.decimal1 = record.decimal1
                existRecord.decimal2 = record.decimal2
                existRecord.text1 = record.text1
                existRecord.text2 = record.text2
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
        guard let result = self.realm.objects(Record.self).filter("id == %@", id).first else { return nil }
        return RecordModel(from: result)
    }
    
    public func find(babyId: String) -> [RecordModel] {
        var records: [RecordModel] = []
        let results = realm.objects(Record.self).filter("babyId == %@", babyId)
        for result in results {
            records.append(RecordModel(from: result))
        }
        return records
    }
    
    public func find(babyId: String, from: Date, to: Date) -> [RecordModel] {
        var records: [RecordModel] = []
        let results = realm.objects(Record.self).filter("babyId == %@ AND %@ <= dateTime AND dateTime <= %@", babyId, from ,to)
        for record in results {
            records.append(RecordModel(from: record))
        }
        return records
    }
    
    public func deleteAll() {
        try! realm.write {
            realm.delete(realm.objects(Record.self))
        }
    }
    
}
