//
//  StatusItem.swift
//  StyleRemover
//
//  Created by Hori,Masaki on 2020/01/14.
//  Copyright © 2020 Hori,Masaki. All rights reserved.
//

import Cocoa

protocol StatusItem {
    
    var menuItem: NSMenuItem { get }
}

protocol UpdatableStatusItem: StatusItem {
    
    func update()
}

struct SeparatorItem: StatusItem {
    
    let menuItem = NSMenuItem.separator()
}
