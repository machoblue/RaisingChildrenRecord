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
        var config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.blue.macho.RaisingChildrenRecord")!
        config.fileURL = url.appendingPathComponent("default.realm")
        do {
            try self.init(configuration: config)
        } catch let error as NSError {
            throw error
        }
    }
}
