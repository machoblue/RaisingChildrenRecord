//
//  BabyDaoFactory.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/10.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

class BabyDaoFactory {
    static let shared = BabyDaoFactory()

    private init() {
    }
    
    func createBabyDao(_ databaseType: DatabaseType) -> BabyDao {
        switch databaseType {
        case .Local:
            return BabyDaoRealm.shared
        case .Remote:
            return BabyDaoFirebase.shared
        }
    }
    
}
