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
        
        recordCreateIntent.baby = BabyDaoRealm.shared.find(babyId!)?.name
        
        switch commandId {
        case "1":
            recordCreateIntent.behavior = Command.values[Int(commandId!)! - 1].verb
            recordCreateIntent.target = Command.values[Int(commandId!)! - 1].target
            guard let amountStr = value2, let amount = Int(amountStr) else { break }
            recordCreateIntent.amount = amount as NSNumber
            recordCreateIntent.unit = "ml"
        case "2":
            recordCreateIntent.behavior = Command.values[Int(commandId!)! - 1].verb
            recordCreateIntent.target = Command.values[Int(commandId!)! - 1].target
            guard let amountStr = value2, let amount = Int(amountStr) else { break }
            recordCreateIntent.amount = amount as NSNumber
            recordCreateIntent.unit = "分"
        case "3":
            recordCreateIntent.property = Command.values[Int(commandId!)! - 1].property
            guard let amountStr = value2, let amount = Float(amountStr) else { break }
            recordCreateIntent.amount = amount as NSNumber
            recordCreateIntent.unit = "℃"
        case "4":
            recordCreateIntent.behavior = Command.values[Int(commandId!)! - 1].verb
            recordCreateIntent.target = Command.values[Int(commandId!)! - 1].target
        case "5":
            recordCreateIntent.behavior = Command.values[Int(commandId!)! - 1].verb
        case "6":
            recordCreateIntent.behavior = Command.values[Int(commandId!)! - 1].verb
        case "8":
            recordCreateIntent.behavior = Command.values[6].verb
            recordCreateIntent.target = Command.values[6].target
        default:
            break
        }
        print("*** RecordModel.intent *** self  :", self, self.commandId)
        print("*** RecordModel.intent *** intent:", recordCreateIntent)
        
        return recordCreateIntent
    }
    
}
