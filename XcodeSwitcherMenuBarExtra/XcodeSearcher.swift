//
//  XcoderSearcher.swift
//  XcodeChangerMenuarExtra
//
//  Created by Hori,Masaki on 2021/04/25.
//

import Cocoa


enum XcodeSearcher {
    
    static func searchInApplications() -> [Xcode] {
        
        let applications = Process() <<< "/bin/ls" <<< ["/Applications/"] >>> { output in
            
            output.lines
        }
        
        return applications
            .map { "/Applications/" + $0 }
            .map(URL.init(fileURLWithPath:))
            .compactMap(Xcode.init(url:))
    }
    
    static func currentXcode() -> Xcode? {
        
        let current = Process() <<< "/usr/bin/xcode-select" <<< ["-p"] >>> { output in
            
            output.string ?? ""
        }
        
        return Xcode(developerDirectory: URL(fileURLWithPath: current))
    }
    
    static func runningXcode() -> [Xcode] {
        
        NSWorkspace
            .shared
            .runningApplications
            .compactMap(\.bundleURL)
            .compactMap(Xcode.init(url:))
    }
}
