//
//  QuitItem.swift
//  StyleRemover
//
//  Created by Hori,Masaki on 2020/01/14.
//  Copyright © 2020 Hori,Masaki. All rights reserved.
//

import Cocoa
import Combine

struct QuitItem: StatusItem {
    
    let menuItem = NSMenuItem()
    
    private var cancellalbes: [AnyCancellable] = []
    
    init() {
        
        menuItem.title = LocalizedStrings.quitFormat.string(AppDelegate.appName)
        menuItem
            .actionPublisher()
            .sink { _ in NSApplication.shared.terminate(nil) }
            .store(in: &cancellalbes)
    }
}
