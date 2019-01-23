//
//  Command.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/16.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

public typealias Command = (id: Commands.Identifier, name: String, image: String, verb: Commands.Verb, unit: Commands.Unit, target: Commands.Target, property: Commands.Property)
public typealias CommandMenu = [Command]

public enum Commands {
    // (baby), verb, unit, object(=target), property
    static public let values: CommandMenu = [
        Command(id: .milk, name: "ミルク", image: "milk", verb: .drink, unit: .ml, target: .milk, property: .none),
        Command(id: .breast, name: "母乳", image: "breast", verb: .drink, unit: .minute, target: .breast, property: .none), // SVO
        Command(id: .babyfood, name: "離乳食", image: "babyfood", verb: .eat, unit: .none, target: .babyfood, property: .none),
        Command(id: .snack, name: "おやつ", image: "snack", verb: .eat, unit: .none, target: .snack, property: .none),
        Command(id: .temperature, name: "体温", image: "temperature", verb: .none, unit: .celcius, target: .none, property: .temperature), // SVC
        Command(id: .poo, name: "うんち", image: "poo", verb: .do, unit: .none, target: .poo, property: .none), // SVO
        Command(id: .sleep, name: "寝る", image: "sleep", verb: .sleep, unit: .none, target: .none, property: .none), // SV
        Command(id: .awake, name: "起きる", image: "awake", verb: .awake, unit: .none, target: .none, property: .none), // SV
        Command(id: .medicine, name: "くすり", image: "medicine", verb: .drink, unit: .none, target: .medicine, property: .none), // SV0
        Command(id: .other, name: "その他", image: "other", verb: .none, unit: .none, target: .none, property: .none) // ???
        // 離乳食を食べた。湿疹がでた。下痢が出た。
    ]
    
    public enum Identifier: Int {
        case milk = 1
        case breast = 2
        case babyfood = 3
        case snack = 4
        case temperature = 5
        case poo = 6
        case sleep = 7
        case awake = 8
        case medicine = 9
        case other = 99
    }
    
    public enum Verb: String {
        case drink = "飲んだ"
        case eat = "食べた"
        case `do` = "した"
        case sleep = "寝た"
        case awake = "起きた"
        case none = ""
    }
    
    public enum Unit: String {
        case ml = "ml"
        case minute = "分"
        case celcius = "℃"
        case none = ""
    }
    
    public enum Target: String {
        case milk = "ミルク"
        case breast = "母乳"
        case babyfood = "離乳食"
        case snack = "おやつ"
        case poo = "うんち"
        case medicine = "くすり"
        case none = ""
    }
    
    public enum Property: String {
        case temperature = "体温"
        case none = ""
    }
    
    static public func command(from id: Int) -> Command? {
        return values.first { $0.id.rawValue == id }
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
