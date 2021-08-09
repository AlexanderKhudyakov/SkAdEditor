//
//  SKAdNetworkCollection.swift
//  SKAdEditor
//
//  Created by Александр Худяков on 30.07.2021.
//

import Foundation

enum Format {
    case json
    case plistXml
}

protocol SKAdNetworkCollection: Collection where Index == Int {
    init(format: Format, data: Data) throws
    func export(format: Format) throws -> Data
}
