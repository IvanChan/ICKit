//
//  ICResKit.swift
//  Ico
//
//  Created by _ivanC on 12/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

public func resGetText(_ key: String) -> String? {
    return ICResTextManager.shared.text(forICResName: key)
}

public func resGetColor(_ key: String) -> UIColor? {
    var result:UIColor? = ICThemeManager.shared.currentTheme?.color(forICResName: key)
    if result == nil {
        result = ICThemeManager.shared.baseTheme.color(forICResName: key)
    }
    return result
}

public func resGetImage(_ key: String) -> UIImage? {
    
    var result:UIImage? = ICThemeManager.shared.currentTheme?.image(forICResName: key)
    if result == nil {
        result = ICThemeManager.shared.baseTheme.image(forICResName: key)
    }
    return result
}

public func resGetImageNoCache(_ key: String) -> UIImage? {
    
    var result:UIImage? = ICThemeManager.shared.currentTheme?.image(forICResNameNoCache: key)
    if result == nil {
        result = ICThemeManager.shared.baseTheme.image(forICResNameNoCache: key)
    }
    return result
}

public func resGetRegionImage(_ key: String) -> UIImage? {
    
    var result:UIImage? = ICThemeManager.shared.currentTheme?.image(forICResNameRegion: key)
    if result == nil {
        result = ICThemeManager.shared.baseTheme.image(forICResNameRegion: key)
    }
    return result
}

public func resGetLanguageImage(_ key: String) -> UIImage? {
    
    var result:UIImage? = ICThemeManager.shared.currentTheme?.image(forICResNameLanguage: key)
    if result == nil {
        result = ICThemeManager.shared.baseTheme.image(forICResNameLanguage: key)
    }
    return result
}

public func resGetTemplateImage(_ key: String) -> UIImage? {
    
    var result:UIImage? = ICThemeManager.shared.currentTheme?.templateImage(forICResName: key)
    if result == nil {
        result = ICThemeManager.shared.baseTheme.templateImage(forICResName: key)
    }
    return result
}

public func resGetTemplateRegionImage(_ key: String) -> UIImage? {
    
    var result:UIImage? = ICThemeManager.shared.currentTheme?.templateImage(forICResNameRegion: key)
    if result == nil {
        result = ICThemeManager.shared.baseTheme.templateImage(forICResNameRegion: key)
    }
    return result
}

public func resGetTemplateLanguageImage(_ key: String) -> UIImage? {
    
    var result:UIImage? = ICThemeManager.shared.currentTheme?.templateImage(forICResNameLanguage: key)
    if result == nil {
        result = ICThemeManager.shared.baseTheme.templateImage(forICResNameLanguage: key)
    }
    return result
}

public func resGetData(_ key: String) -> Data? {
    var result:Data? = ICThemeManager.shared.currentTheme?.data(forICResName: key)
    if result == nil {
        result = ICThemeManager.shared.baseTheme.data(forICResName: key)
    }
    return result
}

