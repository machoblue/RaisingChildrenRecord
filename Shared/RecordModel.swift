//
//  RecordModel.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/14.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

public class RecordModel: NSObject, Codable {
    public var id: String = UUID().uuidString
    public var babyId: String
    public var userId: String?
    public var commandId: Int = 99 // other
    public var dateTime: Date = Date()
    public var value1: String? // note
    public var value2: String? {
        didSet {
            guard let value2 = value2, !value2.isEmpty else { return }
            switch commandId {
            case 1:
                UserDefaults.dataSuite.register(defaults: [UserDefaults.Keys.MilkMillilitters.rawValue: value2])
            case 2:
                UserDefaults.dataSuite.register(defaults: [UserDefaults.Keys.BreastMinutes.rawValue: value2])
            case 5:
                UserDefaults.dataSuite.register(defaults: [UserDefaults.Keys.Temperature.rawValue: value2])
            case 6:
                UserDefaults.dataSuite.register(defaults: [UserDefaults.Keys.PooHardness.rawValue: value2])
            default:
                break
            }
        }
    }// amount1
    public var value3: String? {
        didSet {
            guard let value3 = value3, !value3.isEmpty else { return }
            switch commandId {
            case 6:
                UserDefaults.dataSuite.register(defaults: [UserDefaults.Keys.PooAmount.rawValue: value3])
            default:
                break
            }
        }
    }// amount2
    public var value4: String? // unit1
    public var value5: String? // unit2
    
    override public var description: String {
        return "id=\(self.id), babyId=\(self.babyId)"
    }
    
    public init(id: String, babyId: String, userId: String?, commandId: Int, dateTime: Date, value1: String?, value2: String?, value3: String?, value4: String?, value5: String?) {
        self.id = id
        self.babyId = babyId
        self.userId = userId
        self.commandId = commandId
        self.dateTime = dateTime
        self.value1 = value1
        if let value2 = value2, !value2.isEmpty {
            self.value2 = value2
        } else {
            switch commandId {
            case 1:
                self.value2 = UserDefaults.dataSuite.object(forKey: UserDefaults.Keys.MilkMillilitters.rawValue) as? String ?? "100"
            case 2:
                self.value2 = UserDefaults.dataSuite.object(forKey: UserDefaults.Keys.BreastMinutes.rawValue) as? String ?? "10"
            case 5:
                self.value2 = UserDefaults.dataSuite.object(forKey: UserDefaults.Keys.Temperature.rawValue) as? String ?? "36.5"
            case 6:
                self.value2 = UserDefaults.dataSuite.object(forKey: UserDefaults.Keys.PooHardness.rawValue) as? String ?? "normal"
            default:
                break
            }
        }
        if let value3 = value3, !value3.isEmpty {
            self.value3 = value3
            
        } else {
            switch commandId {
            case 6:
                self.value3 = UserDefaults.dataSuite.object(forKey: UserDefaults.Keys.PooAmount.rawValue) as? String ?? "normal"
            default:
                break
            }
        }
        self.value4 = value4
        self.value5 = value5
    }
    
    public convenience init(babyId: String, commandId: Int) {
        self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: commandId, dateTime: Date(), value1: nil, value2: nil, value3: nil, value4: nil, value5: nil)
    }
}
