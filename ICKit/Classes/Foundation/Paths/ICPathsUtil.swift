//
//  ICPathUtil.swift
//  ICKit
//
//  Created by _ivanC on 02/01/2020.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

public class ICPathUtil: NSObject {
    
    open class func createDirectoryIfNeeded(_ dir: String) {
        if !FileManager.default.fileExists(atPath: dir) {
            try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private class func buildSubDir(from root:String, with sub:String, createIfNeeded:Bool = true) -> String {
        let result = root.ic.stringByAppendingPathComponent(path: sub)
        if createIfNeeded {
            createDirectoryIfNeeded(result)
        }
        return result
    }
    
    private class func buildSubPath(from root:String, with sub:String, createIfNeeded:Bool = true) -> String {
        let result = root.ic.stringByAppendingPathComponent(path: sub)
        let dir = result.ic.stringByDeletingLastPathComponent
        if createIfNeeded {
            createDirectoryIfNeeded(dir)
        }
        return result
    }
    
    //MARK: - Library
    static let libraryDir: String = {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, .userDomainMask, true)
        if let path = paths.first {
            createDirectoryIfNeeded(path)
            return path
        } else {
            let path = (NSHomeDirectory() as NSString).appendingPathComponent("Library")
            createDirectoryIfNeeded(path)
            return path
        }
    }()
    
    open class func librarySubDir(with subDir: String, createIfNeeded:Bool = true) -> String {
        return buildSubDir(from: libraryDir, with: subDir, createIfNeeded:createIfNeeded)
    }
    
    open class func libraryPath(with subPath: String, createIfNeeded:Bool = true) -> String {
        return buildSubPath(from: libraryDir, with: subPath, createIfNeeded:createIfNeeded)
    }
    
    //MARK: - Documents
    static let documentDir: String = {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true)
        if let path = paths.first {
            createDirectoryIfNeeded(path)
            return path
        } else {
            let path = (NSHomeDirectory() as NSString).appendingPathComponent("Documents")
            createDirectoryIfNeeded(path)
            return path
        }
    }()
    
    open class func documentSubDir(with subDir: String, createIfNeeded:Bool = true) -> String {
        return buildSubDir(from: documentDir, with: subDir, createIfNeeded:createIfNeeded)
    }
    
    open class func documentPath(with subPath: String, createIfNeeded:Bool = true) -> String {
        return buildSubPath(from: documentDir, with: subPath, createIfNeeded:createIfNeeded)
    }
    
    //MARK: - Tmp
    static let tmpDir: String = {
        let path = (NSHomeDirectory() as NSString).appendingPathComponent("tmp")
        createDirectoryIfNeeded(path)
        return path
    }()
    
    open class func tmpSubDir(with subDir: String, createIfNeeded:Bool = true) -> String {
        return buildSubDir(from: tmpDir, with: subDir, createIfNeeded:createIfNeeded)
    }
    
    open class func tmpPath(with subPath: String, createIfNeeded:Bool = true) -> String {
        return buildSubPath(from: tmpDir, with: subPath, createIfNeeded:createIfNeeded)
    }
}
