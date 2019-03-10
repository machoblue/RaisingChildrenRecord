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
    
    var observationKeyToNotificationKey: [ObservationKey: NotificationToken] = [:]
    var observationKeyToRecords: [ObservationKey: [RecordModel]] = [:]

    private init() {
        realm = try! Realm()
    }
    
    public func observe(with callback: @escaping ([(RecordModel, Change)]) -> Void) {
        // do nothing
    }
    
    public func observe(babyId: String, from: Date, to: Date, with callback: @escaping ([(RecordModel, Change)]) -> Void) -> ObservationKey {
        var records: [RecordModel] = []
        
        let results = realm.objects(Record.self).filter("babyId == %@ AND %@ <= dateTime AND dateTime <= %@", babyId, from ,to)
        for record in results {
            records.append(RecordModel(from: record))
        }
        
        let notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            var myChanges: [(RecordModel, Change)] = []
            switch changes {
            case .initial:
                for record in records {
                    myChanges.append((record, .Init))
                }
            case .update(_, let deletions, let insertions, let modifications):
                for deletion in self!.reverce(deletions) {
                    let target = records[deletion]
                    records.remove(at: deletion)
                    
                    myChanges.append((target, .Delete))
                }
                for insertion in self!.sort(insertions) {
                    let result = results[insertion]
                    let record = RecordModel(from: result)
                    records.insert(record, at: insertion)
                    myChanges.append((record, .Insert))
                }
                for modification in modifications {
                    let result = results[modification]
                    records[modification] = RecordModel(from: result)
                    myChanges.append((records[modification], .Modify))
                }
                
            case .error(let error):
                fatalError("\(error)")
            }
            callback(myChanges)
        }
        
        let observationKey = UUID().description
        observationKeyToNotificationKey[observationKey] = notificationToken
        observationKeyToRecords[observationKey] = records
        
        return observationKey
    }
    
    deinit {
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
    
    public func invalidate() {
    }
    
    public func invalidate(_ key: ObservationKey) {
        observationKeyToNotificationKey[key]?.invalidate()
        observationKeyToNotificationKey.removeValue(forKey: key)
        observationKeyToRecords.removeValue(forKey: key)
    }
}
