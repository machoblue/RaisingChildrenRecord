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
        let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String
        guard familyId != nil && familyId! != "" else { return }
        let babyDict = ["name": baby.name, "born": baby.born.timeIntervalSince1970, "female": baby.female] as [String : Any]
        self.ref.child("families").child(familyId!).child("babies").child(baby.id).setValue(babyDict)
    }
    
    public func delete(_ baby: BabyModel) {
        let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String
        guard familyId != nil && familyId! != "" else { return }
        self.ref.child("families").child(familyId!).child("babies").child(baby.id).removeValue()
    }
    
    public func findAll() -> [BabyModel] {
        // do nothing
        let babies: [BabyModel] = []
        return babies
    }
    
}
