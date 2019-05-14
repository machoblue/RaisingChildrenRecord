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
    public var note: String?
    public var number1: Int = 0 { // milk, breast
        didSet {
            switch Commands.Identifier(rawValue: commandId)! {
            case .milk:
                UserDefaults.dataSuite.register(defaults: [UserDefaults.Keys.MilkMillilitters.rawValue: number1])
            case .breast:
                UserDefaults.dataSuite.register(defaults: [UserDefaults.Keys.BreastMinutes.rawValue: number1])
            default:
                // do nothing
                break
            }
        }
    }
    
    public var number2: Int = 0
    
    public var decimal1: Float = 0  { // temperature
        didSet {
            switch Commands.Identifier(rawValue: commandId)! {
            case .temperature:
                UserDefaults.dataSuite.register(defaults: [UserDefaults.Keys.Temperature.rawValue: decimal1])
            default:
                // do nothing
                break
            }
        }
    }
    
    public var decimal2: Float = 0
    
    public var text1: String? { // poo/hardness
        didSet {
            switch Commands.Identifier(rawValue: commandId)! {
            case .poo:
                guard let text1 = text1, !text1.isEmpty else { return }
                UserDefaults.dataSuite.register(defaults: [UserDefaults.Keys.PooHardness.rawValue: text1])
            default:
                // do nothing
                break
            }
        }
    }
    public var text2: String? { // poo/amount
        didSet {
            switch Commands.Identifier(rawValue: commandId)! {
            case .poo:
                guard let text2 = text2, !text2.isEmpty else { return }
                UserDefaults.dataSuite.register(defaults: [UserDefaults.Keys.PooAmount.rawValue: text2])
            default:
                // do nothing
                break
            }
        }
    }
    
    override public var description: String {
        return "id=\(self.id), babyId=\(self.babyId)"
    }
    
    public var label: String {
        switch Commands.Identifier(rawValue: commandId)! {
        case .milk:
            let unit = Commands.command(from: commandId)!.unit
            return "\(number1)\(unit.rawValue)"
        case .breast:
            let unit = Commands.command(from: commandId)!.unit
            return "\(number1)\(unit.rawValue)"
        case .temperature:
            let unit = Commands.command(from: commandId)!.unit
            return "\(decimal1)\(unit.rawValue)"
        case .poo:
            guard let text1 = text1, !text1.isEmpty else { return "" }
            return Commands.HardnessOption(rawValue: text1)!.label
        default:
            return note ?? ""
        }
    }
    
    public init(id: String, babyId: String, userId: String?, commandId: Int, dateTime: Date, note: String?, number1: Int, number2: Int, decimal1: Float, decimal2: Float, text1: String?, text2: String?) {
        self.id = id
        self.babyId = babyId
        self.userId = userId
        self.commandId = commandId
        self.dateTime = dateTime
        self.note = note
        self.number1 = number1
        self.number2 = number2
        self.decimal1 = decimal1
        self.decimal2 = decimal2
        self.text1 = text1
        self.text2 = text2
        
        switch Commands.Identifier(rawValue: commandId)! {
        case .milk:
            self.number1 = (number1 > 0) ? number1 : UserDefaults.dataSuite.object(forKey: UserDefaults.Keys.MilkMillilitters.rawValue) as? Int ?? 100
        case .breast:
            self.number1 = (number1 > 0) ? number1 : UserDefaults.dataSuite.object(forKey: UserDefaults.Keys.BreastMinutes.rawValue) as? Int ?? 10
        case .temperature:
            self.decimal1 = (decimal1 > 0.0) ? decimal1 : UserDefaults.dataSuite.object(forKey: UserDefaults.Keys.Temperature.rawValue) as? Float ?? 36.5
        case .poo:
            if let text1 = text1, !text1.isEmpty {
                self.text1 = text1
            } else {
                self.text1 = UserDefaults.dataSuite.object(forKey: UserDefaults.Keys.PooHardness.rawValue) as? String ?? "normal"
            }
            
            if let text2 = text2, !text2.isEmpty {
                self.text2 = text2
            } else {
                self.text2 = UserDefaults.dataSuite.object(forKey: UserDefaults.Keys.PooAmount.rawValue) as? String ?? "normal"
            }
            
        default:
            // do nothing
            break
        }
    }
    
    public convenience init(babyId: String, commandId: Int) {
        self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: commandId, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
    }
}
