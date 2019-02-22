//
//  AdUtils.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/01/15.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import Foundation
import os.log

import GoogleMobileAds

class AdUtils {
    public static let shared = AdUtils()
    private init() {
    }
    
    func loadAndAddAdView(_ viewController: UIViewController) {
        // In this case, we instantiate the banner with desired ad size.
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView, viewController: viewController)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Test
//        bannerView.adUnitID = "ca-app-pub-2062076007725970/1481717848" // Release
        bannerView.rootViewController = viewController
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView, viewController: UIViewController) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(bannerView)
        viewController.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: viewController.bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: viewController.view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func createAndLoadInterstitial(_ delegate: GADInterstitialDelegate) -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910") // Test
//        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-2062076007725970/8006585985") // Release
        interstitial.delegate = delegate
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func showInterstitial(_ interstitial: GADInterstitial, viewController: UIViewController) -> Bool {
        var countToShowInterstitial = UserDefaults.standard.object(forKey: UserDefaults.Keys.CountToShowInterstitial.rawValue) as? Int ?? 0
        countToShowInterstitial = countToShowInterstitial + 1
        
        if countToShowInterstitial >= 3 && interstitial.isReady {
            interstitial.present(fromRootViewController: viewController)
            countToShowInterstitial = 0
            UserDefaults.standard.register(defaults: [UserDefaults.Keys.CountToShowInterstitial.rawValue: countToShowInterstitial])
            return true
        } else {
            os_log("Ad wasn't ready", log: OSLog.default, type: .debug)
            UserDefaults.standard.register(defaults: [UserDefaults.Keys.CountToShowInterstitial.rawValue: countToShowInterstitial])
            return false
        }
    }
}
