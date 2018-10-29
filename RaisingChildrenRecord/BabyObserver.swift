//
//  BabyObserver.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/11.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Shared

protocol BabyObserver {
    func observeAdd(with callback: @escaping (BabyModel) -> Void)
    func observeChange(with callback: @escaping (BabyModel) -> Void)
    func observeRemove(with callback: @escaping (BabyModel) -> Void)
    func observe(with callback: @escaping ([(BabyModel, Change)]) -> Void)
}
