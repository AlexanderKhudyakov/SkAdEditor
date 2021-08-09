//
//  PlistKey.swift
//  SKAdEditor
//
//  Created by Александр Худяков on 05.08.2021.
//

import Foundation

enum PlistKey: String {
    case skAdItems = "SKAdNetworkItems"
    case skAdIdentifier = "SKAdNetworkIdentifier"
}

extension Dictionary where Key == String, Value == Any {
    subscript(_ key: PlistKey) -> Any? {
        get {
            self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue
        }
    }
}
