//
//  ICResTextureExtensions.swift
//  ICResKit
//
//  Created by _ivanC on 15/01/2018.
//  Copyright © 2018 ICResKit. All rights reserved.
//

import UIKit
import AsyncDisplayKit

extension ASDisplayNode: ICKitCompatible {}

extension ASDisplayNode: ICThemeManagerObserver, ICResTextManagerObserver {
    
    @objc open func willThemeChange() {
        
    }
    
    @objc open func didThemeChanged() {
        if let bgColorResKey:String = self.ic.resValue(ICResKey.backgroundColor.rawValue) as? String {
            self.backgroundColor = ICRes.color(bgColorResKey)
        }
    }
    
    @objc open func willLanguageChange() {
        
    }

    @objc open func didLanguageChanged() {
        
    }
}

var ICResTextureAssocaitionKey:Void?
extension ICKit where Base : ASDisplayNode {

    internal func resHash() -> [String:Any] {
        
        var resHash:[String:Any]? = objc_getAssociatedObject(self.base, &ICResTextureAssocaitionKey) as? [String:Any]
        if resHash == nil {
            resHash = [:]
            objc_setAssociatedObject(self.base, &ICResTextureAssocaitionKey, resHash, .OBJC_ASSOCIATION_RETAIN)
            
            ICThemeManager.shared.addObserver(self.base)
            ICResTextManager.shared.addObserver(self.base)
        }
        return resHash!
    }
    
    internal func updateHash(_ resHash:[String:Any]) {
        objc_setAssociatedObject(self.base, &ICResTextureAssocaitionKey, resHash, .OBJC_ASSOCIATION_RETAIN)
    }
    
    internal func setResValue(_ value:Any, forKey:String) {
        var resHash = self.resHash()
        resHash[forKey] = value
        
        self.updateHash(resHash)
    }
    
    internal func removeResValue(for key:String) {
        var resHash = self.resHash()
        resHash.removeValue(forKey: key)
        self.updateHash(resHash)
    }
    
    internal func resValue(_ forKey:String) -> Any? {
        let resHash = self.resHash()
        return resHash[forKey]
    }
    
    //-------------- background color -----------------
    public func setBackgroundColor(key:String) {
        self.setResValue(key, forKey: ICResKey.backgroundColor.rawValue)
        self.base.backgroundColor = ICRes.color(key)
    }
}

extension ASButtonNode {
    
    func state() -> UIControl.State {
        
        var state:UIControl.State = []
        if self.isEnabled {
            state.insert(.disabled)
        } else {
            state.insert(.normal)
        }
        
        if self.isHighlighted {
            state.insert(.highlighted)
        }
        
        if self.isSelected {
            state.insert(.selected)
        }
        return state
    }
    
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        for (key, value) in self.ic.resStateHash(ICResKey.titleColor.rawValue) {
            self.ic.setTitleColor(ICRes.color(value), for: UIControl.State(rawValue: key))
        }
        
        for (key, value) in self.ic.resStateHash(ICResKey.image.rawValue) {
            self.setImage(ICRes.image(value), for: UIControl.State(rawValue: key))
        }
        
        for (key, value) in self.ic.resStateHash(ICResKey.backgroundImage.rawValue) {
            self.setBackgroundImage(ICRes.image(value), for: UIControl.State(rawValue: key))
        }
    }
    
    override open func didLanguageChanged() {
        super.didLanguageChanged()
        
        for (key, value) in self.ic.resStateHash(ICResKey.title.rawValue) {
            self.ic.setTitle(ICRes.text(value), for: UIControl.State(rawValue: key))
        }
    }
}

extension ICKit where Base : ASButtonNode {
    
    internal func resStateHash(_ key: String) -> [UInt:String] {
        var hash:[UInt:String]? = self.resValue(key) as? [UInt:String]
        if hash == nil {
            hash = [:]
            self.setResValue(hash!, forKey: key)
        }
        return hash!
    }
    
    internal func saveResKey(_ key:String, forHashKey: String, forState:UIControl.State) {
        var hash = self.resStateHash(forHashKey)
        hash[forState.rawValue] = key
        
        self.setResValue(hash, forKey: forHashKey)
    }
    
    //-------------- title attribute -----------------
    internal func saveAttributeStateHash(_ hash:[UInt:[NSAttributedString.Key : Any]] ) {
        self.setResValue(hash, forKey: ICResKey.textAttribute.rawValue)
    }
    
    internal func attributeStateHash() -> [UInt:[NSAttributedString.Key : Any]] {
        var hash:[UInt:[NSAttributedString.Key : Any]]? = self.resValue(ICResKey.textAttribute.rawValue) as? [UInt:[NSAttributedString.Key : Any]]
        if hash == nil {
            hash = [:]
            self.saveAttributeStateHash(hash!)
        }
        return hash!
    }

    public  func appendTextAttribute(_ attribute:[NSAttributedString.Key : Any], for state: UIControl.State) {
        var oldAttribute = self.textAttribute(for: state)

        for key in attribute.keys {
            oldAttribute[key] = attribute[key]
        }
        
        self._setTextAttribute(oldAttribute, for: state)
    }
    
    public  func setTextAttribute(_ attribute:[NSAttributedString.Key : Any], for state: UIControl.State) {
        self.removeResValue(for: ICResKey.titleColor.rawValue)
        self._setTextAttribute(attribute, for: state)
    }
    
    public  func _setTextAttribute(_ attribute:[NSAttributedString.Key : Any], for state: UIControl.State) {
        var hash = self.attributeStateHash()
        hash[state.rawValue] = attribute
        self.saveAttributeStateHash(hash)
    }
    
