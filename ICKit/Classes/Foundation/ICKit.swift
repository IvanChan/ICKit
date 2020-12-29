//
//  ICKit.swift
//  ICFoundation
//
//  Created by _ivanC on 2018/6/29.
//

import Foundation

public final class ICKit<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol ICKitCompatible {
    associatedtype CompatibleType
    var ic: CompatibleType { get }
}

public extension ICKitCompatible {
    var ic: ICKit<Self>{
        get { return ICKit(self) }
    }
}

extension String: ICKitCompatible {}
extension UIScreen: ICKitCompatible {}
extension UIView: ICKitCompatible {}
extension UIViewController: ICKitCompatible {}


