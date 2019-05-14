//
//  BabyObserver.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/11.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Shared

public protocol BabyObserver {
    func observe(with callback: @escaping ([(BabyModel, Change)]) -> Void)
    func invalidate()
}
