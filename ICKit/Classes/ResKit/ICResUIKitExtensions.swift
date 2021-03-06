//
//  ICResUIKitExtensions.swift
//  ICResKit
//
//  Created by _ivanC on 15/01/2018.
//  Copyright © 2018 ICKit. All rights reserved.
//

import UIKit

enum ICResKey: String {
    case association = "ic_association"
    
    case backgroundColor = "ic_background_color"
    case borderColor = "ic_border_color"
    case tintColor = "ic_tint_color"

    case title = "ic_title"
    case titleColor = "ic_title_color"

    case image = "ic_image"
    case backgroundImage = "ic_background_image"
    
    case textAttribute = "ic_text_attribute"

}

extension UIView: ICThemeManagerObserver, ICResTextManagerObserver {
    
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

var ICResUIKitAssocaitionKey:Void?

extension ICKit where Base : UIView {

    internal func resHash() -> [String:Any] {
        
        var resHash:[String:Any]? = objc_getAssociatedObject(self.base, &ICResUIKitAssocaitionKey) as? [String:Any]
        if resHash == nil {
            resHash = [:]
            objc_setAssociatedObject(self.base, &ICResUIKitAssocaitionKey, resHash, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            ICThemeManager.shared.add(self.base)
            ICResTextManager.shared.add(self.base)
        }
        return resHash!
    }
    
    internal func updateHash(_ resHash:[String:Any]) {

        objc_setAssociatedObject(self.base, &ICResUIKitAssocaitionKey, resHash, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    internal func setResValue(_ value:Any, forKey:String) {
        var resHash = self.resHash()
        resHash[forKey] = value
        
        self.updateHash(resHash)
    }
    
    internal func resValue(_ forKey:String) -> Any? {
        return self.resHash()[forKey]
    }
    
    //-------------- background color -----------------
    public func setBackgroundColor(key:String) {
        self.setResValue(key, forKey: ICResKey.backgroundColor.rawValue)
        self.base.backgroundColor = ICRes.color(key)
    }
}

extension UIButton {
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        for (key, value) in self.ic.resStateHash(ICResKey.titleColor.rawValue) {
            self.setTitleColor(ICRes.color(value), for: UIControl.State(rawValue: key))
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
            self.setTitle(ICRes.text(value), for: UIControl.State(rawValue: key))
        }
    }
}

extension ICKit where Base : UIButton {
    
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
    
    //-------------- title -----------------
    public func setTitle(key:String, state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.title.rawValue, forState:state)
        self.base.setTitle(ICRes.text(key), for: state)
    }

    //-------------- title color -----------------
    public func setTitleColor(key:String, state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.titleColor.rawValue, forState:state)
        self.base.setTitleColor(ICRes.color(key), for: state)
    }
    
    //-------------- image -----------------
    public func setImage(key:String, state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.image.rawValue, forState:state)
        self.base.setImage(ICRes.image(key), for: state)
    }
    
    //-------------- background image -----------------
    public func setBackgroundImage(key:String, state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.backgroundImage.rawValue, forState:state)
        self.base.setBackgroundImage(ICRes.image(key), for: state)
    }
}

extension UILabel {
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        if let textColorKey:String = self.ic.resValue(ICResKey.titleColor.rawValue) as? String {
            self.textColor = ICRes.color(textColorKey)
        }
    }
    
    override open func didLanguageChanged() {
        super.didLanguageChanged()
        
        if let key:String = self.ic.resValue(ICResKey.title.rawValue) as? String {
            self.text = ICRes.text(key)
        }
    }
}

extension ICKit where Base : UILabel {

    //-------------- text color -----------------
    public func setTextColor(key:String) {
        self.setResValue(key, forKey: ICResKey.titleColor.rawValue)
        self.base.textColor = ICRes.color(key)
    }

    //-------------- text -----------------
    public func setText(key:String) {
        self.setResValue(key, forKey: ICResKey.title.rawValue)
        self.base.text = ICRes.text(key)
        ICResTextManager.shared.add(self.base)
    }
}

extension UITextField {
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        if let textColorKey:String = self.ic.resValue(ICResKey.titleColor.rawValue) as? String {
            self.textColor = ICRes.color(textColorKey)
        }
    }
    
    override open func didLanguageChanged() {
        super.didLanguageChanged()
        
        if let key:String = self.ic.resValue(ICResKey.title.rawValue) as? String {
            self.text = ICRes.text(key)
        }
    }
}

extension ICKit where Base : UITextField {
    
    //-------------- text color -----------------
    public func setTextColor(key:String) {
        self.setResValue(key, forKey: ICResKey.titleColor.rawValue)
        self.base.textColor = ICRes.color(key)
    }
    
    //-------------- text -----------------
    public func setText(key:String) {
        self.setResValue(key, forKey: ICResKey.title.rawValue)
        self.base.text = ICRes.text(key)
        
        ICResTextManager.shared.add(self.base)
    }
}

extension UIImageView {
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        if let key:String = self.ic.resValue(ICResKey.image.rawValue) as? String {
            self.image = ICRes.image(key)
        }
    }
}

extension ICKit where Base : UIImageView {

    //-------------- text -----------------
    public func setImage(key:String) {
        self.setResValue(key, forKey: ICResKey.image.rawValue)
        self.base.image = ICRes.image(key)
    }
}
