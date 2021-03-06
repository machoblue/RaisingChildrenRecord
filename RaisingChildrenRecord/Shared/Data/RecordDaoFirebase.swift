//
//  RecordDaoFirebase.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Firebase

import Shared

public class RecordDaoFirebase: RecordDao {
    static let shared = RecordDaoFirebase()
    let ref: DatabaseReference!
    
    private init() {
        self.ref = Database.database().reference()
    }
    
    public func insertOrUpdate(_ record: RecordModel) {
        guard FirebaseUtils.ready() else { return }
        guard let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String else { return }
        guard familyId != "" else { return }
        self.ref.child("families").child(familyId).child("records").child(record.id).setValue(record.dictionary)
    }
    
    public func delete(_ record: RecordModel) {
        guard FirebaseUtils.ready() else { return }
        guard let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String else { return }
        guard familyId != "" else { return }
//        guard let babyId = record.babyId else { return }
        self.ref.child("families").child(familyId)/*.child("babies").child(babyId)*/.child("records").child(record.id).removeValue()
    }
    
    public func find(id: String) -> RecordModel? {
        // do nothing
        return nil
    }
    
    public func find(babyId: String) -> [RecordModel] {
        return []
    }
    
    public func find(babyId: String, from: Date, to: Date) -> [RecordModel] {
        return []
    }
    
    public func deleteAll() {
        guard FirebaseUtils.ready() else { return }
        let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as! String
        ref.child("families").child(familyId).child("records").removeValue()
    }
    
}
