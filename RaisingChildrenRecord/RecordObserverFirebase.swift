//
//  RecordObserverFirebase.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Firebase

class RecordObserverFirebase: RecordObserver {
    static let shared = RecordObserverFirebase()
    var recordsRef: DatabaseReference!

    private init() {
        initRecordsRef()
    }
    
    func observe(with callback: @escaping ([(RecordModel, Change)]) -> Void) {
        recordsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let recordsDict = snapshot.value as? NSDictionary else { return }
            for key in recordsDict.allKeys {
                let recordDict = recordsDict.value(forKey: key as! String) as! NSDictionary
                guard let newRecord = self.record(key: key as! String, dict: recordDict) else { return }
                callback([(newRecord, .Init)])
            }
        })

        recordsRef.observe(.childAdded, with: { (snapshot) in
            guard let newRecord = self.record(from: snapshot) else { return }
            callback([(newRecord, Change.Insert)])
        })

        recordsRef.observe(.childChanged, with: { (snapshot) in
            guard let newRecord = self.record(from: snapshot) else { return }
            callback([(newRecord, Change.Modify)])
        })

        recordsRef.observe(.childRemoved, with: { (snapshot) in
            guard let newRecord = self.record(from: snapshot) else { return }
            callback([(newRecord, Change.Delete)])
        })
    }

    func record(from snapshot: DataSnapshot) -> RecordModel? {
        let recordDict = snapshot.value as! NSDictionary
        return self.record(key: snapshot.key, dict: recordDict)
    }
    
    func record(key: String, dict recordDict: NSDictionary) -> RecordModel? {
        let id = key
        let babyId = recordDict["babyId"] as? String
        let userId = recordDict["userId"] as? String
        let commandId = recordDict["commandId"] as? String
        let dateTime = Date(timeIntervalSince1970: recordDict["dateTime"] as! Double)
        let value1 = recordDict["value1"] as? String
        let value2 = recordDict["value2"] as? String
        let value3 = recordDict["value3"] as? String
        let value4 = recordDict["value4"] as? String
        let value5 = recordDict["value5"] as? String
        return RecordModel(id: id, babyId: babyId, userId: userId, commandId: commandId, dateTime: dateTime, value1: value1, value2: value2, value3: value3, value4: value4, value5: value5)
    }
    
    func reload() {
        self.clear()
        self.initRecordsRef()
    }
    
    func initRecordsRef() {
        guard let familyId = UserDefaults.standard.object(forKey: UserDefaultsKey.FamilyId.rawValue) as? String else { return }

        self.recordsRef = Database.database().reference().child("families").child(familyId).child("records")
    }
    
    func clear() {
        self.recordsRef.removeAllObservers()
    }
    
    deinit {
        self.clear()
    }
}
