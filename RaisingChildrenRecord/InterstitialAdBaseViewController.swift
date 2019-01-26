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

    override func viewDidLoad() {
        super.viewDidLoad()

        interstitial = AdUtils.shared.createAndLoadInterstitial(self)
        interstitial.delegate = self
    }
    
    func showInterstitialAndDismiss() {
        let haveShownInterstitial = AdUtils.shared.showInterstitial(interstitial, viewController: self)
        if !haveShownInterstitial {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension InterstitialAdBaseViewController: GADInterstitialDelegate {
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        dismiss(animated: true, completion: nil)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = AdUtils.shared.createAndLoadInterstitial(self)
    }
}
