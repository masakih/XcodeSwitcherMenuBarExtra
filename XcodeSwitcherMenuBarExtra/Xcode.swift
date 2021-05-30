//
//  Xcode.swift
//  XcodeChangerMenuarExtra
//
//  Created by Hori,Masaki on 2021/04/25.
//

import Foundation

struct Xcode:  Equatable {
    
    let displayName: String
    let version: String
    let url: URL
    
    var developerDirectory: URL {
        
        url.appendingPathComponent("Contents/Developer")
    }
}

extension Xcode {
    
    init?(for bundle: Bundle) {
        
        guard bundle.bundleIdentifier == "com.apple.dt.Xcode" else {
            
            return nil
        }
        
        guard let infoDict = bundle.infoDictionary else {
            
            print("info Dictionary is not Found")
            return nil
        }
        
        guard let sVer = infoDict["CFBundleShortVersionString"] as? String else {
            
            print("CFBundleShortVersionString is not found")
            return nil
        }
        
        self.displayName = FileManager.default.displayName(atPath: bundle.bundleURL.path)
        self.version = sVer
        self.url = bundle.bundleURL
    }
    
    init?(url: URL) {
        
        guard let bundle = Bundle(url: url) else {
            
            return nil
        }
        
        self.init(for: bundle)
    }
    
    init?(developerDirectory: URL) {
        
        guard let url = Self.developperDirToXcodeDir(developerDirectory) else {
            
            return nil
        }
        
        self.init(url: url)
    }
    
    
    private static func developperDirToXcodeDir(_ url: URL) -> URL? {
        
        if url.lastPathComponent.hasSuffix(".app") {
            
            return url
        }
        let newURL = url.deletingLastPathComponent()
        guard newURL.path != "/" else {
            
            return nil
        }
        
        return developperDirToXcodeDir(newURL)
    }
}
