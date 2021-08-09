//
//  SKAdNetworkList.swift
//  SKAdEditor
//
//  Created by Александр Худяков on 30.07.2021.
//

import Foundation
import OrderedCollections

struct SKAdNetworkList: SKAdNetworkCollection {
    private var ids: OrderedSet<SKAdNetworkId>
    let startIndex: Int = 0
    var endIndex: Int { ids.isEmpty ? 0 : ids.count }

    init(format: Format, data: Data) throws {
        guard let string = String(data: data, encoding: .utf8) else {
            self.init()
            return
        }
        switch format {
        case .plistXml:
            try self.init(plistString: string)
        case .json:
            self = try JSONDecoder().decode(SKAdNetworkList.self, from: data)
        }
    }

    init(string: String) throws {
        let matches = SKAdNetworkId.regexPattern.matches(in: string,
                                                         options: [],
                                                         range: .init(string.startIndex..., in: string))
        let parsedIds = matches.compactMap { (match: NSTextCheckingResult) -> SKAdNetworkId? in
            guard let range = Range(match.range, in: string) else { return nil }
            let subString = String(string[range])
            return try? SKAdNetworkId(string: subString)
        }
        self.init(parsedIds)
    }

    private init(plistString: String) throws {
        let plistDictionary = try Dictionary<String, Any>.withPlist(string: plistString)
        let array = (plistDictionary[PlistKey.skAdItems.rawValue] as? Array<Dictionary<String, String>>)?
            .compactMap { SKAdNetworkId(rawValue: $0[PlistKey.skAdIdentifier.rawValue] ?? "") }
            ?? []
        self.init(array)
    }

    private init(_ array: [SKAdNetworkId]) {
        let trimmed = Set(array).sorted()
        ids = OrderedSet(trimmed)
    }

    init() {
        ids = OrderedSet()
    }

    subscript(position: Int) -> SKAdNetworkId {
       ids[position]
    }

    func index(after i: Int) -> Int {
        i + 1
    }

    mutating func append(_ list: SKAdNetworkList)  {
        ids.append(contentsOf: list)
        ids.sort()
    }

    mutating func append(_ string: String) throws {
        guard let id = SKAdNetworkId(rawValue: string) else {
            throw ListError.invalidId(value: string)
        }
        guard !ids.contains(id) else {
            throw ListError.duplicateId(value: id.rawValue)
        }

        self.append(id)
    }

    mutating func append(_ id: SKAdNetworkId) {
        ids.append(id)
        ids.sort()
    }

    mutating func remove(at index: Index) {
        ids.remove(at: index)
    }

    mutating func remove(id: SKAdNetworkId) {
        ids.remove(id)
    }

    func export(format: Format) throws -> Data {
        switch format {
        case .json:
            return try exportToJson()
        case .plistXml:
            return try exportToXml()
        }
    }

    private func exportToJson() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }

    private func exportToXml() throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        return try encoder.encode(self)
    }
}

extension SKAdNetworkList {
    enum ListError: Error {
        case invalidId(value: String)
        case duplicateId(value: String)
    }
}

extension SKAdNetworkList: Codable {
    enum CodingKeys: String, CodingKey {
        case items = "SKAdNetworkItems"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let values = try container.decode([SKAdNetworkId].self, forKey: .items)
        self.ids = OrderedSet(values)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ids, forKey: .items)
    }
}
