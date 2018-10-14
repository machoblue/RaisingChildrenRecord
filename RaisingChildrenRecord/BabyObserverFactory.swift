//
//  BabyObserverFactory.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/11.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

class BabyObserverFactory {
    static let shared = BabyObserverFactory()
    
    private init() {
    }
    
    func createBabyObserver(_ observerType: ObserverType) -> BabyObserver {
        switch observerType {
        case .Local:
            return BabyObserverRealm.shared
        case .Remote:
            return BabyObserverFirebase.shared
        }
    }
    
}

enum ObserverType {
    case Local
    case Remote
}
