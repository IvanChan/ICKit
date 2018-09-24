//
//  ICResUIKitExtensions.swift
//  Ico
//
//  Created by _ivanC on 15/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

extension UIView {

    private static let ICBackgroundColorResKey = "ICBackgroundColorKey"

    internal func ic_resHash() -> [String:Any] {
        
        let key: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "ICResHashAssociatedKey".hashValue)

        var resHash:[String:Any]? = objc_getAssociatedObject(self, key) as? [String:Any]
        if resHash == nil {
            resHash = [:]
            objc_setAssociatedObject(self, key, resHash, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            ICThemeManager.shared.addObserver(self)
        }
        return resHash!
    }
    
    internal func updateHash(_ resHash:[String:Any]) {
        let key: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "ICResHashAssociatedKey".hashValue)
        objc_setAssociatedObject(self, key, resHash, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    open func ic_setResValue(_ value:Any, forKey:String) {
        var resHash = self.ic_resHash()
        resHash[forKey] = value
        
        self.updateHash(resHash)
    }
    
    internal func ic_resValue(_ forKey:String) -> Any? {
        return self.ic_resHash()[forKey]
    }
    
    //-------------- background color -----------------
    public func setBackgroundColor(forICResName key:String) {
        self.ic_setResValue(key, forKey: UIView.ICBackgroundColorResKey)
        self.backgroundColor = resGetColor(key)
    }
    
    @objc open func didThemeChanged() {
        if let bgColorResKey:String = self.ic_resValue(UIView.ICBackgroundColorResKey) as? String {
            self.backgroundColor = resGetColor(bgColorResKey)
        }
    }
    
    @objc open func didLanguageChanged() {
        
    }
}

extension UIButton {
    
    private static let ICTitleHashKey = "ICTitleHashKey"
    private static let ICTitleColorHashKey = "ICTitleColorHashKey"

    private static let ICImageHashKey = "ICImageHashKey"
    private static let ICBgImageHashKey = "ICBgImageHashKey"

    open func ic_resStateHash(_ key: String) -> [UInt:String] {
        var hash:[UInt:String]? = self.ic_resValue(key) as? [UInt:String]
        if hash == nil {
            hash = [:]
            self.ic_setResValue(hash!, forKey: key)
        }
        return hash!
    }
    
    open func ic_saveResKey(_ key:String, forHashKey: String) {
        var hash = self.ic_resStateHash(forHashKey)
        hash[state.rawValue] = key
        
        self.ic_setResValue(hash, forKey: forHashKey)
    }
    
    //-------------- title -----------------
    public func setTitle(forICResName key:String, state: UIControl.State) {
        self.ic_saveResKey(key, forHashKey: UIButton.ICTitleHashKey)
        self.setTitle(resGetText(key), for: state)
    }

    //-------------- title color -----------------
    public func setTitleColor(forICResName key:String, state: UIControl.State) {
        self.ic_saveResKey(key, forHashKey: UIButton.ICTitleColorHashKey)
        self.setTitleColor(resGetColor(key), for: state)
    }
    
    //-------------- image -----------------
    public func setImage(forICResName key:String, state: UIControl.State) {
        self.ic_saveResKey(key, forHashKey: UIButton.ICImageHashKey)
        self.setImage(resGetImage(key), for: state)
    }
    
    //-------------- background image -----------------
    public func setBackgroundImage(forICResName key:String, state: UIControl.State) {
        self.ic_saveResKey(key, forHashKey: UIButton.ICBgImageHashKey)
        self.setBackgroundImage(resGetImage(key), for: state)
    }
    
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        for (key, value) in self.ic_resStateHash(UIButton.ICTitleColorHashKey) {
            self.setTitleColor(resGetColor(value), for: UIControl.State(rawValue: key))
        }
        
        for (key, value) in self.ic_resStateHash(UIButton.ICImageHashKey) {
            self.setImage(resGetImage(value), for: UIControl.State(rawValue: key))
        }
        
        for (key, value) in self.ic_resStateHash(UIButton.ICBgImageHashKey) {
            self.setBackgroundImage(resGetImage(value), for: UIControl.State(rawValue: key))
        }
    }
    
    override open func didLanguageChanged() {
        super.didLanguageChanged()

        for (key, value) in self.ic_resStateHash(UIButton.ICTitleHashKey) {
            self.setTitle(resGetText(value), for: UIControl.State(rawValue: key))
        }
    }
}

extension UILabel {
    
    private static let ICTextColorResKey = "ICTextColorResKey"
    private static let ICTextResKey = "ICTextResKey"

    //-------------- text color -----------------
    public func setTextColor(forICResName key:String) {
        self.ic_setResValue(key, forKey: UILabel.ICTextColorResKey)
        self.textColor = resGetColor(key)
    }

    //-------------- text -----------------
    public func setText(forICResName key:String) {
        self.ic_setResValue(key, forKey: UILabel.ICTextResKey)
        self.text = resGetText(key)
        ICResTextManager.shared.addObserver(self)
    }

    override open func didThemeChanged() {
        super.didThemeChanged()
        
        if let textColorKey:String = self.ic_resValue(UILabel.ICTextColorResKey) as? String {
            self.textColor = resGetColor(textColorKey)
        }
    }
    
    override open func didLanguageChanged() {
        super.didLanguageChanged()
        
        if let key:String = self.ic_resValue(UILabel.ICTextResKey) as? String {
            self.text = resGetText(key)
        }
    }
}

extension UITextField {
    
    private static let ICTextColorResKey = "ICTextColorResKey"
    private static let ICTextResKey = "ICTextResKey"
    
    //-------------- text color -----------------
    public func setTextColor(forICResName key:String) {
        self.ic_setResValue(key, forKey: UITextField.ICTextColorResKey)
        self.textColor = resGetColor(key)
    }
    
    //-------------- text -----------------
    public func setText(forICResName key:String) {
        self.ic_setResValue(key, forKey: UITextField.ICTextResKey)
        self.text = resGetText(key)
        
        ICResTextManager.shared.addObserver(self)
    }
    
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        if let textColorKey:String = self.ic_resValue(UITextField.ICTextColorResKey) as? String {
            self.textColor = resGetColor(textColorKey)
        }
    }
    
    override open func didLanguageChanged() {
        super.didLanguageChanged()
        
        if let key:String = self.ic_resValue(UITextField.ICTextResKey) as? String {
            self.text = resGetText(key)
        }
    }
}

extension UIImageView {
    private static let ICImageResKey = "ICImageResKey"

    //-------------- text -----------------
    public func setImage(forICResName key:String) {
        self.ic_setResValue(key, forKey: UIImageView.ICImageResKey)
        self.image = resGetImage(key)
    }
    
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        if let key:String = self.ic_resValue(UIImageView.ICImageResKey) as? String {
            self.image = resGetImage(key)
        }
    }
}
