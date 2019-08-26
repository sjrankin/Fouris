//
//  TOC.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 5/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Maintains a map between user IDs and user stat files. Also holds a version number
/// (see `TOCVersion`) to help with upgrading user files between versions.
class TOC: Codable
{
    /// Initializer.
    init()
    {
        _TableOfContents = [TOCStruct]()
    }
    
    /// Holds the table of contents version.
    private var _TOCVersion: String = "1.0"
    /// Get the table of contents version.
    public var TOCVersion: String
    {
        get
        {
            return _TOCVersion
        }
    }
    
    /// Structure of one entry in the table of contents.
    struct TOCStruct: Codable
    {
        /// ID of the user.
        let ID: UUID
        /// Name of the file of the user.
        let FileName: String
    }
    
    /// Holds the table of contents.
    private var _TableOfContents = [TOCStruct]()
    /// Get or set the contents.
    public var Contents: [TOCStruct]
    {
        get
        {
            return _TableOfContents
        }
        set
        {
            _TableOfContents = newValue
        }
    }
    
    /// Add a file to the table of contents.
    ///
    /// - Parameters:
    ///   - ID: ID of the user.
    ///   - Name: Name of the file for the user.
    func AddFileToContents(ID: UUID, Name: String)
    {
        _TableOfContents.append(TOCStruct(ID: ID, FileName: Name))
    }
    
    /// Add a file to the table of contents.
    ///
    /// - Note: If `StringID` cannot be parsed into a UUID, a fatal error will result.
    ///
    /// - Parameters:
    ///   - StringID: ID of the user. Must be parsable into a UUID.
    ///   - Name: Name of the file for the user.
    func AddFileToContents(StringID: String, Name: String)
    {
        if let ID = UUID(uuidString: StringID)
        {
            AddFileToContents(ID: ID, Name: Name)
        }
        else
        {
            fatalError("Invalid ID passed to AddFileToContents.")
        }
    }
    
    /// Remove the item with the specified ID from the table of contents. This will not delete any associated files
    /// in the file system - that is the responsibility of the caller (or alternatively, the caller can call
    /// `DeleteFromContents` which also deletes the associated file).
    ///
    /// - Parameter ID: ID of the item to remove.
    func RemoveFromContents(ID: UUID)
    {
        _TableOfContents.removeAll(where: {$0.ID == ID})
    }
    
    /// Deletes the file associated with the passed ID from the file system then removes the ID from the table of contents.
    ///
    /// - Note:
    ///   - If the ID is not in the table of contents, no action is taken.
    ///   - This function will not delete built-in users (`AI` and `Anonymous`).
    ///
    /// - Parameter ID: ID of the associated file to delete.
    func DeleteFromContents(ID: UUID)
    {
        if Settings.IsBuiltInUser(ID: ID)
        {
            return
        }
        if let FileToDelete = FileFrom(ID: ID)
        {
            let OK = FileIO.DeleteFile(InDirectory: FileIO.AppDirectory(), WithName: FileToDelete)
            if !OK
            {
                print("Error deleting \(FileToDelete)")
            }
            RemoveFromContents(ID: ID)
        }
    }
    
    /// Given an ID, return the associated file name.
    ///
    /// - Parameter ID: ID of the file name to return.
    /// - Returns: Name of the file associated with the ID. Nil if no item with the ID was found.
    func FileFrom(ID: UUID) -> String?
    {
        for Item in _TableOfContents
        {
            if Item.ID == ID
            {
                return Item.FileName
            }
        }
        return nil
    }
    
    /// Encode the contents of the table of contents class into a JSON string.
    ///
    /// - Returns: JSON string with the contents of the table of contents.
    public func ToJSON() -> String
    {
        let Encoder = JSONEncoder()
        Encoder.outputFormatting = .prettyPrinted
        let Encoded = try! Encoder.encode(self)
        return String(data: Encoded, encoding: .utf8)!
    }
    
    /// Convert a JSON-formatted string into a new TOC class.
    ///
    /// - Parameter JSON: JSON-formatted string.
    /// - Returns: New TOC class.
    public static func FromJSON(JSON: String) -> TOC
    {
        let Decoder = JSONDecoder()
        let NewTOC = try! Decoder.decode(TOC.self, from: JSON.data(using: .utf8)!)
        return NewTOC
    }
}
