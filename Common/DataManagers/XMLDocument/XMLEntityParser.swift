//
//  XMLEntityParser.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class XMLEntityParser
{
    /// Break apart the passed string into XML-type entities.
    /// - Parameter Raw: The raw string to parse.
    /// - Returns: Array of string entities.
    public static func ParseToEntities(Raw: String) -> [String]
    {
        var Results = [String]()
        var SplitMe = Raw.trimmingCharacters(in: CharacterSet.whitespaces)
        SplitMe = SplitMe.replacingOccurrences(of: "\n", with: "")
        SplitMe = SplitMe.replacingOccurrences(of: "\t", with: " ")
        let Parts = SplitMe.split(separator: "<", omittingEmptySubsequences: true)
        for Part in Parts
        {
            let Final = "<" + String(Part)
            Results.append(Final)
        }
        return Results
    }
}
