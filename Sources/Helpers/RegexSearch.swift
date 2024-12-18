//
//  RegexSearch.swift
//  
//
//  Created by Sorokin Igor on 24.10.2024.
//

import Foundation

struct RegexSearch {
    let regex: NSRegularExpression
    let group: Int

    init(pattern: String, group: Int) {
        do {
            self.regex = try NSRegularExpression(pattern: pattern)
            self.group = group
        } catch {
            preconditionFailure("Regular expression must be non-null")
        }
    }

    static let interface = RegexSearch(pattern: #"@interface\s(\w+)\s:"#, group: 1)
    static let `protocol` = RegexSearch(pattern: #"@protocol\s(\w+)"#, group: 1)
    static let `enum` = RegexSearch(pattern: #"typedef\sSWIFT_ENUM[(\w]+[,\s]+(\w+)"#, group: 1)
    static let markFunction = RegexSearch(pattern: #"hcodegenFunctionForExtension\d*"#, group: 0)
    static let objectDependency = RegexSearch(pattern: #"\w+(?=\s\*)|\w+(?=<.+>\s\*)"#, group: 0)
    static let protocolDependency = RegexSearch(pattern: #"\s<([\w\s,]+)>"#, group: 1)
    static let enumDependency = RegexSearch(pattern: #"enum\s(\w+)"#, group: 1)
    static let inheritanceDependency = RegexSearch(pattern: #"\s:\s(\w+)"#, group: 1)
    static let action = RegexSearch(pattern: #"(?<=h-codegen:)\S+"#, group: 0)
}

extension String {

    func firstMatch(regex: RegexSearch) -> String? {
        guard let match = regex.regex.firstMatch(in: self, range: NSRange(startIndex..., in: self)) else {
            return nil
        }

        let groupRange = match.range(at: regex.group)

        guard let range = Range(groupRange, in: self) else {
            preconditionFailure("Range must be non-null")
        }

        return String(self[range])
    }

    func matches(regex: RegexSearch) -> [String] {
        let matches = regex.regex.matches(in: self, range: NSRange(startIndex..., in: self))

        let ranges = matches
            .map { $0.range(at: regex.group) }
            .map {
                guard let range = Range($0, in: self) else {
                    preconditionFailure("Range must be non-null")
                }
                return range
            }

        return ranges.map { String(self[$0]) }
    }

}
