//
//  RecordDaoFactory.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

class RecordDaoFactory {
    static let shared = RecordDaoFactory()
    private init() {
    }
    
    func createRecordDao(_ databaseType: DatabaseType) -> RecordDao {
        switch databaseType {
        case .Local:
            return RecordDaoRealm.shared
        case .Remote:
            return RecordDaoFirebase.shared
        }
    }
}
