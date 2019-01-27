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
                newRecord.note = record.note
                newRecord.number1 = record.number1
                newRecord.number2 = record.number2
                newRecord.decimal1 = record.decimal1
                newRecord.decimal2 = record.decimal2
                newRecord.text1 = record.text1
                newRecord.text2 = record.text2
                self.realm.add(newRecord)
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
        guard let r = self.realm.objects(Record.self).filter("id == %@", id).first else { return nil }
        return RecordModel(id: r.id, babyId: r.babyId, userId: r.userId, commandId: r.commandId, dateTime: r.dateTime, note: r.note, number1: r.number1, number2: r.number2, decimal1: r.decimal1, decimal2: r.decimal2, text1: r.text1, text2: r.text2)
    }
    
    public func find(babyId: String) -> [RecordModel] {
        var records: [RecordModel] = []
        let results = realm.objects(Record.self).filter("babyId == %@", babyId)
        for r in results {
            records.append(RecordModel(id: r.id, babyId: r.babyId, userId: r.userId, commandId: r.commandId, dateTime: r.dateTime, note: r.note, number1: r.number1, number2: r.number2, decimal1: r.decimal1, decimal2: r.decimal2, text1: r.text1, text2: r.text2))
        }
        return records
    }
    
    public func deleteAll() {
        try! realm.write {
            realm.delete(realm.objects(Record.self))
        }
    }
    
}
