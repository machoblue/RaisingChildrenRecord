//
//  Command.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/16.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

class Command {
    static let values: [(id: Int, name: String, image: String)] = [
        (1, "ミルク", "milk"),
        (2, "母乳", "breast"),
        (3, "体温", "temperature"),
        (4, "うんち", "poo"),
        (5, "寝る", "sleep"),
        (6, "起きる", "awake"),
        (7, "その他", "other")
    ]
    
    static func name(id: Int) -> String? {
        var name: String?
        for value in values {
            if (value.id == id) {
                name = value.name
            }
        }
        return name
    }
    
    static func image(id: Int) -> String? {
        var image: String?
        for value in values {
            if (value.id == id) {
                image = value.image
            }
        }
        return image
    }
}
