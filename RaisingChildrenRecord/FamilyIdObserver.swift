//
//  FamilyIdObserver.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/13.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Firebase

import Shared

class FamilyIdObserver {
    static let shared = FamilyIdObserver()
    var userDefaults: UserDefaults!
    var familiesRef: DatabaseReference?
    
    private init() {
        self.userDefaults = UserDefaults.standard
    }
    
    func observe(with callback: @escaping (String) -> Void) {
        self.setup()
        self.familiesRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let familiesDict = snapshot.value as? NSDictionary else { return }
            guard let familyId = familiesDict.allKeys.first as? String else { return }
            DispatchQueue.main.async {
                self.userDefaults.register(defaults: [UserDefaults.Keys.FamilyId.rawValue: familyId])
                callback(familyId)
            }
        })
        self.familiesRef?.observe(.value, with: { (snapshot) -> Void in
            guard let familiesDict = snapshot.value as? NSDictionary else { return }
            guard let familyId = familiesDict.allKeys.first as? String else { return }
            DispatchQueue.main.async {
                self.userDefaults.register(defaults: [UserDefaults.Keys.FamilyId.rawValue: familyId])
                callback(familyId)
            }
        })
    }
    
    func setup() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.familiesRef = Database.database().reference().child("users").child(uid).child("families")
    }
    
}
