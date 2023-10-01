//
//  CustomButtonView.swift
//  CustomTextEditor
//
//  Created by Tayler Moosa on 9/10/23.
//

import SwiftUI

public struct CustomButtonView: View {
    var buttonText          : String
    @Binding var attribText : NSAttributedString
    @Binding var range      : NSRange?
    var fontMask            : NSFontTraitMask?
    var isUnderline         : Bool
    public var body: some View {
        Button(action: {
            if let fontMask = fontMask {
                attribText = toggleFont(formatOption: fontMask, attribText: attribText, range: range)
                
            } else if isUnderline {
                attribText = toggleUnderline(range: range, attribText: attribText)
            }
            
        }) {
            Image(systemName: buttonText)
                .frame(width: 50, height: 25)
                .background(Color.secondary.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke( Color.primary.opacity(0.1), lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .shadow(color: Color.clear, radius: 0, x: 0, y: 0)

    }
    
    public func toggleFont(formatOption: NSFontTraitMask, attribText: NSAttributedString, range: NSRange?) -> NSAttributedString {
        guard let range = range, range.length > 0 else { return attribText }
        
        var attributes = attribText.attributes(at: range.location, effectiveRange: nil)
        
        guard let currentFont : NSFont = attributes[.font] as? NSFont else {
            return attribText
        }
        let fontManager = NSFontManager.shared
        var newTraits: NSFontTraitMask = fontManager.traits(of: currentFont)
        
        if addFormat(in: attribText, range: range, formatOption: formatOption) {
            newTraits.insert(formatOption)
        } else {
            newTraits.remove(formatOption)
        }

        let combinedFont = fontManager.font(withFamily: currentFont.familyName ?? "",
                                            traits: newTraits,
                                            weight: 5,
                                            size: currentFont.pointSize) ?? currentFont
        
        attributes = [.font: combinedFont]
        let mutableAttribText = NSMutableAttributedString(attributedString: attribText)
        mutableAttribText.addAttributes(attributes, range: range)
        
        return mutableAttribText
    }

    public func toggleUnderline(range: NSRange?, attribText: NSAttributedString) -> NSAttributedString {
        guard let range = range else { return attribText }
        
        let mutableAttribText = NSMutableAttributedString(attributedString: attribText)
        
        // Check if the text at the beginning of the range is already underlined
        let currentAttributes = attribText.attributes(at: range.location, effectiveRange: nil)
        if let underlineStyle = currentAttributes[.underlineStyle] as? NSNumber, underlineStyle.intValue == NSUnderlineStyle.single.rawValue {
            // Text is currently underlined, so remove the underline
            mutableAttribText.removeAttribute(.underlineStyle, range: range)
        } else {
            // Text is not underlined, so add the underline
            let attributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
            mutableAttribText.addAttributes(attributes, range: range)
        }

        return mutableAttribText
    }


    public func addFormat(in attribText: NSAttributedString, range: NSRange?, formatOption: NSFontTraitMask) -> Bool {
        var result      = false
        guard let range = range else { return result }
        var index       = range.location
        let end         = range.location + range.length
        var collection : Set<Bool> = []
        while index < end {
            var effectiveRange: NSRange = NSRange()
            let currentAttributes = attribText.attributes(at: index, effectiveRange: &effectiveRange)
            
            guard let currentFont : NSFont = currentAttributes[.font] as? NSFont else { return result }
            let fontManager = NSFontManager.shared
            let newTraits: NSFontTraitMask = fontManager.traits(of: currentFont)
            if newTraits.contains(formatOption) {
                collection.insert(true)
            } else {
                collection.insert(false)
            }
            index = effectiveRange.location + effectiveRange.length
        }
        if collection.count == 2 {
            result = true
        } else if collection.count == 1 {
            if collection.first == true {
                result = false
            } else {
                result = true
            }
        }
        return result
    }
}


