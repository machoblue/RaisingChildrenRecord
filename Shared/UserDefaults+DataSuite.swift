//
//  UserDefaults+DataSuite.swift
//  Shared
//
//  Created by 松島勇貴 on 2018/10/30.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    /// - Tag: app_group
    // Note: This project does not share data between iOS and watchOS. Orders placed on the watch will not display in the iOS order history.
    private static let AppGroup = "group.blue.macho.RaisingChildrenRecord"
    
    enum StorageKeys: String {
        case records
    }
    
    static let dataSuite = { () -> UserDefaults in
        guard let dataSuite = UserDefaults(suiteName: AppGroup) else {
            fatalError("Could not load UserDefaults for app group \(AppGroup)")
        }
        
        return dataSuite
    }()
}
