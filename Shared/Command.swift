//
//  Command.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/16.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

public class Command {
    // (baby), verb, unit, object(=target), property
    static public let values: [(id: Int, name: String, image: String, verb: String, unit: String, target: String, property: String)] = [
        (1, "ミルク", "milk", "飲んだ", "ml", "ミルク", ""), // SVO
        (2, "母乳", "breast", "飲んだ", "分", "母乳", ""), // SVO
        (3, "体温", "temperature", "", "℃", "", "体温"), // SVC
        (4, "うんち", "poo", "した", "", "うんち", ""), // SVO
        (5, "寝る", "sleep", "寝た", "", "", ""), // SV
        (6, "起きる", "awake", "起きた", "", "", ""), // SV
        (8, "くすり", "medicine", "飲んだ", "", "くすり", ""), // SV0
        (7, "その他", "other", "", "", "", "") // ???
        
        // 離乳食を食べた。湿疹がでた。下痢が出た。
    ]
    
    static public func name(id: Int) -> String? {
        var name: String?
        for value in values {
            if (value.id == id) {
                name = value.name
            }
        }
        return name
    }
    
    static public func image(id: Int) -> String? {
        var image: String?
        for value in values {
            if (value.id == id) {
                image = value.image
            }
        }
        return image
    }
    
    public enum HardnessOption: String {
        case soft = "soft"
        case normal = "normal"
        case hard = "hard"
        
        public static let all: [HardnessOption] = [.soft, .normal, .hard]
        
        public var label: String {
            switch self {
            case .soft:
                return "柔らかめ"
            case .normal:
                return "普通"
            case .hard:
                return "硬め"
            }
        }
    }
    
    public enum AmountOption: String {
        case little = "little"
        case normal = "normal"
        case much = "much"
        
        public static let all: [AmountOption] = [.little, .normal, .much]
        
        public var label: String {
            switch self {
            case .little:
                return "少なめ"
            case .normal:
                return "普通"
            case .much:
                return "多め"
            }
        }
    }
}
