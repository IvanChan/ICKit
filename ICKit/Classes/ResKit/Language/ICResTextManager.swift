//
//  ICResTextManager.swift
//  Ico
//
//  Created by _ivanC on 15/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit
import GDataXML_HTML

@objc public protocol ICResTextManagerObserver {
    func willLanguageChange()
    func didLanguageChanged()
}

public class ICResTextManager: ICObserverTable<ICResTextManagerObserver> {
    public static let shared = ICResTextManager()

    private var textXmlDoc:GDataXMLDocument?

    private lazy var languageResMainPath:String = {
        return ICResEnvironmentConfigurator.shared.languageMainPath
    }()
    
    init() {
        super.init()
        
        self.reloadAllText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ICResTextManager.didReceivedICLocalizationLanguageDidChanged), name: NSNotification.Name.ICLocalizationLanguageDidChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func didReceivedICLocalizationLanguageDidChanged(notification: NSNotification) {
        self.notifyObserversLanguageWillChanged()
        self.reloadAllText()
        self.notifyObserversLanguageDidChanged()
    }
    
    private func reloadAllText() {
        var usingBase = false
        let xmlName = "\(ICLocalization.shared.languageCodeShort).xml"
        var xmlPath = self.languageResMainPath.ic.stringByAppendingPathComponent(path: xmlName)
        if !FileManager.default.fileExists(atPath: xmlPath) {
            xmlPath = self.languageResMainPath.ic.stringByAppendingPathComponent(path: "base.xml")
            usingBase = true
        }
        
        if !self.loadTextXml(path: xmlPath) && !usingBase {
            let _ = self.loadTextXml(path: self.languageResMainPath.ic.stringByAppendingPathComponent(path: "base.xml"))
        }
    }
    
    private func loadTextXml(path: String) -> Bool {

        let xmlURL = URL(fileURLWithPath: path)
        if let xmlData = try?Data(contentsOf: xmlURL), xmlData.count > 0 {
            do {
                try self.textXmlDoc = GDataXMLDocument(data: xmlData)
            } catch {
                self.textXmlDoc = nil
            }
        }
        
        return self.textXmlDoc != nil
    }
    
    public func text(_ key:String) -> String? {
        if key.count <= 0 {
            return nil
        }

        let xpath = "//Language/\(key)"
        
        var xmlNode:GDataXMLNode?
        do {
            xmlNode = try self.textXmlDoc?.firstNode(forXPath: xpath)
        } catch {
            xmlNode = nil
        }
        
        if xmlNode != nil {
            return xmlNode!.stringValue()
        }
        
        return nil
    }
    
    private func notifyObserversLanguageWillChanged() {
        self.enumerateObserverOnMain { (observer) in
            let ob:NSObject = observer as! NSObject
            if ob.responds(to: #selector(ICResTextManagerObserver.willLanguageChange)) {
                ob.perform(#selector(ICResTextManagerObserver.willLanguageChange))
            }
        }
    }
    
    private func notifyObserversLanguageDidChanged() {
        self.enumerateObserverOnMainAsync { (observer) in
            let ob:NSObject = observer as! NSObject
            if ob.responds(to: #selector(ICResTextManagerObserver.didLanguageChanged)) {
                ob.perform(#selector(ICResTextManagerObserver.didLanguageChanged))
            }
        }
    }
}
