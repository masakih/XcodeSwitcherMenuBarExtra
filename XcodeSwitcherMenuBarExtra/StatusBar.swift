//
//  StatusBar.swift
//  StyleRemover
//
//  Created by Hori,Masaki on 2020/01/14.
//  Copyright © 2020 Hori,Masaki. All rights reserved.
//

import Cocoa
import Combine

final class StatusBar: NSObject, NSMenuDelegate {
    
    private let myStatusBar: NSStatusItem
    private var menu: NSMenu
    
    private var xcodeItems: [StatusItem] = []
    private let basicItems: [StatusItem] = [
        SeparatorItem(),
        QuitItem()
    ]
            
    override init() {
        
        myStatusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        menu = NSMenu()
        
        myStatusBar.menu = menu
        myStatusBar.button?.image = NSImage(named: "MenuBarIconTemplate")
        
        super.init()
        
        menu.delegate = self
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        xcodeItems = XcodeSearcher
            .searchInApplications()
            .map(XcodeMenuItem.init(xcode:))
        
        let menus = xcodeItems + basicItems
        
        menus
            .compactMap { $0 as? UpdatableStatusItem }
            .forEach { $0.update() }
        
        menu.removeAllItems()
        menu.items = menus.map(\.menuItem)
    }
}
