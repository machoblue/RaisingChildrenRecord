//
//  RecordDataManager.swift
//  Shared
//
//  Created by 松島勇貴 on 2018/10/30.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation
import Intents

public class RecordDataManager: DataManager<[RecordModel]> {
    
    public convenience init() {
        let storageInfo = UserDefaultsStorageDescriptor(key: UserDefaults.StorageKeys.records.rawValue, keyPath: \UserDefaults.records)
        self.init(storageDescriptor: storageInfo)
    }
    
    override func deployInitialData() {
        self.dataAccessQueue.sync {
            self.managedData = []
        }
    }
    
    /*
    // The following code isn't required.
    private func donateInteraction(for record: RecordModel) {
        let interaction = INInteraction(intent: record.intent, response: nil)
        
        interaction.identifier = record.id
        
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    print("Interaction donation failed: %@", error)
                }
            } else {
                print("Successfully donated interaction")
            }
        }
    }
 */

}

extension RecordDataManager {
    public var records: [RecordModel] {
        return self.dataAccessQueue.sync {
            return self.managedData
        }
    }
    
    public func createRecord(_ record: RecordModel) {
        self.dataAccessQueue.sync {
            managedData.insert(record, at: 0)
        }
        
        writeData()
        
//        donateInteraction(for: record) // This isn't required.
    }
}

extension UserDefaults {
    // For specifying keyPath
    @objc var records: Data? {
        return self.data(forKey: UserDefaults.StorageKeys.records.rawValue)
    }
}
