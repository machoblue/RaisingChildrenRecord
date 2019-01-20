//
//  RecordObserverFirebase.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Firebase

import Shared

class RecordObserverFirebase: RecordObserver {
    static let shared = RecordObserverFirebase()
    var recordsRef: DatabaseReference!

    private init() {
    }
    
    func observe(with callback: @escaping ([(RecordModel, Change)]) -> Void) {
        guard FirebaseUtils.ready() else { return }
        setup()
        recordsRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let recordsDict = snapshot.value as? NSDictionary else { return }
            for key in recordsDict.allKeys {
                let recordDict = recordsDict.value(forKey: key as! String) as! NSDictionary
                guard let newRecord = RecordModel(key: key as! String, dict: recordDict) else { return }
                callback([(newRecord, .Init)])
            }
        })

        recordsRef?.observe(.childAdded, with: { (snapshot) in
            guard let newRecord = RecordModel(from: snapshot) else { return }
            callback([(newRecord, Change.Insert)])
        })

        recordsRef?.observe(.childChanged, with: { (snapshot) in
            guard let newRecord = RecordModel(from: snapshot) else { return }
            callback([(newRecord, Change.Modify)])
        })

        recordsRef?.observe(.childRemoved, with: { (snapshot) in
            guard let newRecord = RecordModel(from: snapshot) else { return }
            callback([(newRecord, Change.Delete)])
        })
    }
    
    func observe(babyId: String, from: Date, to: Date, with callback: @escaping ([(RecordModel, Change)]) -> Void) {
        // do nothing
    }
    
    func setup() {
        recordsRef?.removeAllObservers()

        let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as! String
        recordsRef = Database.database().reference().child("families").child(familyId).child("records")
    }
    
    deinit {
        invalidate()
    }
    
    public func invalidate() {
        recordsRef?.removeAllObservers()
    }
}
