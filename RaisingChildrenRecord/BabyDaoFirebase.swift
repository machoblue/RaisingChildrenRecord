//
//  BabyDaoImplFirebase.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/10.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation
import Firebase

import Shared

public class BabyDaoFirebase: BabyDao {

    public static let shared = BabyDaoFirebase()
    
    let ref: DatabaseReference!

    private init() {
        self.ref = Database.database().reference()
    }
    
    public func insertOrUpdate(_ baby: BabyModel) {
        guard FirebaseUtils.ready() else { return }
        let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as! String
        let babyDict = ["name": baby.name, "born": baby.born.timeIntervalSince1970, "female": baby.female] as [String : Any]
        self.ref.child("families").child(familyId).child("babies").child(baby.id).setValue(babyDict)
    }
    
    public func delete(_ baby: BabyModel) {
        guard FirebaseUtils.ready() else { return }
        let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as! String
        self.ref.child("families").child(familyId).child("babies").child(baby.id).removeValue()
    }
    
    public func findAll() -> [BabyModel] {
        // do nothing
        let babies: [BabyModel] = []
        return babies
    }
    
    public func find(_ id: String) -> BabyModel? {
        return nil
    }
    
    public func deleteAll() {
        guard FirebaseUtils.ready() else { return }
        let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as! String
        ref.child("families").child(familyId).child("babies").removeValue()
    }
    
}
