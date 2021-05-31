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
        
        // TODO: Implement
        
        return true
    }
    
    private func quitRunningXcode() {
        
        // TODO: Implement
        
        if XcodeSearcher.runningXcode().isEmpty {
            
            print("there is no running Xcode.")
            return
        }
                
        let target = NSAppleEventDescriptor(bundleIdentifier: "com.apple.dt.Xcode")
        let ae = NSAppleEventDescriptor.appleEvent(withEventClass: kCoreEventClass,
                                                   eventID: kAEQuitApplication,
                                                   targetDescriptor: target,
                                                   returnID: AEReturnID(kAutoGenerateReturnID),
                                                   transactionID: AETransactionID(kAnyTransactionID))
        do {
            let result = try ae.sendEvent(timeout: 1)
            print(result)
        }
        catch {
            
            print("ERROR sendEvent:", error)
        }
    }
    
    private func activateXcode(_ xcode: Xcode) {
        
        // TODO: Implement
    }
}
