//
//  ICThemeManager.swift
//  Ico
//
//  Created by _ivanC on 12/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit
import ICObserver

public enum ICPresetTheme: String {
    case day = "Day"
    case night = "Night"
}

@objc public protocol ICThemeManagerObserver {
    func willThemeChange()
    func didThemeChanged()
}

public class ICThemeManager: ICObserverTable {
    public static let shared = ICThemeManager()
    
    private(set) lazy var baseTheme:ICThemeInfo = {
        let themeInfo = ICThemeInfo(name: ICPresetTheme.day.rawValue, mode: .day, type: .preset, baseDir: ICResEnvironmentConfigurator.shared.fullResMainPath.ic.stringByAppendingPathComponent(path: "Themes/Day"))
        return themeInfo
    }()
    
    private(set) var currentTheme:ICThemeInfo?
    
    public func loadTheme(theme: ICThemeInfo) -> Bool {
        
        if self.currentTheme?.name == theme.name {
            return true
        }
        
        if !theme.load() {
            return false
        }
        
        self.notifyObserversThemeWillChanged()
        
        self.currentTheme?.unload()
        self.currentTheme = theme
        
        self.notifyObserversThemeDidChanged()
        
        return true
    }
    
    public func loadTheme(named: String) -> Bool {
        if named.count <= 0 {
            return false
        }
        
        var nextTheme:ICThemeInfo?
        switch named {
        case ICPresetTheme.day.rawValue:
            nextTheme = self.baseTheme
            break
        case ICPresetTheme.night.rawValue:
            nextTheme = ICThemeInfo(name: ICPresetTheme.night.rawValue, mode: .night, type: .preset, baseDir: ICResEnvironmentConfigurator.shared.fullResMainPath.ic.stringByAppendingPathComponent(path: "Themes/Night"))
            break
        default:
            if let downloadedPath = ICResEnvironmentConfigurator.shared.downloadedSkinMainPath {
                let path = downloadedPath.ic.stringByAppendingPathComponent(path: named)
                if FileManager.default.fileExists(atPath: path) {
                    
                    // Maybe we should check whether data is valid
                    nextTheme = ICThemeInfo(name: named, mode: .day, type: .download, baseDir: path)
                }
            }
        }
        
        if let toLoadTheme = nextTheme {
            return self.loadTheme(theme: toLoadTheme)
        }
        
        return false
    }
    
    private func notifyObserversThemeWillChanged() {
        self.enumerateObserverOnMainThread { (observer) in
            let ob:NSObject = observer as! NSObject
            if ob.responds(to: #selector(ICThemeManagerObserver.willThemeChange)) {
                ob.perform(#selector(ICThemeManagerObserver.willThemeChange))
            }
        }
    }
    
    private func notifyObserversThemeDidChanged() {
        self.enumerateObserverOnMainThreadAsync { (observer) in
            let ob:NSObject = observer as! NSObject
            if ob.responds(to: #selector(ICThemeManagerObserver.didThemeChanged)) {
                ob.perform(#selector(ICThemeManagerObserver.didThemeChanged))
            }
        }
    }
}
