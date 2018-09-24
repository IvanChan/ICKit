//
//  String+PathUtilities.swift
//  Ico
//
//  Created by _ivanC on 15/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

extension ICKit where Base == String {

    public var lastPathComponent: String {
        
        get {
            return (base as NSString).lastPathComponent
        }
    }
    public var pathExtension: String {
        
        get {
            
            return (base as NSString).pathExtension
        }
    }
    public var stringByDeletingLastPathComponent: String {
        
        get {
            
            return (base as NSString).deletingLastPathComponent
        }
    }
    public var stringByDeletingPathExtension: String {
        
        get {
            
            return (base as NSString).deletingPathExtension
        }
    }
    public var pathComponents: [String] {
        
        get {
            
            return (base as NSString).pathComponents
        }
    }
    
    public func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = base as NSString
        
        return nsSt.appendingPathComponent(path)
    }
    
    public func stringByAppendingPathExtension(ext: String) -> String? {
        
        let nsSt = base as NSString
        
        return nsSt.appendingPathExtension(ext)
    }
}
