//
//  RecordModel+DataSnapshot.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/01/20.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import Foundation
import Firebase
import Shared

extension RecordModel {
    
    public convenience init?(from snapshot: DataSnapshot) {
        guard let recordDict = snapshot.value as? NSDictionary else { return nil }
        self.init(key: snapshot.key, dict: recordDict)
    }
    
    public convenience init?(key: String, dict recordDict: NSDictionary) {
        let id = key
        
        guard let babyId = recordDict["babyId"] as? String else { return nil }
        
        let userId = recordDict["userId"] as? String
        
        guard let commandId = recordDict["commandId"] as? Int else { return nil }
        
        let dateTime = Date(timeIntervalSince1970: recordDict["dateTime"] as! Double)
        let value1 = recordDict["value1"] as? String
        let value2 = recordDict["value2"] as? String
        let value3 = recordDict["value3"] as? String
        let value4 = recordDict["value4"] as? String
        let value5 = recordDict["value5"] as? String
        self.init(id: id, babyId: babyId, userId: userId, commandId: commandId, dateTime: dateTime, value1: value1, value2: value2, value3: value3, value4: value4, value5: value5)
    }
    
    public var dictionary: [String: Any] {
        return [
            "id": id,
            "babyId": babyId,
            "commandId": commandId,
            "userId": Auth.auth().currentUser?.uid ?? "",
            "dateTime": dateTime.timeIntervalSince1970,
            "value1": value1 ?? "",
            "value2": value2 ?? "",
            "value3": value3 ?? "",
            "value4": value4 ?? "",
            "value5": value5 ?? ""
        ]
    }
}
