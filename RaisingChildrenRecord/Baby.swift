//
//  Baby.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import RealmSwift

class Baby: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = "赤ちゃん"
    @objc dynamic var born: Date = Date()
}
