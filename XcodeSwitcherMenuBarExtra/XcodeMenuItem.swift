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
                    
                    Announce(configration:
                                .init(style: .critical,
                                      messageText: "Can not set new Deleloper Directory",
                                      informativeText: "Xcode-select's exit code: \(exitCode)")
                    ).show()
                    
                    return
                }
            }
        }
        catch {
            
            Announce(configration:
                        .init(style: .critical,
                              messageText: "Can not set new Deleloper Directory",
                              informativeText: "Fail to launch xcode-select.\n Error: \(error)")
            ).show()
        }
    }
    
    private func tellQuitRunningXcode() -> Bool {
        
        return Announce(configration:
                    .init(messageText: "Do you want to quit the running xcode?",
                          informativeText: "Do you want to quit the running xcode?",
                          buttonAttributes: [
                            .init(title: "Quit"),
                            .init(title: "Don't Quit", keyEquivalent: "\u{1b}")
                          ])
        ).show() == .OK
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
            
            Announce(configration:
                        .init(style: .critical,
                              messageText: "Fail to quit Xcode.",
                              informativeText: "Fail to quit Xcode. \nReason: \(error)"
                )
            ).show()
        }
    }
    
    private func activateXcode(_ xcode: Xcode) {
        
        if NSWorkspace.shared.open(xcode.url) {
            
            return
        }
        
        Announce(configration:
                    .init(messageText: "Failed to start Xcode",
                          informativeText: "Failed to start Xcode")
        ).show()
    }
}
