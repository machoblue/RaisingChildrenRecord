//
//  BabyObserverRealm.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import RealmSwift

import Shared

public class BabyObserverRealm: BabyObserver {
    public static let shared = BabyObserverRealm()
    var realm: Realm!
    var notificationToken: NotificationToken?
    var babies: [BabyModel] = []
    
    private init() {
        self.realm = try! Realm()
        
        let results = realm.objects(Baby.self)
        for baby in results {
            self.babies.append(BabyModel(id: baby.id, name: baby.name, born: baby.born, female: baby.female))
        }
    }
    
    public func observe(with callback: @escaping ([(BabyModel, Change)]) -> Void) {
        let results = realm.objects(Baby.self)
        
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            var myChanges: [(BabyModel, Change)] = []
            switch changes {
            case .initial:
                for baby in self!.babies {
                    myChanges.append((baby, .Init))
                }
            case .update(_, let deletions, let insertions, let modifications):
                for deletion in self!.reverce(deletions){
                    let target = self!.babies[deletion]
                    self!.babies.remove(at: deletion)
                    myChanges.append((target, .Delete))
                }
                for insertion in self!.sort(insertions) {
                    let result = results[insertion]
                    let baby = BabyModel(id: result.id, name: result.name, born: result.born, female: result.female)
                    self!.babies.insert(baby, at: insertion)
                    myChanges.append((baby, .Insert))
                }
                for modification in modifications {
                    let from = results[modification]
                    let to = self!.babies[modification]
                    to.id = from.id
                    to.name = from.name
                    to.born = from.born
                    to.female = from.female
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
    
    public func invalidate() {
        notificationToken?.invalidate()
    }
    
}
