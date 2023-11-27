//
//  LinkPopUpView.swift
//  CustomTextEditor
//
//  Created by Tayler Moosa on 9/10/23.
//

import SwiftUI

public struct LinkPopUpView: View {
    @State var isAlert      = false
    @State var alertText    = ""
    var textToLInk          : String
    @Binding var isShown    : Bool
    @Binding var currentLink: String
    @State var newLink      = ""
    @Binding var attribText : NSAttributedString
    @Binding var range      : NSRange?
    
    public var body: some View {
        ZStack {
            Color(.sRGB, red: 0/255, green: 76/255, blue: 153/255, opacity: 1)
            VStack(spacing: 9) {
                Text("Selected Text: \(textToLInk)")
                if currentLink != "" {
                    Text("Previous link to replace: \(currentLink)")
                }
                TextField("https://...", text: $newLink, onCommit: {
                    saveButton()
                })
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5.0)
                    .padding(.top)
                    
                HStack(spacing: 20) {
                    Button {
                        saveButton()
                    } label: {
                        Text("Save")
                            .frame(width: 50, height: 25)
                            .background(Color.secondary.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke( Color.primary.opacity(0.1), lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    if returnLinksInSelectedText(in: attribText, range: range).count != 0 {
                        Button {
                            guard let range = range else { return }
                            let currentAttributes = attribText.attributes(at: range.location, effectiveRange: nil)
                            if currentAttributes[.link] != nil {
                                // Link attribute exists. You can now override or remove it.
                                let mutableAttrib = NSMutableAttributedString(attributedString: attribText)
                                mutableAttrib.removeAttribute(.link, range: range)
                                attribText = mutableAttrib
                                self.isShown = false
                            }
                        } label: {
                            Text("Unlink")
                                .frame(width: 50, height: 25)
                                .background(Color.secondary.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke( Color.primary.opacity(0.1), lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    Button {
                        currentLink     = ""
                        self.isShown    = false
                    } label: {
                        Text("Cancel")
                            .frame(width: 50, height: 25)
                            .background(Color.secondary.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke( Color.primary.opacity(0.1), lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    
                }
            }
            .padding()
        }
        .onAppear {
            let existingURLs = returnLinksInSelectedText(in: attribText, range: range)
            if existingURLs.count == 1 {
                currentLink = existingURLs.first!.absoluteString
            } else if existingURLs.count > 1 {
                currentLink = "Multiple"
            }
        }
        .alert(alertText, isPresented: $isAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    public func saveButton() {
        currentLink = newLink
        guard let url = URL(string: newLink) else {
            isAlert = true
            alertText = "The URL Is Not Valid"
            return
        }
        guard let range = range else {
            isAlert = true
            alertText = "Invalid Selection"
            return
            
        }
        guard range.location >= 0,
              range.length >= 0,
              (range.location + range.length) <= attribText.length
        else {
            alertText = "Um.. something went wrong"
            isAlert = true
            return
        }
        guard range.length > 0 else {
            alertText = "No Text Selected"
            isAlert = true
            return
        }
        let currentAttributes = attribText.attributes(at: range.location, effectiveRange: nil)
        if currentAttributes[.link] != nil {
            // Link attribute exists. You can now override or remove it.
            let mutableAttrib = NSMutableAttributedString(attributedString: attribText)
            mutableAttrib.addAttribute(.link, value: url, range: range)
            attribText = mutableAttrib
        } else {
            let mutableAttrib = NSMutableAttributedString(attributedString: attribText)
            mutableAttrib.addAttribute(.link, value: url, range: range)
            attribText = mutableAttrib
        }
        currentLink = ""
        self.isShown = false
    }
    
    public func returnLinksInSelectedText(in attribText: NSAttributedString, range: NSRange?) -> [URL] {
        guard let range = range else { return [] }
        var index = range.location
        let end = range.location + range.length
        var uniqueLinks = Set<URL>()
        
        while index < end {
            var effectiveRange: NSRange = NSRange()
            let currentAttributes = attribText.attributes(at: index, effectiveRange: &effectiveRange)
            
            if let link = currentAttributes[.link] as? URL {
                uniqueLinks.insert(link)
            }
            
            index = effectiveRange.location + effectiveRange.length
        }
        return Array(uniqueLinks)
    }

}



