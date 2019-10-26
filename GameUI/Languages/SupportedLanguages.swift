//
//  SupportedLanguages.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/24/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that helps with languages.
class Languages
{
    /// Returns the language code for the passed language.
    /// - Parameter For: The language whose language code (ISO-639) will be returned.
    /// - Returns: Language code (in string format) on success, nil if not found.
    public static func GetLanguageCode(For: SupportedLanguages) -> String?
    {
        if let Code = LanguageCodes[For]
        {
            return Code
        }
        return nil
    }
    
    /// Languages to language code map. Supported languages only.
    public static let LanguageCodes: [SupportedLanguages: String] =
        [
            .EnglishUS: "en-US",
            .Japanese: "ja-JP"
    ]
}

/// Supported languages. Codes are based on ISO-639.
/// - Note: [iOS Supported Language Codes (ISO-639)](https://www.ibabbleon.com/iOS-Language-Codes-ISO-639.html)
enum SupportedLanguages: String, CaseIterable
{
    case EnglishUS = "US English"
    case Japanese = "日本語"
}
