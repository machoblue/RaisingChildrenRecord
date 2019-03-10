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

    private init() {
    }
    
    public func observe(with callback: @escaping ([(RecordModel, Change)]) -> Void) {
        // do nothing
    }
    
    public func observe(babyId: String, from: Date, to: Date, with callback: @escaping ([(RecordModel, Change)]) -> Void) {
        notificationToken?.invalidate()
        realm = try! Realm()
        
        self.results = realm.objects(Record.self).filter("babyId == %@ AND %@ <= dateTime AND dateTime <= %@", babyId, from ,to)
        
        notificationToken = self.results.observe { [weak self] (changes: RealmCollectionChange) in
            var myChanges: [(RecordModel, Change)] = []
            switch changes {
            case .initial:
                for result in self!.results {
                    myChanges.append((RecordModel(from: result), .Init))
                }
            case .update(_, let deletions, let insertions, let modifications):
                for deletion in deletions {
                    let result = self!.results[deletion]
                    myChanges.append((RecordModel(from: result), .Delete))
                }
                for insertion in insertions {
                    let result = self!.results[insertion]
                    let record = RecordModel(from: result)
                    myChanges.append((record, .Insert))
                }
                for modification in modifications {
                    let result = self!.results[modification]
                    myChanges.append((RecordModel(from: result), .Modify))
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
    
    public func invalidate() {
        notificationToken?.invalidate()
    }
}
