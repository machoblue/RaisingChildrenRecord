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
        recordCreateIntent.behavior = Command.behaviorName(id: Int(commandId!)!)
        recordCreateIntent.baby = BabyDaoFactory.shared.createBabyDao(.Local).find(babyId!)?.name
//        orderSoupIntent.quantity = quantity as NSNumber
//
//        let displayString = NSString.deferredLocalizedIntentsString(with: menuItem.shortcutLocalizationKey) as String
//        orderSoupIntent.soup = INObject(identifier: menuItem.itemName, display: displayString)
//        orderSoupIntent.setImage(INImage(named: menuItem.iconImageName), forParameterNamed: \OrderSoupIntent.soup)
//
//        orderSoupIntent.options = menuItemOptions.map { (option) -> INObject in
//            let displayString = NSString.deferredLocalizedIntentsString(with: option.shortcutLocalizationKey) as String
//            return INObject(identifier: option.rawValue, display: displayString)
//        }
//
//
//        orderSoupIntent.suggestedInvocationPhrase = NSString.deferredLocalizedIntentsString(with: "ORDER_SOUP_SUGGESTED_PHRASE") as String
        
        
        return recordCreateIntent
    }
}
