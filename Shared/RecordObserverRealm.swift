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
    }
    
    public func observe(with callback: @escaping ([(RecordModel, Change)]) -> Void) {
        // do nothing
    }
    
    public func observe(babyId: String, from: Date, to: Date, with callback: @escaping ([(RecordModel, Change)]) -> Void) {
        notificationToken?.invalidate()
        records = []
        realm = try! Realm()
        
        self.results = realm.objects(Record.self).filter("babyId == %@ AND %@ <= dateTime AND dateTime <= %@", babyId, from ,to)
        for record in results {
            self.records.append(self.recordModel(from: record))
        }
        
        notificationToken = self.results.observe { [weak self] (changes: RealmCollectionChange) in
            var myChanges: [(RecordModel, Change)] = []
            switch changes {
            case .initial:
                for record in self!.records {
                    myChanges.append((record, .Init))
                }
            case .update(_, let deletions, let insertions, let modifications):
                for deletion in self!.reverce(deletions) {
                    let target = self!.records[deletion]
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
        invalidate()
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
                             note: from.note, number1: from.number1, number2: from.number2, decimal1: from.decimal1, decimal2: from.decimal2, text1: from.text1, text2: from.text2)
        return to
    }
    
    func copy(from: Record, to: RecordModel) {
        to.babyId = from.babyId
        to.commandId = from.commandId
        to.userId = from.userId
        to.dateTime = from.dateTime
        to.note = from.note
        to.number1 = from.number1
        to.number2 = from.number2
        to.decimal1 = from.decimal1
        to.decimal2 = from.decimal2
        to.text1 = from.text1
        to.text2 = from.text2
    }
    
    public func invalidate() {
        records = []
        notificationToken?.invalidate()
    }
}
