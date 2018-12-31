//
//  ICThemeInfo.swift
//  Ico
//
//  Created by _ivanC on 13/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit
import GDataXML_HTML

public enum ICThemeMode : Int {
    
    case none
    
    case day
    
    case night
}

public enum ICThemeType : Int {
    
    case preset
    
    case download
    
    case custom
}

public class ICThemeInfo: NSObject {
    
    private(set) var mode:ICThemeMode
    private(set) var type:ICThemeType

    private(set) var name:String
    private(set) var logo:UIImage?

    var colorXmlFilename:String = "color.xml"
    private(set) var baseDir:String // Theme folder contains: image、info.xml、logo

    private(set) var presetDir:String?
    
    private(set) var isLoaded:Bool = false

    private var colorXmlDoc:GDataXMLDocument?
    
    init(name:String, mode:ICThemeMode, type:ICThemeType, baseDir: String) {
        
        self.name = name
        self.mode = mode
        self.type = type
        self.baseDir = baseDir
        
        if self.type == .preset {
            self.presetDir = ICResEnvironmentConfigurator.shared.relativePresetThemeMainPath.ic.stringByAppendingPathComponent(path: self.name)
        }
        
        super.init()
    }
    
    func load() -> Bool {
        if self.isLoaded {
            return true
        }
        
        let xmlURL = URL(fileURLWithPath: self.baseDir).appendingPathComponent(self.colorXmlFilename)
        if let xmlData = try?Data(contentsOf: xmlURL), xmlData.count > 0 {
            do {
                try self.colorXmlDoc = GDataXMLDocument(data: xmlData)
            } catch {
                self.colorXmlDoc = nil
            }
        }
        
        self.isLoaded = (self.colorXmlDoc != nil)
        return self.isLoaded
    }
    
    func unload() {
        if !self.isLoaded {
            return;
        }
        
        self.colorXmlDoc = nil;
        self.isLoaded = false
    }
    
    //------------------- Localization Key ----------------------
    private func canonicalRegionKey(_ key: String) -> String {
        let regionCode = ICLocalization.shared.regionCode
        if regionCode.count <= 0 {
            return key
        }
        
        let filename = key.ic.lastPathComponent
        let regionKey = key.ic.stringByDeletingLastPathComponent.ic.stringByAppendingPathComponent(path: regionCode)
        return regionKey.ic.stringByAppendingPathComponent(path: filename)
    }
    
    private func canonicalLanguageKey(_ key: String) -> String {
        let languageCode = ICLocalization.shared.languageCodeShort
        if languageCode.count <= 0 {
            return key
        }
        
        let filename = key.ic.lastPathComponent
        let resKey = key.ic.stringByDeletingLastPathComponent.ic.stringByAppendingPathComponent(path: languageCode)
        return resKey.ic.stringByAppendingPathComponent(path: filename)
    }
    
    //--------------------------- Images ------------------------
    public func image(_ key:String, shouldCache:Bool = true, useTemplate:Bool = false) -> UIImage? {
        if key.count <= 0 {
            return nil
        }
        
        var image:UIImage?
        if shouldCache {
            if let presetDir = self.presetDir {
                let path = "\(presetDir)/Images/\(key)"
                image = UIImage(named: path)
            } else {
                let path = "\(self.baseDir)/Images/\(key)"
                image = UIImage(contentsOfFile: path)
            }
        } else {
            let path = "\(self.baseDir)/Images/\(key)"
            image = UIImage(contentsOfFile: path)
        }
        
        if useTemplate {
            image = image?.withRenderingMode(.alwaysTemplate)
        }
        return image
    }
    
    public func regionImage(_ key:String, shouldCache:Bool = true, useTemplate:Bool = false) -> UIImage? {
        return self.image(self.canonicalRegionKey(key), shouldCache:shouldCache, useTemplate:useTemplate)
    }
    
    public func languageImage(_ key:String, shouldCache:Bool = true, useTemplate:Bool = false) -> UIImage? {
        return self.image(self.canonicalLanguageKey(key), shouldCache:shouldCache, useTemplate:useTemplate)
    }
    
    //------------------- Color ----------------------
    public func color(_ key:String) -> UIColor? {
        if key.count <= 0 {
            return nil
        }
        
        let xpath = "//Color/\(key)"
        
        var xmlNode:GDataXMLNode?
        do {
            xmlNode = try self.colorXmlDoc?.firstNode(forXPath: xpath)
        } catch {
            xmlNode = nil
        }
        
        if xmlNode != nil {
            if let valueStr = xmlNode!.stringValue(), valueStr.count > 0 {
                let valueNS: NSString = valueStr as NSString
                let argbValue:UInt64 = strtoull(valueNS.utf8String, nil, 16)
                return UIColor(red: CGFloat(((argbValue & 0x00FF0000) >> 16))/255.0, green: CGFloat(((argbValue & 0x0000FF00) >> 8))/255.0, blue: CGFloat((argbValue & 0x000000FF))/255.0, alpha: CGFloat(((argbValue & 0xFF000000) >> 24))/255.0)
            }
        }
        
        return nil
    }
    
    //------------------- Data ----------------------
    public func data(_ key:String) -> Data? {
        if key.count <= 0 {
            return nil
        }
        
        let path = self.baseDir.ic.stringByAppendingPathComponent(path: key)
        if FileManager.default.fileExists(atPath: path) {
            return try? Data(contentsOf: URL(fileURLWithPath: path))
        }
        
        return nil
    }
}
