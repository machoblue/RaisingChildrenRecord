//
//  BabyDaoImpl.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/10.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import RealmSwift

import Shared

class BabyDaoRealm: BabyDao {
    static let shared = BabyDaoRealm()
    
    let realm: Realm!

    private init() {
        self.realm = try! Realm()
    }
    
    func insertOrUpdate(_ baby: BabyModel) {
        try! realm.write {
            let results = realm.objects(Baby.self).filter("id == %@", baby.id)
            if results.count == 0 {
                let newBaby = Baby()
                newBaby.id = baby.id
                newBaby.name = baby.name
                newBaby.born = baby.born
                newBaby.female = baby.female
                realm.add(newBaby)
            } else {
                let existBaby = results.first!
                existBaby.name = baby.name
                existBaby.born = baby.born
                existBaby.female = baby.female
            }
        }
    }
    
    func delete(_ baby: BabyModel) {
        let realm = try! Realm()
        let target = realm.objects(Baby.self).filter("id == %@", baby.id).first
        if let unwrappedTarget = target {
            try! realm.write {
                realm.delete(unwrappedTarget)
            }
        }
    }
    
    func findAll() -> Array<BabyModel> {
        let realm = try! Realm()
        let results = realm.objects(Baby.self)
        var babies: [BabyModel] = []
        for result in results {
            let baby = BabyModel(id: result.id, name: result.name, born: result.born, female: result.female)
            babies.append(baby)
        }
        return babies
    }
    
    
}
