//
//  ICResEnvironmentConfigurator.swift
//  Ico
//
//  Created by _ivanC on 15/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

public class ICResEnvironmentConfigurator: NSObject {
    public static let shared = ICResEnvironmentConfigurator()
    
    public var relativeResMainPath: String = ""

    public var fullResMainPath: String {
        get {
            if let rPath = Bundle.main.resourcePath {
                return rPath.ic.stringByAppendingPathComponent(path: self.relativeResMainPath)
            }
            return ""
        }
    }
    
    var relativePresetThemeMainPath: String {
        get {
            return self.relativeResMainPath.ic.stringByAppendingPathComponent(path: "Themes")
        }
    }
    
    var languageMainPath: String {
        get {
            return self.fullResMainPath.ic.stringByAppendingPathComponent(path: "Languages")
        }
    }
    

    public var downloadedSkinMainPath: String?

}
