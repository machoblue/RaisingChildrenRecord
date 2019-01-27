//
//  Record.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import RealmSwift

public class Record: Object {
    @objc dynamic public var id = UUID().uuidString
    @objc dynamic public var babyId: String = ""
    @objc dynamic public var userId: String?
    @objc dynamic public var commandId: Int = 99 // other
    @objc dynamic public var dateTime: Date = Date()
    @objc dynamic public var note: String?
    @objc dynamic public var number1: Int = 0
    @objc dynamic public var number2: Int = 0
    @objc dynamic public var decimal1: Float = 0.0
    @objc dynamic public var decimal2: Float = 0.0
    @objc dynamic public var text1: String?
    @objc dynamic public var text2: String?
}
