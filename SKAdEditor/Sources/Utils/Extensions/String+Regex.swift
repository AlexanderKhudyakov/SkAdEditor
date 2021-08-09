//
//  String+Regex.swift
//  SKAdEditor
//
//  Created by Александр Худяков on 30.07.2021.
//

import Foundation

public extension String {
    func satisfiesRegexPattern(_ pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive]
        ) else {
            return true
        }

        let matches = regex.matches(
            in: self,
            options: [],
            range: NSRange(self.startIndex..., in: self)
        )

        guard let match = matches.first,
              match.range.location == 0,
              match.range.length == self.count else {
            return false
        }

        return true
    }
}
