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
        let note = recordDict["note"] as? String
        let number1 = recordDict["number1"] as? Int ?? 0
        let number2 = recordDict["number2"] as? Int ?? 0
        let decimal1 = recordDict["decimal1"] as? Float ?? 0.0
        let decimal2 = recordDict["decimal2"] as? Float ?? 0.0
        let text1 = recordDict["text1"] as? String
        let text2 = recordDict["text2"] as? String
        self.init(id: id, babyId: babyId, userId: userId, commandId: commandId, dateTime: dateTime, note: note, number1: number1, number2: number2, decimal1: decimal1, decimal2: decimal2, text1: text1, text2: text2)
    }
    
    public var dictionary: [String: Any] {
        return [
            "id": id,
            "babyId": babyId,
            "commandId": commandId,
            "userId": Auth.auth().currentUser?.uid ?? "",
            "dateTime": dateTime.timeIntervalSince1970,
            "note": note ?? "",
            "number1": number1,
            "number2": number2,
            "decimal1": decimal1,
            "decimal2": decimal2,
            "text1": text1 ?? "",
            "text2": text2 ?? ""
        ]
    }
}
