//
//  XcodeMenuItem.swift
//  XcodeSwitcherMenuBarExtra
//
//  Created by Hori,Masaki on 2021/05/17.
//


import Cocoa
import Combine

final class XcodeMenuItem: UpdatableStatusItem {
    
    private struct AppleEventError: Error, CustomStringConvertible {
        
        let description: String
    }
    
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
            
            guard needsQuitRunningXcode() else { return }
            
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
                                      messageText: LocalizedStrings.failToRunSwitchDevDirMsg.string,
                                      informativeText: LocalizedStrings.failToRunSwitchDevDirInfo.string(exitCode))
                    ).show()
                    
                    return
                }
            }
        }
        catch {
            
            Announce(configration:
                        .init(style: .critical,
                              messageText: LocalizedStrings.canNotAttachHelperMsg.string,
                              informativeText: LocalizedStrings.canNotAttachHelperInfo.string(error.localizedDescription))
            ).show()
        }
    }
    
    private func needsQuitRunningXcode() -> Bool {
        
        guard let runningXcode = XcodeSearcher.runningXcode().first else {
            
            return false
        }
        
        guard runningXcode != xcode else {
            
            return false
        }
        
        return tellQuitRunningXcode()
    }
    
    private func tellQuitRunningXcode() -> Bool {
        
        Announce(configration:
                    .init(messageText: LocalizedStrings.tellQuitRunninngXcodeMsg.string,
                          buttonAttributes: [
                            .init(title: LocalizedStrings.tellQuitRunninngXcodeOK.string),
                            .init(title: LocalizedStrings.tellQuitRunninngXcodeCancel.string, keyEquivalent: "\u{1b}")
                          ])
        ).show() == .alertFirstButtonReturn
    }
    
    private func quitRunningXcode() {
        
        if XcodeSearcher.runningXcode().isEmpty {
            
            return
        }
        
        do {
            
            let target = NSAppleEventDescriptor(bundleIdentifier: "com.apple.dt.Xcode")
            let appleEvent = NSAppleEventDescriptor.appleEvent(withEventClass: kCoreEventClass,
                                                               eventID: kAEQuitApplication,
                                                               targetDescriptor: target,
                                                               returnID: AEReturnID(kAutoGenerateReturnID),
                                                               transactionID: AETransactionID(kAnyTransactionID))
            let result = try appleEvent.sendEvent(options: [.waitForReply], timeout: 10)
            
            guard let osStatus = result.paramDescriptor(forKeyword: keyErrorNumber)?.int32Value else {
                
                throw AppleEventError(description: LocalizedStrings.canNotGetErrorNumber.string)
            }
            
            guard osStatus == noErr else {
                
                if let errorString = result.paramDescriptor(forKeyword: keyErrorString)?.stringValue {
                    
                    throw AppleEventError(description: LocalizedStrings.xcodeError.string(errorString))
                }
                
                if let errorString = SecCopyErrorMessageString(osStatus, nil) {
                    
                    throw AppleEventError(description: LocalizedStrings.osErrorMessage.string(String(errorString)))
                }
                
                throw AppleEventError(description: LocalizedStrings.osErrorNumber.string(osStatus))
            }
        }
        catch {
            
            Announce(configration:
                        .init(style: .critical,
                              messageText: LocalizedStrings.failToQuitXcodeMsg.string,
                              informativeText: LocalizedStrings.failToRunSwitchDevDirInfo.string(error.localizedDescription)
                )
            ).show()
        }
    }
    
    private func activateXcode(_ xcode: Xcode) {
        
        if NSWorkspace.shared.open(xcode.url) {
            
            return
        }
        
        Announce(configration:
                    .init(messageText: LocalizedStrings.failToStartXcodeMsg.string)
        ).show()
    }
}
