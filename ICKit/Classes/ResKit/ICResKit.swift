//
//  ICResKit.swift
//  Ico
//
//  Created by _ivanC on 12/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

struct ICRes {
    public static func text(_ key: String) -> String? {
        return ICResTextManager.shared.text(key)
    }
    
    public static func color(_ key: String) -> UIColor? {
        var result:UIColor? = ICThemeManager.shared.currentTheme?.color(key)
        if result == nil {
            result = ICThemeManager.shared.baseTheme.color(key)
        }
        return result
    }
    
    public static func image(_ key: String, shouldCache:Bool = true, useTemplate:Bool = false) -> UIImage? {
        
        var result:UIImage? = ICThemeManager.shared.currentTheme?.image(key, shouldCache:shouldCache, useTemplate:useTemplate)
        if result == nil {
            result = ICThemeManager.shared.baseTheme.image(key, shouldCache:shouldCache, useTemplate:useTemplate)
        }
        return result
    }
    
    public static func regionImage(_ key: String, shouldCache:Bool = true, useTemplate:Bool = false) -> UIImage? {
        
        var result:UIImage? = ICThemeManager.shared.currentTheme?.regionImage(key, shouldCache:shouldCache, useTemplate:useTemplate)
        if result == nil {
            result = ICThemeManager.shared.baseTheme.regionImage(key, shouldCache:shouldCache, useTemplate:useTemplate)
        }
        return result
    }
    
    public static func languageImage(_ key: String, shouldCache:Bool = true, useTemplate:Bool = false) -> UIImage? {
        
        var result:UIImage? = ICThemeManager.shared.currentTheme?.languageImage(key, shouldCache:shouldCache, useTemplate:useTemplate)
        if result == nil {
            result = ICThemeManager.shared.baseTheme.languageImage(key, shouldCache:shouldCache, useTemplate:useTemplate)
        }
        return result
    }
    
    public static func data(_ key: String) -> Data? {
        var result:Data? = ICThemeManager.shared.currentTheme?.data(key)
        if result == nil {
            result = ICThemeManager.shared.baseTheme.data(key)
        }
        return result
    }
}


