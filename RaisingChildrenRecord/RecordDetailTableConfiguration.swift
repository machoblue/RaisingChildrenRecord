//
//  RecordDetailTableConfiguration.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/12/15.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

/*
 共通
  時間
  削除
  メモ
 固有
  ミルク
   ml
  母乳
   分
  体温
   度
  うんち
   硬さ（柔らか、普通、硬い）
   量（少し、普通、多い）
  寝た、起きた、その他は無し
 */
struct RecordDetailTableConfiguration {
    enum RecordType {
        case milk,/* breast, temperature, poo, */sleep, awake, other
    }
    
    enum SectionType: String {
        case dateTime = "時間帯"
        case deleteButton = "削除する"
        case note = "メモ"
        case milliLitters = "量(ml)"
        case minutes = "時間(分)"
        case temperature = "体温(度)"
        case hardness = "硬さ"
        case amount = "量"
    }
    
    enum ReuseIdentifiers: String {
        case labelCell = "LabelCell"
        case dateTimeCell = "DateTimeCell"
        case deleteButtonCell = "DeleteButtonCell"
        case textCell = "TextCell"
        case quantityCell = "QuantityCell"
    }
    
    public let recordType: RecordType
    
    init(recordType: RecordType) {
        self.recordType = recordType
    }
    
    typealias SectionModel = (type: SectionType, rowCount: Int, cellReuseIdentifier: String)
    
    private static let milkRecordSectionModels: [SectionModel] = [
        SectionModel(type: .dateTime, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.dateTimeCell.rawValue),
        SectionModel(type: .milliLitters, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.quantityCell.rawValue),
        SectionModel(type: .note, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.textCell.rawValue),
        SectionModel(type: .deleteButton, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.deleteButtonCell.rawValue)
    ]
    
    private static let sleepRecordSectionModels: [SectionModel] = [
        SectionModel(type: .dateTime, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.dateTimeCell.rawValue),
        SectionModel(type: .note, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.textCell.rawValue),
        SectionModel(type: .deleteButton, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.deleteButtonCell.rawValue)
    ]
    
    var sections: [SectionModel] {
        switch recordType {
        case .milk:
            return RecordDetailTableConfiguration.milkRecordSectionModels
        case .sleep:
            return RecordDetailTableConfiguration.sleepRecordSectionModels
        case .awake:
            return RecordDetailTableConfiguration.sleepRecordSectionModels // same sectionModels as sleep
        case .other:
            return RecordDetailTableConfiguration.sleepRecordSectionModels // same sectionModels as sleep
        }
    }
}
