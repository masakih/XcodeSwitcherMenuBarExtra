//
//  XcodeMenuItem.swift
//  XcodeSwitcherMenuBarExtra
//
//  Created by Hori,Masaki on 2021/05/17.
//


import Cocoa
import Combine

final class XcodeMenuItem: UpdatableStatusItem {
    
    let xcode: Xcode
    let menuItem = NSMenuItem()
        
    private let viewController: XcodeMenuItemViewController
    
    private var cancellalbes: [AnyCancellable] = []
    
    init(xcode: Xcode) {
        
        self.xcode = xcode
        self.viewController = XcodeMenuItemViewController(xcode: xcode)
        
        menuItem.view = viewController.view
        menuItem
            .actionPublisher()
            .sink { [weak self] _ in
                
                self?.switchXcodeIfNeed()
            }
            .store(in: &cancellalbes)
    }
    
    func update() {
                
        if XcodeSearcher.currentXcode() == xcode {
            
            viewController.state = .on
        }
        else {
            
            viewController.state = .off
        }
    }
    
    private func switchXcodeIfNeed() {
        
        guard XcodeSearcher.currentXcode() != xcode else {
            
            return
        }
        
        switchXcode()
    }
    
    private func switchXcode() {
        
        do {
            
            defer { switchDeveloperDirectory() }
            
            guard tellQuitRunningXcode() else { return }
            
            quitRunningXcode()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.activateXcode(self.xcode)
        }
    }
    
    private func switchDeveloperDirectory() {
        
        do {
            
            let helperCon = HelperConnector()
            let helper = try helperCon.helper()
            helper.switchDeveloperDirectory(url: self.xcode.url) { exitCode in
                
                guard exitCode == 0 else {
                    
                    print("Helper exit code is", exitCode)
                    return
                }
            }
        }
        catch {
            
            // TODO: Implement
            print(error)
        }
    }
    
    private func tellQuitRunningXcode() -> Bool {
        
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "Don't Quit")
        alert.buttons
            .filter { $0.title == "Don't Quit" }
            .forEach { $0.keyEquivalent = "\u{1b}" }
        alert.messageText = "Do you want to quit the running xcode?"
        alert.informativeText = "Do you want to quit the running xcode?"
        NSApplication.shared.activate(ignoringOtherApps: true)
        return alert.runModal() == .OK
    }
    
    private func quitRunningXcode() {
        
        if XcodeSearcher.runningXcode().isEmpty {
            
            return
        }
        
        let target = NSAppleEventDescriptor(bundleIdentifier: "com.apple.dt.Xcode")
        let appleEvent = NSAppleEventDescriptor.appleEvent(withEventClass: kCoreEventClass,
                                                           eventID: kAEQuitApplication,
                                                           targetDescriptor: target,
                                                           returnID: AEReturnID(kAutoGenerateReturnID),
                                                           transactionID: AETransactionID(kAnyTransactionID))
        do {
            
            let result = try appleEvent.sendEvent(timeout: 1)
            
            // TODO: Implement
            print(result)
        }
        catch {
            
            // TODO: Implement
            print("ERROR sendEvent:", error)
        }
    }
    
    private func activateXcode(_ xcode: Xcode) {
        
        if NSWorkspace.shared.open(xcode.url) {
            
            return
        }
        
        let alert = NSAlert()
        
        alert.alertStyle = .informational
        alert.messageText = "Failed to start Xcode"
        alert.informativeText = "Failed to start Xcode."
        NSApplication.shared.activate(ignoringOtherApps: true)
        _ = alert.runModal()
    }
}
