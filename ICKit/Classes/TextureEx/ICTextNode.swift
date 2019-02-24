//
//  ICTextNode.swift
//  ICKit
//
//  Created by _ivanc on 2019/2/3.
//  Copyright © 2019 _ivanc. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ICTextNode: ASTextNode {
    
    public struct AnalyseType : OptionSet {
        let rawValue: UInt32

        static let link = AnalyseType(rawValue: 1 << 0)
        static let mention = AnalyseType(rawValue: 1 << 1)
    }
    
    lazy var textFont:UIFont = UIFont.systemFont(ofSize: 17)
    lazy var textColor:UIColor = SCColor(.black)
    lazy var linkColor:UIColor = SCColor(.lightBlue)

    var analyseType:AnalyseType = [.link]
    
    var contentText:String? {
        get {
            return self.attributedText?.string
        }
        set {
            if let text = newValue {
                let attributedText = NSMutableAttributedString(string: text)
                self.setupBasic(attributedText)
                
                if self.analyseType.contains(.link) {
                    self.analyseLink(attributedText)
                }
                if self.analyseType.contains(.mention) {
                    self.analyseMention(attributedText)
                }
                
                self.attributedText = customizedContent(attributedText)

            } else {
                self.attributedText = nil
            }
        }
    }
    
    func setupBasic(_ attributedText:NSMutableAttributedString) {
        let range = NSMakeRange(0, attributedText.length)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: range)
        attributedText.addAttribute(NSAttributedString.Key.font, value: textFont, range: range)
        self.isUserInteractionEnabled = false
    }
    
    func analyseLink(_ attributedText:NSMutableAttributedString) {
        
        let text = attributedText.string
        let range = NSMakeRange(0, text.count)

        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        detector?.enumerateMatches(in: text, range: range) {
            (result, _, _) in
            
            guard let result = result else {
                return
            }
            
            if let url = result.url {
                self.isUserInteractionEnabled = true
                attributedText.addAttributes([.underlineColor:UIColor.clear,
                                              .link:url,
                                              .foregroundColor:linkColor],
                                             range: result.range)
            }
        }
    }
    
    func analyseMention(_ attributedText:NSMutableAttributedString) {

    }

    // for subclass override this to add additional content
    func customizedContent(_ attributedText:NSMutableAttributedString) -> NSMutableAttributedString {
        return attributedText
    }
}
