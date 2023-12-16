//
//  File.swift
//  
//
//  Created by Tayler Moosa on 12/16/23.
//

import SwiftUI

public struct FontChangeView: View {
    @Binding var attribText         : NSAttributedString
    @Binding var range              : NSRange?
    let fontNames = NSFontManager.shared.availableFontFamilies
    @Binding var selectedFont: String 
    public var body: some View {

            VStack {
                Picker("Select a font", selection: $selectedFont) {
                          ForEach(fontNames, id: \.self) { fontName in
                              Text(fontName).tag(fontName)
                          }
                      }
                      .pickerStyle(MenuPickerStyle())
                      .onChange(of: selectedFont) { newValue in
                          attribText = changeFont(of: attribText, to: selectedFont, range: range)
                      }
            }
            .onChange(of: range) { newRange in
                guard let range = range else { return }
                let fontFamily = fontFamilyNameInRange(of: attribText, range: range)
                if fontNames.contains(fontFamily) {
                    selectedFont = fontFamily
                }
                
            }
            

    }    
    public func changeFont(of attribText: NSAttributedString, to fontFamily: String, range: NSRange?) -> NSAttributedString {
        guard let range = range else { return attribText }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attribText)

        mutableAttributedString.enumerateAttribute(.font, in: range, options: []) { (value, enumRange, stop) in
            if let oldFont = value as? NSFont {
                var newFontDescriptor = oldFont.fontDescriptor.withFamily(fontFamily)

                if let newFont = NSFont(descriptor: newFontDescriptor, size: newFontDescriptor.pointSize) {
                    mutableAttributedString.addAttribute(.font, value: newFont, range: enumRange)
                }
            }
        }

        return mutableAttributedString
    }
    


    public func fontFamilyNameInRange(of attribText: NSAttributedString, range: NSRange?) -> String {
        guard let range = range else { return "None" }
        
        var foundFontFamily: String?
        var multipleFontFamilies = false
        
        attribText.enumerateAttribute(.font, in: range, options: []) { value, _, stop in
            if let font = value as? NSFont {
                let fontFamily = (font.fontDescriptor.fontAttributes[.family] as? String) ?? font.familyName
                
                if foundFontFamily == nil {
                    // First font family found
                    foundFontFamily = fontFamily
                } else if foundFontFamily != fontFamily {
                    // Another different font family found
                    multipleFontFamilies = true
                    stop.pointee = true
                }
            }
        }
        if multipleFontFamilies {
            return "Many"
        } else if let fontFamily = foundFontFamily {
            return fontFamily
        } else {
            return "None" // or some default value if no font attribute found
        }
    }
}



