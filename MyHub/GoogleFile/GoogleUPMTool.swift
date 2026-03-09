//
//  GoogleUPMTool.swift
//  MyHub
//
//  Created by hub on 3/8/26.
//

import Foundation
import GoogleMobileAds
import UserMessagingPlatform

class GoogleUPMTool: NSObject {
    static let instance = GoogleUPMTool()
    
    var canRequestAds: Bool {
        return ConsentInformation.shared.canRequestAds
    }
    
    var isPrivacyOptionsRequired: Bool {
        return ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }
    
    /// Helper method to call the UMP SDK methods to request consent information and load/present a
    /// consent form if necessary.
    func showGoogleView(
        _ controller: UIViewController,
        consentGatheringComplete: @escaping (Error?) -> Void
    ) {
        let parameters = RequestParameters()
        
        //For testing purposes, you can force a UMPDebugGeography of EEA or not EEA.
#if DEBUG
        let debugSettings = DebugSettings()
        //        debugSettings.testDeviceIdentifiers = ["951D6AFC-673E-44D1-9CA0-BE3DB00E50E4"]
        
        debugSettings.geography = DebugGeography.EEA
        
        parameters.debugSettings = debugSettings
#endif
        // Requesting an update to consent information should be called on every app launch.
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) {
            requestConsentError in
            guard requestConsentError == nil else {
                return consentGatheringComplete(requestConsentError)
            }
            let status = ConsentInformation.shared.formStatus
            if status == .available {
                ConsentForm.loadAndPresentIfRequired(from: controller) {
                    loadAndPresentError in
                    // Consent has been gathered.
                    consentGatheringComplete(loadAndPresentError)
                }
            }
        }
    }
}
