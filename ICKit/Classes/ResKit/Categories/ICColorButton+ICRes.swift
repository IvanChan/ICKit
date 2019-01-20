//
//  ICColorButton+ICRes.swift
//  ICFoundation
//
//  Created by _ivanC on 2018/7/29.
//

import UIKit

extension ICColorButton {
    
    override open func didThemeChanged() {
        super.didThemeChanged()
        
        for (key, value) in self.ic.resStateHash(ICResKey.backgroundColor.rawValue) {
            self.setBackgroundColor(ICRes.color(value), for: UIControl.State(rawValue: key))
        }
        
        for (key, value) in self.ic.resStateHash(ICResKey.borderColor.rawValue) {
            self.setBorderColor(ICRes.color(value), for: UIControl.State(rawValue: key))
        }
        
        for (key, value) in self.ic.resStateHash(ICResKey.tintColor.rawValue) {
            self.setTintColor(ICRes.color(value), for: UIControl.State(rawValue: key))
        }
    }
}

extension ICKit where Base : ICColorButton {
    
    //-------------- Background color -----------------
    public func setBackgroundColor(key:String, state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.backgroundColor.rawValue, forState: state)
        self.base.setBackgroundColor(ICRes.color(key), for: state)
    }
    
    //-------------- Border color -----------------
    public func setBorderColor(key:String, state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.borderColor.rawValue, forState: state)
        self.base.setBorderColor(ICRes.color(key), for: state)
    }
    
    //-------------- Tint color -----------------
    public func setTintColor(key:String, state: UIControl.State) {
        self.saveResKey(key, forHashKey: ICResKey.tintColor.rawValue, forState: state)
        self.base.setTintColor(ICRes.color(key), for: state)
    }
}
