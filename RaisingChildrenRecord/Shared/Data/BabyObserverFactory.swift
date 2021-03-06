//
//  BabyObserverFactory.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/11.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Shared

public class BabyObserverFactory {
    public static let shared = BabyObserverFactory()
    
    private init() {
    }
    
    public func createBabyObserver(_ databaseType: DatabaseType) -> BabyObserver {
        switch databaseType {
        case .Local:
            return BabyObserverRealm.shared
        case .Remote:
            return BabyObserverFirebase.shared
        }
    }
    
}
