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
    
    func notifyToShowInterstitial() {
        NotificationCenter.default.post(name: .ShowInterstitialAd, object: nil)
    }
    
    func loadAndAddAdView(_ viewController: UIViewController) {
        // In this case, we instantiate the banner with desired ad size.
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView, viewController: viewController)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
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
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = delegate
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func showInterstitial(_ interstitial: GADInterstitial, viewController: UIViewController) {
        var countToShowInterstitial = UserDefaults.standard.object(forKey: UserDefaults.Keys.CountToShowInterstitial.rawValue) as? Int ?? 0
        countToShowInterstitial = countToShowInterstitial + 1
        if countToShowInterstitial >= 3 && interstitial.isReady {
            interstitial.present(fromRootViewController: viewController)
            countToShowInterstitial = 0
        } else {
            os_log("Ad wasn't ready", log: OSLog.default, type: .debug)
        }
        UserDefaults.standard.register(defaults: [UserDefaults.Keys.CountToShowInterstitial.rawValue: countToShowInterstitial])
    }
}

extension Notification.Name {
    static let ShowInterstitialAd = Notification.Name("ShowInterstitalAd")
}
