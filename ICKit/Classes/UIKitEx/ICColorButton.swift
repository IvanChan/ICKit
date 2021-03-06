//
//  ICColorButton.swift
//  Ico
//
//  Created by _ivanC on 17/01/2018.
//  Copyright © 2018 Ico. All rights reserved.
//

import UIKit

open class ICColorButton: UIButton {

    private lazy var backgroundColorsForStates: [UInt:UIColor] = [:]
    private lazy var borderColorsForStates: [UInt:UIColor] = [:]
    private lazy var tintColorsForStates: [UInt:UIColor] = [:]
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.reloadBackgroundColor()
        self.reloadTintColor()
        self.reloadBorderColor()
    }
    
    //---------------- backgroundColor ------------------
    private func reloadBackgroundColor() {
        self.backgroundColor = self.backgroundColor(for: self.state)
    }
    
    open func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        if color == nil {
            self.backgroundColorsForStates.removeValue(forKey: state.rawValue)
        } else {
            self.backgroundColorsForStates[state.rawValue] = color
            self.reloadBackgroundColor()
        }
    }
    
    open func backgroundColor(for state: UIControl.State) -> UIColor? {
        return self.backgroundColorsForStates[state.rawValue]
    }
    
    //---------------- tint Color ------------------
    private func reloadTintColor() {
        self.tintColor = self.tintColor(for: self.state)
    }
    
    open func setTintColor(_ color: UIColor?, for state: UIControl.State) {
        if color == nil {
            self.tintColorsForStates.removeValue(forKey: state.rawValue)
        } else {
            self.tintColorsForStates[state.rawValue] = color
            self.reloadTintColor()
        }
    }
    
    open func tintColor(for state: UIControl.State) -> UIColor? {
        return self.tintColorsForStates[state.rawValue]
    }
    
    //---------------- border Color ------------------
    private func reloadBorderColor() {
        self.layer.borderColor = self.borderColor(for: self.state)?.cgColor
    }
    
    open func setBorderColor(_ color: UIColor?, for state: UIControl.State) {
        if color == nil {
            self.borderColorsForStates.removeValue(forKey: state.rawValue)
        } else {
            self.borderColorsForStates[state.rawValue] = color
            self.reloadBorderColor()
        }
    }
    
    open func borderColor(for state: UIControl.State) -> UIColor? {
        return self.borderColorsForStates[state.rawValue]
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                reloadBorderColor()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
