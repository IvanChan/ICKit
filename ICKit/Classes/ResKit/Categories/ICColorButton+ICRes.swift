//
//  ICColorButton+ICRes.swift
//  ICFoundation
//
//  Created by _ivanC on 2018/7/29.
//

import UIKit

extension ICColorButton {
    
    private static let ICBackgroundColorHashKey = "ICBackgroundColorHashKey"
    private static let ICBorderColorHashKey = "ICBorderColorHashKey"
    private static let ICTintColorHashKey = "ICTintColorHashKey"
    
    
    //-------------- Background color -----------------
    public func setBackgroundColor(forICResName key:String, state: UIControl.State) {
        self.ic_saveResKey(key, forHashKey: ICColorButton.ICBackgroundColorHashKey)
        self.setBackgroundColor(resGetColor(key), for: state)
    }
    
    //-------------- Border color -----------------
    public func setBorderColor(forICResName key:String, state: UIControl.State) {
        self.ic_saveResKey(key, forHashKey: ICColorButton.ICBorderColorHashKey)
        self.setBorderColor(resGetColor(key), for: state)
    }
    
    //-------------- Tint color -----------------
    public func setTintColor(forICResName key:String, state: UIControl.State) {
        self.ic_saveResKey(key, forHashKey: ICColorButton.ICTintColorHashKey)
        self.setTintColor(resGetColor(key), for: state)
    }
    
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        for (key, value) in self.ic_resStateHash(ICColorButton.ICBackgroundColorHashKey) {
            self.setBackgroundColor(resGetColor(value), for: UIControl.State(rawValue: key))
        }
        
        for (key, value) in self.ic_resStateHash(ICColorButton.ICBorderColorHashKey) {
            self.setBorderColor(resGetColor(value), for: UIControl.State(rawValue: key))
        }
        
        for (key, value) in self.ic_resStateHash(ICColorButton.ICTintColorHashKey) {
            self.setTintColor(resGetColor(value), for: UIControl.State(rawValue: key))
        }
    }
}
