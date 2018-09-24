//
//  ICLocalization.swift
//  Ico
//
//  Created by _ivanC on 12/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    
    public static let ICLocalizationRegionDidChanged: NSNotification.Name = NSNotification.Name(rawValue: "ICLocalizationRegionDidChanged")
    public static let ICLocalizationLanguageDidChanged: NSNotification.Name = NSNotification.Name(rawValue: "ICLocalizationLanguageDidChanged")

}

public class ICLocalization: NSObject {
    public static let shared = ICLocalization()
    
    private let user_set_region_key = "user_set_region_key"
    private let user_set_language_key = "user_set_language_key"

    private(set) var regionCode:String = ""     // uppercase string
    private(set) var languageCode:String = ""
    var languageCodeShort:String {
        get {
            let lanObjs = self.languageCode.components(separatedBy: "-")
            if lanObjs.count > 1 {
                return lanObjs[0].lowercased()
            } else {
                return self.languageCode.lowercased()
            }
        }
    }

    override init() {
        super.init()
        
        if let userSetRegion:String = UserDefaults.standard.object(forKey: self.user_set_region_key) as? String, userSetRegion.count > 0 {
            self.regionCode = userSetRegion
        } else {
            self.regionCode = self.systemRegionCode()
        }
        
        if let userSetLanguage:String = UserDefaults.standard.object(forKey: self.user_set_language_key) as? String, userSetLanguage.count > 0 {
            self.languageCode = userSetLanguage
        } else {
            self.languageCode = self.systemLanguageCode()
        }
    }
    
    public func systemRegionCode() -> String {
        if let systemRegionCode = Locale.current.regionCode {
            return systemRegionCode.uppercased()
        }
        return ""
    }
    
    public func systemLanguageCode() -> String{
        if Locale.preferredLanguages.count > 0 {
            return Locale.preferredLanguages.first!
        }
        return ""
    }
    
    public func systemLanguageCodeShort() -> String{
        if let systemLanguageCodeShort = Locale.current.languageCode {
            return systemLanguageCodeShort
        }
        return ""
    }
    
    public func changeRegion(regionCode: String) {
        if regionCode.count <= 0 {
            return
        }
        
        let regionCodeU = regionCode.uppercased()
        if self.regionCode == regionCodeU {
            return
        }
        
        self.regionCode = regionCodeU
        UserDefaults.standard.set(self.regionCode, forKey: self.user_set_region_key)
        UserDefaults.standard.synchronize()
        
        self.notifyLocalizationRegionDidChanged()
    }
    
    public func changeLanguage(languageCode:String) {
        if languageCode.count <= 0 || self.languageCode == languageCode {
            return
        }
        
        self.languageCode = languageCode
        UserDefaults.standard.set(self.languageCode, forKey: self.user_set_language_key)
        UserDefaults.standard.synchronize()
        
        self.notifyLocalizationLanguageDidChanged()
    }
    
    public func clearUserSetRegionAndLanguage () {
        UserDefaults.standard.removeObject(forKey: user_set_region_key)
        UserDefaults.standard.removeObject(forKey: user_set_language_key)
        UserDefaults.standard.synchronize()
        
        let originalRegionCode = String(self.regionCode)
        let originalLanguageCode = String(self.languageCode)

        self.regionCode = self.systemRegionCode()
        self.languageCode = self.systemLanguageCode()
        
        if originalRegionCode != self.regionCode {
            self.notifyLocalizationRegionDidChanged()
        }
        
        if originalLanguageCode != self.languageCode {
            self.notifyLocalizationLanguageDidChanged()
        }
    }
    
    private func notifyLocalizationRegionDidChanged() {
        NotificationCenter.default.post(name: Notification.Name.ICLocalizationRegionDidChanged, object: nil)
    }
    
    private func notifyLocalizationLanguageDidChanged() {
        NotificationCenter.default.post(name: Notification.Name.ICLocalizationLanguageDidChanged, object: nil)
    }
}
