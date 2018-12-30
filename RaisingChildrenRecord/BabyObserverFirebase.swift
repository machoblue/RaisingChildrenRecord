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
    }
    
    func baby(from snapshot: DataSnapshot) -> BabyModel? {
        guard let babyDict = snapshot.value as? NSDictionary else { return nil }
        return baby(key: snapshot.key, dict: babyDict)
    }
    
    func baby(key: String, dict babyDict: NSDictionary) -> BabyModel? {
        let id = key
        let name = babyDict["name"] as! String
        let born = Date(timeIntervalSince1970: babyDict["born"] as! Double)
        let female = babyDict["female"] as! Bool
        let newBaby = BabyModel(id: id, name: name, born: born, female: female)
        return newBaby
    }
    
    func observe(with callback: @escaping ([(BabyModel, Change)]) -> Void) {
        guard FirebaseUtils.ready() else { return }
        setup()
        babiesRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let babiesDict = snapshot.value as? NSDictionary else { return }
            for key in babiesDict.allKeys {
                let babyDict = babiesDict.value(forKey: key as! String) as! NSDictionary
                guard let newBaby = self.baby(key: key as! String, dict: babyDict) else { return }
                callback([(newBaby, .Init)])
            }
        })
        
        babiesRef.observe(DataEventType.childAdded, with: { (snapshot) in
            print("snapshot:", snapshot)
            guard let newBaby = self.baby(from: snapshot) else {return}
            callback([(newBaby, .Insert)])
        })
        
        babiesRef.observe(DataEventType.childChanged, with: { (snapshot) in
            print("snapshot:", snapshot)
            guard let newBaby = self.baby(from: snapshot) else {return}
            callback([(newBaby, .Modify)])
        })
        
       babiesRef.observe(DataEventType.childRemoved, with: { (snapshot) in
            print("snapshot:", snapshot)
            guard let newBaby = self.baby(from: snapshot) else {return}
            callback([(newBaby, .Delete)])
        })
    }
    
    func setup() {
        babiesRef?.removeAllObservers()
        let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as! String
        babiesRef = Database.database().reference().child("families").child(familyId).child("babies")
    }
    
    deinit {
        invalidate()
    }
    
    public func invalidate() {
        babiesRef?.removeAllObservers()
    }
}
