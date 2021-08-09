//
//  SKAdNetworkId.swift
//  SKAdEditor
//
//  Created by Александр Худяков on 30.07.2021.
//

import Foundation

struct SKAdNetworkId: RawRepresentable {
    private static let idPattern = "[0-9a-z]{10}"
    private static let suffix = ".skadnetwork"

    static var regexPattern: NSRegularExpression = {
        return try! NSRegularExpression(pattern: idPattern + suffix, options: [.caseInsensitive])
    }()

    let rawValue: String

    var fullForm: String { rawValue + SKAdNetworkId.suffix }

    init?(rawValue id: String) {
        guard let networkId = try? SKAdNetworkId(string: id) else { return nil }
        self = networkId
    }

    init(string: String) throws {
        guard !string.isEmpty else { throw ParsingError.emptyString }
        let suffix = SKAdNetworkId.suffix
        let trimmed = string.hasSuffix(suffix) ? string.replacingOccurrences(of: suffix, with: "") : string
        let lowercased = trimmed.lowercased()
        guard lowercased.satisfiesRegexPattern(SKAdNetworkId.idPattern) else { throw ParsingError.invalidFormat(string: string) }
        self.rawValue = lowercased
    }
}

extension SKAdNetworkId {
    enum ParsingError: Error {
        case emptyString
        case invalidFormat(string: String)
    }
}

extension SKAdNetworkId: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "SKAdNetworkIdentifier"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(String.self, forKey: .id)
        self = SKAdNetworkId(rawValue: value)!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fullForm, forKey: .id)
    }
}

extension SKAdNetworkId: CustomStringConvertible {
    var description: String { rawValue }
}

extension SKAdNetworkId: Comparable {
    static func < (lhs: SKAdNetworkId, rhs: SKAdNetworkId) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension SKAdNetworkId: Equatable { }

extension SKAdNetworkId: Hashable { }

