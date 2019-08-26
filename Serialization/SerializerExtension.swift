//
//  SerializerExtension.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Extensions for Serializer - mainly utility functions for parsing.
extension Serializer
{
    /// Sanitize a string of characters that are valid XML entities.
    ///
    /// - Parameter Raw: The string to sanitize.
    /// - Returns: Sanitized string. All characters defined in `EntityList` are replaced by the corresponding entities.
    func SanitizeString(_ Raw: String) -> String
    {
        var Working = ""
        for Char in Raw
        {
            if let Entity = EntityList[String(Char)]
            {
                Working = Working + Entity
            }
            else
            {
                Working = Working + String(Char)
            }
        }
        return Working
    }
    
    /// Desanitize a string of entities, replacing them with the corresponding characters.
    ///
    /// - Parameter Raw: The raw string to desanitize.
    /// - Returns: String with all XML entities replaced by the corresponding strings.
    func DesanitizeString(_ Raw: String) -> String
    {
        var Working = Raw
        for (Char, Entity) in EntityList
        {
            Working = Working.replacingOccurrences(of: Entity, with: Char)
        }
        return Working
    }
}
