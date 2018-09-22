//
//  Record.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import RealmSwift

class Record: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var babyId: String?
    @objc dynamic var userId: String?
    @objc dynamic var commandId: String?
    @objc dynamic var dateTime: Date?
    @objc dynamic var value1: String?
    @objc dynamic var value2: String?
    @objc dynamic var value3: String?
    @objc dynamic var value4: String?
    @objc dynamic var value5: String?
}
