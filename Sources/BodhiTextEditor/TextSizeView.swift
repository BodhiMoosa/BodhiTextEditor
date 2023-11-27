//
//  TextSizePopUpView.swift
//  CustomTextEditor
//
//  Created by Tayler Moosa on 9/11/23.
//

import SwiftUI

public struct TextSizeView: View {
    @Binding var attribText         : NSAttributedString
    @Binding var range              : NSRange?
    @State var increment : CGFloat  = 12
    @State var test: Int            = 34
    let values: [CGFloat]           = Array(stride(from: 0.0, through: 72.0, by: 2.0))
    public var body: some View {

            VStack {
                Picker("Text Size", selection: $increment) {
                    ForEach(values, id: \.self) { value in
                        Text("\(Int(value))").tag(value)
                    }
                }
                .onChange(of: increment) { newIncrement in
                    attribText = changeFontSizeWithNumber(of: attribText, to: newIncrement, range: range)
                }
            }
            .onChange(of: range) { newRange in
                guard let range = range else { return }
                increment = returnCurrentFontSize(attribText: attribText, range: range)
            }
            

    }
    public func returnCurrentFontSize(attribText: NSAttributedString, range: NSRange?) -> CGFloat {
        var currentSize : CGFloat = 0
        guard let range = range else { return currentSize }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attribText)
        mutableAttributedString.enumerateAttribute(.font, in: range, options: []) { (value, range, stop) in
            if let oldFont = value as? NSFont {
                currentSize = oldFont.pointSize
            } else {
                currentSize = 12
            }
        }
        if currentSize == 0 {
            currentSize = fontSize(at: range.location, in: attribText) ?? 0
        }
        return currentSize
    }

    public func changeFontSizeWithNumber(of attribText: NSAttributedString, to newSize: CGFloat, range: NSRange?) -> NSAttributedString {
        guard let range = range else { return attribText }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attribText)
        
        mutableAttributedString.enumerateAttribute(.font, in: range, options: []) { (value, range, stop) in
            if let oldFont = value as? NSFont {
                let newFont = NSFont(descriptor: oldFont.fontDescriptor, size: newSize) ?? NSFont.systemFont(ofSize: newSize)
                mutableAttributedString.addAttribute(.font, value: newFont, range: range)
            }
        }
        
        return mutableAttributedString
    }

    public func fontSize(at caretPosition: Int, in attributedText: NSAttributedString) -> CGFloat? {
        // Ensure the caret position is within the bounds of the attributed text.
        guard caretPosition <= attributedText.length && caretPosition > 0 else {
            return nil
        }
        // Get the font attribute at the caret position.
        let attributes = attributedText.attributes(at: caretPosition - 1, effectiveRange: nil)
        if let font = attributes[.font] as? NSFont { // Use NSFont for macOS instead of UIFont
            return font.pointSize
        }
        return nil
    }
}





