//
//  UserDefaults+Keys.swift
//  Shared
//
//  Created by 松島勇貴 on 2018/11/04.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

extension UserDefaults {
    public enum Keys: String {
        case FamilyId
        case BabyId
        case MilkMillilitters
        case BreastMinutes
        case Temperature
        case PooHardness
        case PooAmount
        case IsSignInSkipped
        case CountToShowInterstitial
    }
}
