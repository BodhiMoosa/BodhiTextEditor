// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//
//  CustomTextEditor.swift
//  CustomTextEditor
//
//  Created by Tayler Moosa on 9/8/23.
//

import SwiftUI

public struct BodhiTextEditor: View {
    let padding: CGFloat                            = 10
    @State var height                               : CGFloat
    @State var width                                : CGFloat
    @Binding var range                              : NSRange?
    @Binding var attribText                         : NSAttributedString
    @State var link: String                         = ""
    @State private var bgColor                      = Color(.sRGB, red: 1, green: 1, blue: 1)
    @Binding var isEditing                          : Bool
    @State private var isLinkPopUpPresented: Bool   = false

    public init(height: CGFloat,
                width: CGFloat,
                range: Binding<NSRange?>,
                attribText: Binding<NSAttributedString>, // Use Binding here
                link: String,
                bgColor: SwiftUI.Color = Color(.sRGB, red: 1, green: 1, blue: 1),
                isLinkPopUpPresented: Bool,
                isEditing: Binding<Bool>)
    {
        self._height                = State(initialValue: height) // Use _propertyName for State properties
        self._width                 = State(initialValue: width)   // Use _propertyName for State properties
        self._range                 = range   // Use _propertyName for State properties
        self._attribText            = attribText              // Directly assign Binding property
        self._link                  = State(initialValue: link)     // Use _propertyName for State properties
        self._bgColor               = State(initialValue: bgColor) // Use _propertyName for State properties
        self._isLinkPopUpPresented  = State(initialValue: isLinkPopUpPresented) // Use _propertyName for State properties
        self._isEditing             = isEditing
    }

    
  
    public var body: some View {

        VStack {
            ZStack(alignment: .topLeading) {
                InternalCustomTextEditor(text: $attribText, rangeSelected: $range, height: $height, width: $width, isDisabled: $isEditing)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 0)
                            .padding(.all, padding)
                    )
            }
            .onChange(of: isEditing) { newValue in
                if !isEditing { range = NSRange(location: attribText.length, length: 0) }
            }
            if isEditing {
                HStack {
                    CustomButtonView(buttonText: "bold", attribText: $attribText, range: $range, fontMask: .boldFontMask, isUnderline: false)
                        .keyboardShortcut("b", modifiers: [.command])
                    CustomButtonView(buttonText: "italic", attribText: $attribText, range: $range, fontMask: .italicFontMask, isUnderline: false)
                        .keyboardShortcut("i", modifiers: [.command])
                    CustomButtonView(buttonText: "underline", attribText: $attribText, range: $range, isUnderline: true)
                        .keyboardShortcut("u", modifiers: [.command])

                    Button {
                        self.isLinkPopUpPresented.toggle()
                    } label: {
                        Text("Link")
                            .frame(width: 50, height: 25)
                            .background(Color.secondary.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke( Color.primary.opacity(0.1), lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    TextSizeView(attribText: $attribText, range: $range)
                    ColorPicker("Font Color", selection: $bgColor)
                }
                .frame(width: width)
            }

            Spacer()
        }

        .sheet(isPresented: $isLinkPopUpPresented) {
            LinkPopUpView(textToLInk: attribText.substring(with: range) ?? "", isShown: self.$isLinkPopUpPresented, currentLink: $link, newLink: link, attribText: $attribText, range: $range)
                .frame(idealWidth: 500)
        }
        
    }
}

public struct InternalCustomTextEditor: NSViewRepresentable {
    @Binding var text                       : NSAttributedString
    @Binding var rangeSelected              : NSRange?
    let padding                             : CGFloat = 10
    @Binding var height                     : CGFloat
    @Binding var width                      : CGFloat
    @Binding var isDisabled                 : Bool
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, range: $rangeSelected)
    }
    
    
    public func makeNSView(context: Context) -> NSScrollView {
        let textView                                = CustomTextView()
        textView.delegate                           = context.coordinator
        textView.backgroundColor                    = .white
        textView.textContainerInset                 = NSSize(width: padding, height: padding)
        textView.isVerticallyResizable              = true  // this should be true for scrolling
        textView.isHorizontallyResizable            = true
        textView.autoresizingMask                   = [.width, .height]
        textView.textContainer?.size                = NSSize(width: 0, height: 0)
        textView.textColor                          = .black
        textView.isContinuousSpellCheckingEnabled   = true
        textView.isGrammarCheckingEnabled           = true
        textView.isAutomaticTextReplacementEnabled  = false
        textView.selectedTextAttributes             = [        .backgroundColor: NSColor.black.withAlphaComponent(0.2),
                                                               .foregroundColor: NSColor.black
        ]
  

        NotificationCenter.default.addObserver(context.coordinator, selector: #selector(Coordinator.textDidChange(_:)), name: NSText.didChangeNotification, object: textView)
        
        // Wrapping the textView inside an NSScrollView
        let scrollView                      = NSScrollView()
        scrollView.borderType               = .noBorder
        scrollView.hasVerticalScroller      = true
        scrollView.hasHorizontalScroller    = true
        scrollView.allowsMagnification      = true
        scrollView.magnification            = 1
        scrollView.documentView             = textView
        scrollView.backgroundColor          = .white
        //scrollView.setFrameSize(NSSize(width: 0, height: 0))
        return scrollView
    }
    
    
    
    public func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView      = nsView.documentView as? NSTextView else { return }
        textView.isEditable     = isDisabled
        textView.isSelectable   = isDisabled
        if textView.textStorage != text {
            DispatchQueue.main.async {
                textView.textStorage?.setAttributedString(text)
                //the following ensures the selection remains after modifying the selected text
                guard let selecteRange = self.rangeSelected else { return }
                textView.setSelectedRange(selecteRange)
            }
        }
    }
    
  


    
    public class Coordinator: NSObject, NSTextViewDelegate {
        var text    : Binding<NSAttributedString>
        var range   : Binding<NSRange?>
        init(text: Binding<NSAttributedString>, range: Binding<NSRange?>) {
            self.text   = text
            self.range  = range
        }
        
        @objc public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            if textView.textStorage != text.wrappedValue {
                DispatchQueue.main.async {
                    self.text.wrappedValue = textView.textStorage!
                }
            }
        }
        
        public func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            DispatchQueue.main.async {
                let rangeToPassBack: NSRange = textView.selectedRange
                self.range.wrappedValue = rangeToPassBack
            }
        }
    }
}


