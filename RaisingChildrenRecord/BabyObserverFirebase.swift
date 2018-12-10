//
//  BabyObserverFirebase.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/11.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation
import Firebase
import Shared

class BabyObserverFirebase: BabyObserver {
    static let shared = BabyObserverFirebase()
    var ref: DatabaseReference!
    var familyId: String?
    var babiesRef: DatabaseReference!
    
    private init() {
        self.ref = Database.database().reference()
        self.familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String
        guard let familyId = self.familyId else { return }
        self.babiesRef = self.ref.child("families").child(familyId).child("babies")
    }
    
    func observeAdd(with callback: @escaping (BabyModel) -> Void) {
        guard let _ = self.familyId else { return }
        self.babiesRef.observe(DataEventType.childAdded, with: { (snapshot) in
            print("snapshot:", snapshot)
            guard let newBaby = self.baby(from: snapshot) else {return}
            callback(newBaby)
        })
    }
    
    func observeChange(with callback: @escaping (BabyModel) -> Void) {
        guard let _ = self.familyId else { return }
        self.babiesRef.observe(DataEventType.childChanged, with: { (snapshot) in
            print("snapshot:", snapshot)
            guard let newBaby = self.baby(from: snapshot) else {return}
            callback(newBaby)
        })
    }
    
    func observeRemove(with callback: @escaping (BabyModel) -> Void) {
        guard let _ = self.familyId else { return }
        self.babiesRef.observe(DataEventType.childRemoved, with: { (snapshot) in
            print("snapshot:", snapshot)
            guard let newBaby = self.baby(from: snapshot) else {return}
            callback(newBaby)
        })
    }
    
    func baby(from snapshot: DataSnapshot) -> BabyModel? {
        guard let babyDict = snapshot.value as? NSDictionary else { return nil }
        let id = snapshot.key
        let name = babyDict["name"] as! String
        let born = Date(timeIntervalSince1970: babyDict["born"] as! Double)
        let female = babyDict["female"] as! Bool
        let newBaby = BabyModel(id: id, name: name, born: born, female: female)
        return newBaby
    }
    
    func observe(with callback: @escaping ([(BabyModel, Change)]) -> Void) {
        // do nothing
    }
    
    deinit {
        self.babiesRef.removeAllObservers()
    }
    
}
