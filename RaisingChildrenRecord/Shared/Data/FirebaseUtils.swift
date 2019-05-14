//
//  FirebaseUtils.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/12/24.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Firebase
import Shared

class FirebaseUtils {
    static let shared = FirebaseUtils()
    
    let babyObserverRemote: BabyObserver!
    let recordObserverRemote: RecordObserver!
    let babyDaoLocal: BabyDao!
    let recordDaoLocal: RecordDao!
    
    private init() {
        babyObserverRemote = BabyObserverFactory.shared.createBabyObserver(.Remote)
        recordObserverRemote = RecordObserverFactory.shared.createRecordObserver(.Remote)
        babyDaoLocal = BabyDaoFactory.shared.createBabyDao(.Local)
        recordDaoLocal = RecordDaoFactory.shared.createRecordDao(.Local)
    }

    static func ready() -> Bool {
        guard let _ = Auth.auth().currentUser else {
            return false
        }
        
        let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String
        if familyId == nil || familyId == "" {
            return false
        }
        return true
    }
    
    func observeRemote() {
        FamilyIdObserver.shared.observe(with: { (familyId) -> Void in
            self.observeRemoteBabies()
            self.observeRemoteRecords()
        })
    }
    
    func observeRemoteBabies() {
        babyObserverRemote?.observe(with: { (babyAndChangeArray) in
            for babyAndChange in babyAndChangeArray {
                let baby = babyAndChange.0
                let change = babyAndChange.1
                switch change {
                case .Init:
                    self.babyDaoLocal?.insertOrUpdate(baby)
                case .Insert:
                    self.babyDaoLocal?.insertOrUpdate(baby)
                case .Modify:
                    self.babyDaoLocal?.insertOrUpdate(baby)
                case .Delete:
                    self.babyDaoLocal?.delete(baby)
                }
            }
        })
    }
    
    func observeRemoteRecords() {
        self.recordObserverRemote?.observe(with: { (recordAndChangeArray) in
            for recordAndChange in recordAndChangeArray {
                let record = recordAndChange.0
                let change = recordAndChange.1
                switch change {
                case .Init:
                    self.recordDaoLocal?.insertOrUpdate(record)
                case .Insert:
                    self.recordDaoLocal?.insertOrUpdate(record)
                case .Modify:
                    self.recordDaoLocal?.insertOrUpdate(record)
                case .Delete:
                    self.recordDaoLocal?.delete(record)
                }
            }
        })
    }
    
    func invalidateObservation() {
        self.babyObserverRemote.invalidate()
        self.recordObserverRemote.invalidate()
    }
}
