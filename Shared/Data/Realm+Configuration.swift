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
            schemaVersion: 3,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 3) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                    migration.enumerateObjects(ofType: Record.className()) { oldObject, newObject in
                        if let value1 = oldObject!["value1"] as? String, !value1.isEmpty {
                            newObject!["note"] = value1
                        }
                        
                        guard let commandIdStr = oldObject!["commandId"] as? String, !commandIdStr.isEmpty else { return }
                        guard let commandId = Int(commandIdStr), let command = Commands.Identifier(rawValue: commandId) else { return }
                        
                        newObject!["commandId"] = commandId
                        
                        switch command {
                        case .milk:
                            guard let value2 = oldObject!["value2"] as? String, !value2.isEmpty else { break }
                            newObject!["number1"] = Int(value2)!
                        case .breast:
                            guard let value2 = oldObject!["value2"] as? String, !value2.isEmpty else { break }
                            newObject!["number1"] = Int(value2)!
                        case .temperature:
                            guard let value2 = oldObject!["value2"] as? String, !value2.isEmpty else { break }
                            newObject!["decimal1"] = Float(value2)!
                        case .poo:
                            guard let value2 = oldObject!["value2"] as? String, !value2.isEmpty else { break }
                            newObject!["text1"] = value2
                            guard let value3 = oldObject!["value3"] as? String, !value3.isEmpty else { break }
                            newObject!["text2"] = value3
                        default:
                            // do nothing
                            break
                        }
                    }
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
