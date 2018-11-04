//
//  Baby.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import RealmSwift

public class Baby: Object {
    @objc dynamic public var id: String = UUID().uuidString
    @objc dynamic public var name: String = "赤ちゃん"
    @objc dynamic public var born: Date = Date()
    @objc dynamic public var female: Bool = true
}
