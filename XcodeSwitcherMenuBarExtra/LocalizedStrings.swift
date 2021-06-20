//
//  LocalizedStrings.swift
//  StyleRemover
//
//  Created by Hori,Masaki on 2020/01/26.
//  Copyright © 2020 Hori,Masaki. All rights reserved.
//

struct LocalizedStrings {}


// MARK: - MenuItems
extension LocalizedStrings {
    
    static let preference = LocalizedString("Preference...", comment: "MenunItem: Preference")
    
    static let quitFormat = LocalizedString("Quit %@", comment: "MenunItem: Quit")
}

// MARK: - Errors
extension LocalizedStrings {
    
    static let failToRunSwitchDevDirMsg = LocalizedString("Can not set new Deleloper Directory", comment: "CfailToRunSwitchDevDirMsg")
    static let failToRunSwitchDevDirInfo = LocalizedString("Xcode-select's exit code: %d", comment: "failToRunSwitchDevDirInfo")
    
    static let canNotAttachHelperMsg = failToRunSwitchDevDirMsg
    static let canNotAttachHelperInfo = LocalizedString("Fail to launch xcode-select.\n Error: %@", comment: "canNotAttachHelperInfo")
    
    static let tellQuitRunninngXcodeMsg = LocalizedString("Do you want to quit the running Xcode?", comment: "tellQuitRunninngXcodeMsg")
    static let tellQuitRunninngXcodeOK = LocalizedString("Quit", comment: "tellQuitRunninngXcodeOK")
    static let tellQuitRunninngXcodeCancel = LocalizedString("Don't Quit", comment: "tellQuitRunninngXcodeCancel")
    
    static let failToQuitXcodeMsg = LocalizedString("Fail to quit Xcode.", comment: "failToQuitXcodeMsg")
    static let failToQuitXcodeInfo = LocalizedString("Fail to quit Xcode. \nReason: %@", comment: "failToQuitXcodeInfo")
    
    static let failToStartXcodeMsg = LocalizedString("Failed to start Xcode", comment: "failToStartXcodeMsg")
}


// MARK: - AppleEvent Error
extension LocalizedStrings {
    
    static let canNotGetErrorNumber = LocalizedString("Can not get errorNumder.", comment: "canNotGetErrorNumber")
    
    static let xcodeError = LocalizedString("Xcode response error: %@", comment: "xcodeError")
    
    static let osErrorMessage = LocalizedString("OSSutatus ErrorMessage: %@", comment: "osErrorMessage")
    
    static let osErrorNumber = LocalizedString("keyErrorNumber: %d", comment: "osErrorNumber")
}

// MARK: - HelperConnection Error
extension LocalizedStrings {
    
    static let connectionInvalidate = LocalizedString("Connection invalidate.", comment: "connectionInvalidate")
    static let notHelperProxy = LocalizedString("Proxy is not Helper.", comment: "notHelperProxy")
    static let canNotGetHelperInfoPlist = LocalizedString("Can not get Helper's Info.plist.", comment: "canNotGetHelperInfoPlist")
    static let canNotGetHelperShortVersion = LocalizedString("Can not get Helper's short version.", comment: "canNotGetHelperShortVersion")
    static let canNotMakeAuthorizationRef = LocalizedString("Can not make AuthorizationRef.", comment: "canNotMakeAuthorizationRef")
    static let failSMJobBless = LocalizedString("SMJobBless failed.", comment: "failSMJobBless")
    static let commandTimeOut = LocalizedString("Command is time out.", comment: "commandTimeOut")
    static let canNotGetInstalledHelperVersion = LocalizedString("Can not get installed Helper version.", comment: "canNotGetInstalledHelperVersion")
}


// MARK: - Preference
extension LocalizedStrings {
    
    static let choose = LocalizedString("Choose", comment: "Preference: OpenPanel: Choose button")
    static let message = LocalizedString("Chose Target Application", comment: "Preference: OpenPanel: Message")
}
