//
//  Dictionary+Plist.swift
//  SKAdEditor
//
//  Created by Александр Худяков on 30.07.2021.
//

import Foundation

extension Dictionary {
    static func withPlist(at url: URL) throws -> Dictionary<String, AnyObject>  {
        let data = try Data(contentsOf: url)
        return try withPlist(data: data)
    }

    static func withPlist(string: String) throws -> Dictionary<String, AnyObject>  {
        let data = string.data(using: .utf8)!
        return try withPlist(data: data)
    }

    static func withPlist(data: Data) throws -> Dictionary<String, AnyObject> {
        let plist = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
        return plist as? [String: AnyObject] ?? [:]
    }
}
