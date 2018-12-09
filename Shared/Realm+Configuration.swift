//
//  Realm+Configuration.swift
//  Shared
//
//  Created by 松島勇貴 on 2018/12/06.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import RealmSwift

extension Realm {
    convenience init() throws {
        var config = Realm.Configuration()
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.blue.macho.RaisingChildrenRecord")!
        config.fileURL = url.appendingPathComponent("default.realm")
        do {
            try self.init(configuration: config)
        } catch let error as NSError {
            throw error
        }
    }
}
