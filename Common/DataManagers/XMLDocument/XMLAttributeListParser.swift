//
//  XMLAttributeListParser.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class XMLAttributeListParser
{
    public static func ParseAttributes(From Raw: String) -> [XMLKVP]
    {
        let Working = Raw.trimmingCharacters(in: CharacterSet.whitespaces)
        let Parts = Working.split(separator: "\"", omittingEmptySubsequences: true)
        if !Parts.count.isMultiple(of: 2)
        {
            fatalError("Unexpected pattern found in raw attributes: \(Working)")
        }
        var WorkingList = [String]()
        var Index = 0
        for _ in 0 ..< Parts.count
        {
            let Attr = String(Parts[Index]) + "\"" + String(Parts[Index + 1]) + "\""
            Index = Index + 2
            WorkingList.append(Attr)
            if Index >= Parts.count - 1
            {
                break
            }
        }
        var Final = [XMLKVP]()
        for SomeAttribute in WorkingList
        {
            let FinalAttributes = XMLKVP(RawValue: SomeAttribute)
            Final.append(FinalAttributes!)
        }
        return Final
    }
}
