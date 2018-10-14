//
//  RecordObserverRealm.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

class RecordObserverRealm: RecordObserver {
    static let shared = RecordObserverRealm()
    private init() {
    }
    
    func observe(with callback: @escaping ([(RecordModel, Change)]) -> Void) {
    }
    
}
