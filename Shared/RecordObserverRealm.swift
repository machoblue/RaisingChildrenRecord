//
//  RecordObserverRealm.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import RealmSwift

import Shared

public class RecordObserverRealm: RecordObserver {
    public static let shared = RecordObserverRealm()
    var realm: Realm!
    var results: Results<Record>!
    var notificationToken: NotificationToken?
    var records: [RecordModel] = []

    private init() {
        self.initRecordRef()
    }
    
    public func reload() {
        self.clear()
        self.initRecordRef()
    }
    
    func initRecordRef() {
        self.realm = try! Realm()
    }
    
    
    public func observe(with callback: @escaping ([(RecordModel, Change)]) -> Void) {
        // do nothing
    }
    
    public func observe(babyId: String, from: Date, to: Date, with callback: @escaping ([(RecordModel, Change)]) -> Void) {
        print("*** RecordObserverRealm.observe ***", babyId, from, to)
        
        self.results = realm.objects(Record.self).filter("babyId == %@ AND %@ <= dateTime AND dateTime <= %@", babyId, from ,to)
        for record in results {
            self.records.append(self.recordModel(from: record))
        }
        
        notificationToken = self.results.observe { [weak self] (changes: RealmCollectionChange) in
            print("*** RecordObserverRealm.observe.results.observe*** ", changes)
            var myChanges: [(RecordModel, Change)] = []
            switch changes {
            case .initial:
                for record in self!.records {
                    myChanges.append((record, .Init))
                }
            case .update(_, let deletions, let insertions, let modifications):
                for deletion in self!.reverce(deletions) {
                    let target = self!.records[deletion]
                    print("*** RecordObserverRealm.observe.results.observe *** deleteTarget:", target)
                    self!.records.remove(at: deletion)
                    
                    myChanges.append((target, .Delete))
                }
                for insertion in self!.sort(insertions) {
                    let result = self!.results[insertion]
                    let record = self!.recordModel(from: result)
                    self!.records.insert(record, at: insertion)
                    myChanges.append((record, .Insert))
                }
                for modification in modifications {
                    let from = self!.results[modification]
                    let to = self!.records[modification]
                    self!.copy(from: from, to: to)
                    myChanges.append((to, .Modify))
                }
                
            case .error(let error):
                fatalError("\(error)")
            }
            callback(myChanges)
        }
    }
    
    deinit {
        clear()
    }
    
    func sort(_ array: [Int]) -> [Int] {
        var temp = array
        temp.sort(by: {$0 < $1})
        return temp
    }
    
    func reverce(_ array: [Int]) -> [Int] {
        var temp = array
        temp.sort(by: {$1 < $0})
        return temp
    }
    
    func recordModel(from: Record) -> RecordModel {
        let to = RecordModel(id: from.id, babyId: from.babyId, userId: from.userId, commandId: from.commandId, dateTime: from.dateTime,
                             value1: from.value1, value2: from.value2, value3: from.value3, value4: from.value4, value5: from.value5)
        return to
    }
    
    func copy(from: Record, to: RecordModel) {
        to.babyId = from.babyId
        to.commandId = from.commandId
        to.userId = from.userId
        to.dateTime = from.dateTime
        to.value1 = from.value1
        to.value2 = from.value2
        to.value3 = from.value3
        to.value4 = from.value4
        to.value5 = from.value5
    }
    
    func clear() {
        notificationToken?.invalidate()
        self.records = []
    }

}
