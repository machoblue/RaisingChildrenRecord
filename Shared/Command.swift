//
//  Command.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/16.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

public class Command {
    static public let values: [(id: Int, name: String, image: String, behaviorName: String)] = [
        (1, "ミルク", "milk", "ミルクを飲んだ"), // SVO
        (2, "母乳", "breast", "母乳を飲んだ"), // SVO
        (3, "体温", "temperature", ""), // SVC
        (4, "うんち", "poo", "した"), // SVO
        (5, "寝る", "sleep", "寝た"), // SV
        (6, "起きる", "awake", "起きた"), // SV
        (7, "その他", "other", "") // ???
        
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
    
    static public func behaviorName(id: Int) -> String? {
        var behaviorName: String?
        for value in values {
            if (value.id == id) {
                behaviorName = value.behaviorName
            }
        }
        return behaviorName
    }
    
//    static func id(of babyName: String) -> Int {
//        var id: Int?
//        for value in values {
//            if (value.name == babyName) {
//                id = value.id
//            }
//        }
//        return id!
//    }
    
    static public func id(of behaviorName: String) -> Int {
        var id: Int?
        for value in values {
            if (value.behaviorName == behaviorName) {
                id = value.id
                break
            }
        }
        return id!
    }
}
