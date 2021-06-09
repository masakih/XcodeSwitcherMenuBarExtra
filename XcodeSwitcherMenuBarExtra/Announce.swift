//
//  Announce.swift
//  XcodeSwitcherMenuBarExtra
//
//  Created by Hori,Masaki on 2021/06/03.
//

import AppKit

struct Announce {
    
    struct Configuration {
        
        struct ButtonAttribute {
            
            let title: String
            let keyEquivalent: String?
            let keyEquivalentModifierMask: NSEvent.ModifierFlags
            
            init(title: String,
                 keyEquivalent: String? = nil,
                 keyEquivalentModifierMask: NSEvent.ModifierFlags = []) {
                
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
             buttonAttributes: [Announce.Configuration.ButtonAttribute] = []) {
            
            self.style = style
            self.messageText = messageText
            self.informativeText = informativeText
            self.buttonAttributes = buttonAttributes
        }
    }
    
    let configration: Configuration
    
    @discardableResult
    func show() -> NSApplication.ModalResponse {
        
        let alert = NSAlert()
        
        alert.alertStyle = configration.style
        
        configration.buttonAttributes
            .forEach { attr in
                
                alert.addButton(withTitle: attr.title)
            }
        alert.buttons
            .forEach { button in
                
                if let attr = configration.buttonAttributes.first(where: { $0.title == button.title }),
                   let keyEquivalent = attr.keyEquivalent {
                    
                    button.keyEquivalent = keyEquivalent
                    button.keyEquivalentModifierMask = attr.keyEquivalentModifierMask
                }
            }
        
        alert.messageText = configration.messageText
        alert.informativeText = configration.informativeText
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        return alert.runModal()
    }
}