    public  func textAttribute(for state: UIControl.State) -> [NSAttributedString.Key : Any] {
        var hash = self.attributeStateHash()
        var result = hash[state.rawValue]
        if result == nil {
            result = [:]
            hash[state.rawValue] = result
            self.saveAttributeStateHash(hash)
        }
        return result!
    }
    
    public func setTitle(_ text:String?, for state: UIControl.State) {
        self.base.setAttributedTitle(NSAttributedString(string: text ?? "", attributes: self.textAttribute(for: state)),
                                     for: state)
    }
    
    public func setTitleColor(_ color:UIColor, for state: UIControl.State) {
        var attribute = self.textAttribute(for: state)
        attribute[NSAttributedString.Key.foregroundColor] = color
        self.appendTextAttribute(attribute, for: state)
        
        if let str = self.base.attributedTitle(for: state)?.string {
            if str.count > 0 {
                self.setTitle(str, for:state)
            }
        }
    }
    
    public func setTitleFont(_ font:UIFont, for state: UIControl.State) {
        var attribute = self.textAttribute(for: state)
        attribute[NSAttributedString.Key.font] = font
        self.appendTextAttribute(attribute, for: state)
        
        if let str = self.base.attributedTitle(for: state)?.string {
            if str.count > 0 {
                self.setTitle(str, for:state)
            }
        }
    }
    
    //-------------- title -----------------
    public func setTitle(key:String, state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.title.rawValue, forState:state)
        self.setTitle(ICRes.text(key), for: state)
    }

    //-------------- title color -----------------
    public func setTitleColor(key:String, state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.titleColor.rawValue, forState:state)
        
        self.setTitleColor(ICRes.color(key), for: state)
        
        if let str = self.base.attributedTitle(for: state)?.string {
            if str.count > 0 {
                self.setTitle(str, for:state)
            }
        }
    }
    
    //-------------- image -----------------
    public func setImage(key:String, for state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.image.rawValue, forState:state)
        self.base.setImage(ICRes.image(key), for: state)
    }
    
    //-------------- background image -----------------
    public func setBackgroundImage(key:String, state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.backgroundImage.rawValue, forState:state)
        self.base.setBackgroundImage(ICRes.image(key), for: state)
    }
}

extension ASTextNode {
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        if let textColorKey:String = self.ic.resValue(ICResKey.titleColor.rawValue) as? String {
            var attribute = self.ic.textAttribute()
            attribute[NSAttributedString.Key.foregroundColor] = ICRes.color(textColorKey)
            self.ic.appendTextAttribute(attribute)
            self.ic.setText(self.attributedText?.string)
        }
    }
    
    override open func didLanguageChanged() {
        super.didLanguageChanged()
        
        if let key:String = self.ic.resValue(ICResKey.title.rawValue) as? String {
            self.ic.setText(ICRes.text(key))
        }
    }
}

extension ICKit where Base : ASTextNode {
    
    public func textAttribute() -> [NSAttributedString.Key : Any] {
        let attribute:[NSAttributedString.Key : Any]? = self.resValue(ICResKey.textAttribute.rawValue) as? [NSAttributedString.Key : Any]
        if let result = attribute {
            return result
        }
        
        let attr:[NSAttributedString.Key : Any] = [:]
        self._setTextAttribute(attr)
        return attr
    }
    
    public  func appendTextAttribute(_ attribute:[NSAttributedString.Key : Any]) {
        var oldAttribute = self.textAttribute()
        
        for key in attribute.keys {
            oldAttribute[key] = attribute[key]
        }
        
        self._setTextAttribute(oldAttribute)
    }
    
    public func setTextAttribute(_ attribute:[NSAttributedString.Key : Any]) {
        self.removeResValue(for: ICResKey.titleColor.rawValue)
        self._setTextAttribute(attribute)
    }
    
    internal func _setTextAttribute(_ attribute:[NSAttributedString.Key : Any]) {
        self.setResValue(attribute, forKey: ICResKey.textAttribute.rawValue)
    }
    
    public func setText(_ text:String?) {
        self.base.attributedText = NSAttributedString(string: text ?? "", attributes: self.textAttribute())
    }
    
    //-------------- text color -----------------
    public func setTextColor(key:String) {
        self.setResValue(key, forKey: ICResKey.titleColor.rawValue)
        
        var attribute = self.textAttribute()
        attribute[NSAttributedString.Key.foregroundColor] = ICRes.color(key)
        self.appendTextAttribute(attribute)
        
        if let str = self.base.attributedText?.string {
            if str.count > 0 {
                self.setText(str)
            }
        }
    }
    
    public func setTextFont(_ font:UIFont) {
        var attribute = self.textAttribute()
        attribute[NSAttributedString.Key.font] = font
        self.appendTextAttribute(attribute)
        
        if let str = self.base.attributedText?.string {
            if str.count > 0 {
                self.setText(str)
            }
        }
    }

    //-------------- text -----------------
    public func setText(key:String) {
        self.setResValue(key, forKey: ICResKey.title.rawValue)
        self.setText(ICRes.text(key))
        ICResTextManager.shared.addObserver(self.base)
    }
}

extension ASImageNode {
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        if let key:String = self.ic.resValue(ICResKey.image.rawValue) as? String {
            self.image = ICRes.image(key)
        }
    }
}

extension ICKit where Base : ASImageNode {

    //-------------- text -----------------
    public func setImage(key:String) {
        self.setResValue(key, forKey: ICResKey.image.rawValue)
        self.base.image = ICRes.image(key)
    }
}

