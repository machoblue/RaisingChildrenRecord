//
//  BabyDao.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/10.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

protocol BabyDao {
    func insertOrUpdate(_ baby: BabyModel)
//    func observe(with callback: (BabyModel, Change) -> Void)
    func delete(_ baby: BabyModel)
    func findAll() -> [BabyModel]
}
