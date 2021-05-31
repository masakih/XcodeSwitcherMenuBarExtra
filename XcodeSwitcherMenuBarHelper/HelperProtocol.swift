//
//  HelperProtocol.swift
//  SwiftPrivilegedHelper
//
//  Created by Erik Berglund on 2018-10-01.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation

@objc(HelperProtocol)
protocol HelperProtocol {
    func getVersion(completion: @escaping (String) -> Void)
    func switchDeveloperDirectory(url: URL, completion: @escaping (NSNumber) -> Void)
    func switchDeveloperDirectory(url: URL, authData: NSData?, completion: @escaping (NSNumber) -> Void)
    func switchDeveloperDirectory(withPath: String, authData: NSData?, completion: @escaping (NSNumber) -> Void)
    func switchDeveloperDirectory(withPath: String, completion: @escaping (NSNumber) -> Void)
}
