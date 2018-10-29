//
//  RecordObserver.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Shared

protocol RecordObserver {
    func observe(with callback: @escaping ([(RecordModel, Change)]) -> Void)
    func observe(babyId: String, from: Date, to: Date, with callback: @escaping([(RecordModel, Change)]) -> Void)
    func reload()
}
