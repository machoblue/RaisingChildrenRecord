//
//  RecordDao.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

public protocol RecordDao {
    func insertOrUpdate(_ record: RecordModel)
    func delete(_ record: RecordModel)
    func find(id: String) -> RecordModel?
    func find(babyId: String) -> [RecordModel]
    func deleteAll()
}
