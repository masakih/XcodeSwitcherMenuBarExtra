//
//  AppDelegate.swift
//  XcodeSwitcherMenuBarExtra
//
//  Created by Hori,Masaki on 2021/04/24.
//

import Cocoa

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    class var appName: String {
        
        guard let dict = Bundle.main.localizedInfoDictionary,
            let name = dict["CFBundleDisplayName"] as? String else {
                
                return "Xcode Switcher"
        }
        return name
    }
    
    var statusBar = StatusBar()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        do {
            
            try HelperAuthorization.authorizationRightsUpdateDatabase()
            
        } catch {
            
            print(error)
        }
        
//        print(
//            "All of within Applications",
//            XcodeSearcher.searchInApplications(),
//            "\n",
//            "All of running.",
//            XcodeSearcher.runningXcode()
//        )
    }
}

