//
//  Announce.swift
//  XcodeSwitcherMenuBarExtra
//
//  Created by Hori,Masaki on 2021/06/03.
//

import AppKit

struct Announce {
    
    struct Connfiguration {
        
        struct ButtonAttribute {
            
            let title: String
            let keyEquivalent: String?
            let keyEquivalentModifierMask: NSEvent.ModifierFlags
            
            init(title: String, keyEquivalent: String? = nil, keyEquivalentModifierMask: NSEvent.ModifierFlags = []) {
                
                self.title = title
                self.keyEquivalent = keyEquivalent
                self.keyEquivalentModifierMask = keyEquivalentModifierMask
            }
        }
        
        let style: NSAlert.Style
        let messageText: String
        let informativeText: String
        let buttonAttributes: [ButtonAttribute]
        
        
        init(style: NSAlert.Style = .informational,
             messageText: String,
             informativeText: String,
             buttonAttributes: [Announce.Connfiguration.ButtonAttribute] = []) {
            
            self.style = style
            self.messageText = messageText
            self.informativeText = informativeText
            self.buttonAttributes = buttonAttributes
        }
    }
    
    let configration: Connfiguration
    
    @discardableResult
    func show() -> NSApplication.ModalResponse {
        
        let alert = NSAlert()
        
        alert.alertStyle = configration.style
        
        configration.buttonAttributes
            .forEach { attr in
                
                alert.addButton(withTitle: attr.title)
            }
        alert.buttons
            .map { ($0, $0.title) }
            .forEach { button, title in
                
                if let attr = configration.buttonAttributes
                    .first(where: { $0.title == title } ) {
                    
                    attr.keyEquivalent.map { button.keyEquivalent = $0 }
                    button.keyEquivalentModifierMask = attr.keyEquivalentModifierMask
                }
            }
        
        alert.messageText = configration.messageText
        alert.informativeText = configration.informativeText
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        return alert.runModal()
    }
}