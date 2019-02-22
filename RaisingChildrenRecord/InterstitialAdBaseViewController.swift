//
//  InterstitialAdBaseViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/01/26.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import UIKit

import Firebase

class InterstitialAdBaseViewController: UIViewController {
    
    var interstitial: GADInterstitial!
    
    var onComplete: (() -> ()) = {}

    override func viewDidLoad() {
        super.viewDidLoad()

        interstitial = AdUtils.shared.createAndLoadInterstitial(self)
        interstitial.delegate = self
    }
    
    func showInterstitial(onComplete: @escaping () -> ()) {
        self.onComplete = onComplete
        let haveShownInterstitial = AdUtils.shared.showInterstitial(interstitial, viewController: self)
        if !haveShownInterstitial {
            onComplete()
        }
    }
}

extension InterstitialAdBaseViewController: GADInterstitialDelegate {
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        onComplete()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = AdUtils.shared.createAndLoadInterstitial(self)
    }
}