public extension NSFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.bold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.italic)
    }
}

public enum FormatOptions {
    case bold
    case italics
    case underlined
    case link
}

public func checkForFormatting(attribText: NSAttributedString, range: NSRange) -> [FormatOptions] {
    var formatOptionsActive : [FormatOptions] = []
    let attributes = attribText.attributes(at: range.location, effectiveRange: nil)
    if let font = attributes[.font] as? NSFont {
        if font.isBold {
            formatOptionsActive.append(.bold)
        }
        if font.isItalic {
            formatOptionsActive.append(.italics)
        }
    }
    if attributes[.underlineStyle] != nil {
        formatOptionsActive.append(.underlined)
    }
    if attributes[.link] != nil {
        formatOptionsActive.append(.link)
    }
    return formatOptionsActive
}

public func checkFontSize(attribText: NSAttributedString, range: NSRange) -> CGFloat {
    var fontSize : CGFloat = 12
    let attributes = attribText.attributes(at: range.location, effectiveRange: nil)
    if let font = attributes[.font] as? NSFont {
        fontSize = font.pointSize
    }
    return fontSize
}





//public func copyAttributedStringToPB(attribString: NSAttributedString) {
//    
//    do {
//        let documentAttributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf]
//        let rtfData = try attribString.data(from: NSMakeRange(0, attribString.length), documentAttributes: documentAttributes)
//        let pb = NSPasteboard.general
//        pb.setData(rtfData, forType: .string)
//        //pb.setData(rtfData, forPasteboardType: kUTTypeRTF as String)
//    }
//    catch {
//        print("error creating RTF from Attributed String")
//    }
//}



public func darkModeCheck() -> Bool {
    if #available(OSX 10.14, *) {
        let appearance = NSApp.effectiveAppearance
        if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            return true
        }
    }
    return false
}


//public func checkAllAttributesWithinRange(range: NSRange?, text: NSAttributedString) {
//    guard let range = range else { return }
//    text.enumerateAttributes(in: range, options: []) { (attributes, subrange, stop) in
//        if let color = attributes[.foregroundColor] as? NSColor {
//            
//        }
//    }
//}




class CustomTextView: NSTextView {

    override func becomeFirstResponder() -> Bool {
        let becomingFirstResponder = super.becomeFirstResponder()
        if becomingFirstResponder {
        }
        return becomingFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        let resigningFirstResponder = super.resignFirstResponder()
        if resigningFirstResponder {
        }
        return resigningFirstResponder
    }
}
