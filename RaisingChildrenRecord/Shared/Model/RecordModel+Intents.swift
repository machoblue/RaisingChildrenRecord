//
//  RecordModel+Intents.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/01/03.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import Foundation

import Shared

extension RecordModel {
    
    public var intent: RecordCreateIntent {
        let recordCreateIntent = RecordCreateIntent()
        
        recordCreateIntent.baby = BabyDaoRealm.shared.find(babyId)?.name
        
        let command = Commands.command(from: commandId)!
        recordCreateIntent.behavior = command.verb.rawValue.isEmpty ? nil : command.verb.rawValue
        recordCreateIntent.target = command.target.rawValue.isEmpty ? nil : command.target.rawValue
        recordCreateIntent.property = command.property.rawValue.isEmpty ? nil : command.property.rawValue
        
        switch command.unit {
        case .ml:
            guard number1 > 0 else { break }
            recordCreateIntent.amount = number1 as NSNumber
            recordCreateIntent.unit = command.unit.rawValue
        case .minute:
            guard number1 > 0 else { break }
            recordCreateIntent.amount = number1 as NSNumber
            recordCreateIntent.unit = command.unit.rawValue
        case .celcius:
            guard decimal1 > 0.0 else { break }
            recordCreateIntent.amountDecimal = decimal1 as NSNumber
            recordCreateIntent.unit = command.unit.rawValue
        case .none:
            break
        }
        
        return recordCreateIntent
    }
    
}
