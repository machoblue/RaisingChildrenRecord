//
//  BabyModel+DataSnapshot.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/01/20.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import Foundation
import Firebase
import Shared

extension BabyModel {
    public convenience init?(from snapshot: DataSnapshot) {
        guard let babyDict = snapshot.value as? NSDictionary else { return nil }
        self.init(key: snapshot.key, dict: babyDict)
    }
    
    public convenience init?(key: String, dict babyDict: NSDictionary) {
        let id = key
        let name = babyDict["name"] as! String
        let born = Date(timeIntervalSince1970: babyDict["born"] as! Double)
        let female = babyDict["female"] as! Bool
        self.init(id: id, name: name, born: born, female: female)
    }
}
