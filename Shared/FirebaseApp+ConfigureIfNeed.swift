//
//  FirebaseApp+ConfigureIfNeed.swift
//  Shared
//
//  Created by 松島勇貴 on 2018/11/04.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Foundation

import Firebase

extension FirebaseApp {
    private static var configured = false;
    private static let firebaseStatusAccessQueue = DispatchQueue(label: "Firebase Status Access Queue")
    public static func configureIfNeed() {
        firebaseStatusAccessQueue.sync {
            guard !configured else { return }
            FirebaseApp.configure()
            configured = true
        }
    }
}
