//
//  RecordObserverFactory.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Shared

class RecordObserverFactory {
    static let shared = RecordObserverFactory()
    private init(){
    }
    
    func createRecordObserver(_ databaseType: DatabaseType) -> RecordObserver {
        switch databaseType {
        case .Local:
            return RecordObserverRealm.shared
        case .Remote:
            return RecordObserverFirebase.shared
        }
    }
}
