//
//  HelperConnector.swift
//  XcodeSwitcherMenuBarExtra
//
//  Created by Hori,Masaki on 2021/05/07.
//

import Foundation
import ServiceManagement

class HelperConnector {
    
    struct Error: Swift.Error, CustomStringConvertible {
        
        let description: String
        
        static let connectionInvalidate = Error(description: "Connection invalidate.")
        static let notHelperProxy = Error(description: "Proxy is not Helper.")
        static let canNotGetHelperInfoPlist = Error(description: "Can not get Helper's Info.plist.")
        static let canNotGetHelperShortVersion = Error(description: "Can not get Helper's short version.")
        static let canNotMakeAuthorizationRef = Error(description: "Can not make AuthorizationRef.")
        static let failSMJobBless = Error(description: "SMJobBless failed.")
        
        static let commandTimeOut = Error(description: "Command is time out.")
        static let canNotGetInstalledHelperVersion = Error(description: "Can not get installed Helper version.")
        
    }
    
    private enum HelperStatus {
        
        case installed
        case diffrentVersionInstalled
        case invalid
    }
    
    private lazy var currentConnectionSemaphore = DispatchSemaphore(value: 1)
    private var currentConnection: NSXPCConnection? {
        
        willSet {
            currentConnectionSemaphore.wait()
        }
        
        didSet {
            currentConnectionSemaphore.signal()
        }
    }
    
    func helper() throws -> HelperProtocol {
        
        try installIfNeeds()
        
        return try helper(from: connection())
    }
    
    private func helper(from connection: NSXPCConnection) throws -> HelperProtocol {
        
        var catchedError: Swift.Error?
        let proxy = connection.remoteObjectProxyWithErrorHandler { error in
            
            catchedError = error
        }
        
        if let error = catchedError {
            
            throw error
        }
        
        guard let helper = proxy as? HelperProtocol else {
            
            throw Error.notHelperProxy
        }
        
        return helper
    }
    
    private func bundledHelperVersion() throws -> String {
        
        let helperURL = Bundle.main
            .bundleURL
            .appendingPathComponent("Contents/Library/LaunchServices/")
            .appendingPathComponent(HelperConstants.machServiceName)
        
        guard let helperBundleInfo = CFBundleCopyInfoDictionaryForURL(helperURL as CFURL) as? [String: Any] else {
            
            throw Error.canNotGetHelperInfoPlist
        }
        
        guard let helperVersion = helperBundleInfo["CFBundleShortVersionString"] as? String else {
            
            throw Error.canNotGetHelperShortVersion
        }
        
        return helperVersion
    }
    
    private func installedHelperVersion() throws -> String {
        
        let semaphore = DispatchSemaphore(value: 0)
        var installedHelperVersion: String?
        DispatchQueue.global().async {
            do {
                try self.helper(from: self.connection()).getVersion { ver in
                    
                    installedHelperVersion = ver
                    semaphore.signal()
                }
            }
            catch {
                
                print(error)
                semaphore.signal()
            }
        }
        
        guard semaphore.wait(wallTimeout: .now() + 0.5) == .success else {
            
            throw Error.commandTimeOut
        }
        
        guard let version = installedHelperVersion else {
            
            throw Error.canNotGetInstalledHelperVersion
        }
        
        return version
    }
    
    private func helperStatus() throws -> HelperStatus {
        
        do {
            
            guard try bundledHelperVersion() == installedHelperVersion() else {
                
                return .diffrentVersionInstalled
            }
            
            return .installed
        }
        catch {
            
            print(error)
            
            return .invalid
        }
    }
    
    private func connection() throws -> NSXPCConnection {
        
        if let con = currentConnection {
            
            return con
        }
        
        let connection = NSXPCConnection(machServiceName: HelperConstants.machServiceName, options: .privileged)
        connection.exportedInterface = NSXPCInterface(with: HelperClient.self)
        connection.exportedObject = self
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.invalidationHandler = {
            
            self.currentConnection?.invalidationHandler = nil
            self.currentConnection = nil
        }
        
        currentConnection = connection
        currentConnection?.resume()
        
        guard let con = currentConnection else {
            
            throw Error.connectionInvalidate
        }

        return con
    }
    
    private func installIfNeeds() throws {
        
        if try helperStatus() == .installed {
            
            return
        }
        
        try install()
    }
    
    private func install() throws {
        
        // TODO: Authorize関連を外に吐き出す
        var authItem = kSMRightBlessPrivilegedHelper.withCString { cStr in
            
            AuthorizationItem(name: cStr, valueLength: 0, value: UnsafeMutableRawPointer(bitPattern: 0), flags: 0)
        }
        var authRights = withUnsafeMutablePointer(to: &authItem) { item in
                        
            AuthorizationRights(count: 1, items: item)
        }
        
        let optionalAuthRef = try HelperAuthorization
                .authorizationRef(&authRights, nil, [.interactionAllowed, .extendRights, .preAuthorize])
        guard let authRef = optionalAuthRef else {
            
            throw Error.canNotMakeAuthorizationRef
        }
        
        var cfError: Unmanaged<CFError>?
        guard SMJobBless(kSMDomainSystemLaunchd,
                         HelperConstants.machServiceName as CFString,
                         authRef,
                         &cfError) else {
            
            if let error = cfError?.takeRetainedValue() {
                
                throw error
            }
            
            throw Error.failSMJobBless
        }
        
        self.currentConnection?.invalidate()
        self.currentConnection = nil
    }
}


extension HelperConnector: HelperClient {
    
    @objc
    func log(stdOut: String) {
        
        if stdOut.isEmpty {
            
            return
        }
        
        print("STDOUT:", stdOut)
    }
    
    @objc
    func log(stdErr: String) {
        
        if stdErr.isEmpty {
            
            return
        }
        
        print("STDERR:", stdErr)
    }
    
}
