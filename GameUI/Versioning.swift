//
//  Versioning.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 4/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains versioning and copyright information. The contents of this file are automatically updated with each
/// build by the VersionUpdater utility.
public class Versioning
{
    /// Major version number.
    public static let MajorVersion: String = "1"
    
    /// Minor version number.
    public static let MinorVersion: String = "0"
    
    /// Potential version suffix.
    public static let VersionSuffix: String = ""
    
    /// Name of the application.
    public static let ApplicationName = "Fouris"
    
    /// ID of the application.
    public static let ProgramID = "9c49a210-40f0-4f8a-89cf-4f88bc2430c6"
    
    /// The intended OS for the program.
    public static let IntendedOS = "iOS"
    
    /// Returns a standard-formatted version string in the form of "Major.Minor" with optional
    /// version suffix.
    ///
    /// - Parameter IncludeVersionSuffix: If true and the VersionSuffix value is non-empty, the contents
    ///                                   of VersionSuffix will be appended (with a leading space) to the
    ///                                   returned string.
    /// - Parameter IncludeVersionPrefix: If true, the word "Version" is prepended to the returned string.
    /// - Returns: Standard version string.
    public static func MakeVersionString(IncludeVersionSuffix: Bool = false,
                                         IncludeVersionPrefix: Bool = true) -> String
    {
        let VersionLabel = IncludeVersionPrefix ? "Version " : ""
        var Final = "\(VersionLabel)\(MajorVersion).\(MinorVersion)"
        if IncludeVersionSuffix
        {
            if !VersionSuffix.isEmpty
            {
                Final = Final + " " + VersionSuffix
            }
        }
        return Final
    }
    
    /// Publishes the version string to the debug console.
    /// - Parameter LinePrefix: The prefix for each line of the version block. Defaults to empty string.
    public static func PublishVersion(_ LinePrefix: String = "")
    {
        print(MakeVersionBlock(LinePrefix))
    }
    
    /// Build number.
    public static let Build: Int = 1561
    
    /// Build increment.
    private static let BuildIncrement = 1
    
    /// Build ID.
    public static let BuildID: String = "D3F7F89C-3316-4F02-B858-3605709C73E5"
    
    /// Build date.
    public static let BuildDate: String = "24 September 2019"
    
    /// Build Time.
    public static let BuildTime: String = "16:27"
    
    /// Return a standard build string.
    ///
    /// - Parameter IncludeBuildPrefix: If true, the word "Build" is prepended to the returned string.
    /// - Returns: Standard build string
    public static func MakeBuildString(IncludeBuildPrefix: Bool = true) -> String
    {
        let BuildLabel = IncludeBuildPrefix ? "Build " : ""
        let Final = "\(BuildLabel)\(Build), \(BuildDate) \(BuildTime)"
        return Final
    }
    
    /// Copyright years.
    public static let CopyrightYears = [2018, 2019]
    
    /// Legal holder of the copyright.
    public static let CopyrightHolder = "Stuart Rankin"
    
    /// Returns copyright text.
    ///
    /// - Returns: Program copyright text.
    public static func CopyrightText(ExcludeCopyrightString: Bool = false) -> String
    {
        var Years = Versioning.CopyrightYears
        var CopyrightYears = ""
        if Years.count > 1
        {
            Years = Years.sorted()
            let FirstYear = Years.first
            let LastYear = Years.last
            CopyrightYears = "\(FirstYear!) - \(LastYear!)"
        }
        else
        {
            CopyrightYears = String(describing: Years[0])
        }
        var CopyrightTextString = ""
        if ExcludeCopyrightString
        {
            CopyrightTextString = "\(CopyrightYears) \(CopyrightHolder)"
        }
        else
        {
            CopyrightTextString = "Copyright © \(CopyrightYears) \(CopyrightHolder)"
        }
        return CopyrightTextString
    }
    
    /// Return the program ID as a UUID.
    public static func ProgramIDAsUUID() -> UUID
    {
        return UUID(uuidString: ProgramID)!
    }
    
    /// Returns a list of parts that make up a version block.
    /// - Returns: List of tuples that make up a version block. The first item in the tuple is the header (if
    ///            desired) and the second item is the actual data for the version block.
    public static func MakeVersionParts() -> [(String, String)]
    {
        var Parts = [(String, String)]()
        Parts.append(("Name", ApplicationName))
        Parts.append(("Version", MakeVersionString(IncludeVersionSuffix: true, IncludeVersionPrefix: true)))
        Parts.append(("Build", MakeBuildString()))
        Parts.append(("Build ID", BuildID))
        Parts.append(("Copyright", CopyrightText()))
        Parts.append(("Program ID", ProgramID))
        return Parts
    }
    
    /// Returns a block of text with most of the versioning information.
    /// - Parameter WithLinePrefix: The string to prefix each line with. Defaults to "". Available mainly for
    ///                             when dumping the version block to the debug console. This function will add
    ///                             a whitespace character between any non-empty value and the version block text
    ///                             on each line.
    /// - Returns: Most versioning information, each piece of information on a separate line.
    public static func MakeVersionBlock(_ WithLinePrefix: String = "") -> String
    {
        let Prefix = WithLinePrefix.isEmpty ? "" : WithLinePrefix + " "
        var Block = Prefix + ApplicationName + "\n"
        Block = Block + Prefix + MakeVersionString(IncludeVersionSuffix: true, IncludeVersionPrefix: true) + "\n"
        Block = Block + Prefix + MakeBuildString() + "\n"
        Block = Block + Prefix + "Build ID " + BuildID + "\n"
        Block = Block + Prefix + CopyrightText() + "\n"
        Block = Block + Prefix + "Program ID " + ProgramID
        return Block
    }
    
    /// Returns the version block as an attributed string with colors and formats as sepcified in the parameters.
    /// - Parameter TextColor: Color of the normal (eg, payload) text.
    /// - Parameter HeaderColor: Header color for those lines with headers.
    /// - Parameter FontName: Name of the font.
    /// - Parameter FontSize: Size of the font.
    /// - Returns: Attributed string with the version block.
    public static func MakeAttributedVersionBlockEx(TextColor: UIColor = UIColor.blue, HeaderColor: UIColor = UIColor.black,
                                                    FontName: String = "Avenir", HeaderFontName: String = "Avenir-Heavy",
                                                    FontSize: Double = 24.0) -> NSAttributedString
    {
        let Parts = MakeVersionParts()
        let HeaderFont = UIFont(name: HeaderFontName, size: CGFloat(FontSize))
        let StandardFont = UIFont(name: FontName, size: CGFloat(FontSize))
        
        let HeaderAttributes: [NSAttributedString.Key: Any] =
            [
                .font: HeaderFont as Any,
                .foregroundColor: HeaderColor as Any
        ]
        let Line1Attributes: [NSAttributedString.Key: Any] =
            [
                .font: UIFont(name: HeaderFontName, size: CGFloat(FontSize + 4)) as Any,
                .foregroundColor: TextColor as Any
        ]
        let StandardLineAttributes: [NSAttributedString.Key: Any] =
            [
                .font: StandardFont as Any,
                .foregroundColor: TextColor as Any
        ]
        
        let Line1 = NSMutableAttributedString(string: Parts[0].1 + "\n", attributes: Line1Attributes)
        let Line2H = NSMutableAttributedString(string: "Version ", attributes: HeaderAttributes)
        let Line2T = NSMutableAttributedString(string: MakeVersionString(IncludeVersionSuffix: true, IncludeVersionPrefix: false) + "\n", attributes: StandardLineAttributes)
        let Line3H = NSMutableAttributedString(string: "Build ", attributes: HeaderAttributes)
        let Line3T = NSMutableAttributedString(string: MakeBuildString(IncludeBuildPrefix: false) + "\n", attributes: StandardLineAttributes)
        let Line4H = NSMutableAttributedString(string: Parts[3].0 + " ", attributes: HeaderAttributes)
        let Line4T = NSMutableAttributedString(string: Parts[3].1 + "\n", attributes: StandardLineAttributes)
        let Line5H = NSMutableAttributedString(string: "Copyright © ", attributes: HeaderAttributes)
        let Line5T = NSMutableAttributedString(string: CopyrightText(ExcludeCopyrightString: true) + "\n", attributes: StandardLineAttributes)
        let Line6H = NSMutableAttributedString(string: Parts[5].0 + " ", attributes: HeaderAttributes)
        let Line6T = NSMutableAttributedString(string: Parts[5].1, attributes: StandardLineAttributes)
        let Working = NSMutableAttributedString()
        Working.append(Line1)
        Working.append(Line2H)
        Working.append(Line2T)
        Working.append(Line3H)
        Working.append(Line3T)
        Working.append(Line4H)
        Working.append(Line4T)
        Working.append(Line5H)
        Working.append(Line5T)
        Working.append(Line6H)
        Working.append(Line6T)
        return Working
    }
    
    /// Returns the version block as an attributed string with colors and formats as sepcified in the parameters.
    /// - Parameter TextColor: Color of the normal (eg, payload) text.
    /// - Parameter HeaderColor: Header color for those lines with headers.
    /// - Parameter FontName: Name of the font.
    /// - Parameter FontSize: Size of the font.
    /// - Returns: Attributed string with the version block.
    public static func MakeAttributedVersionBlock(TextColor: UIColor = UIColor.blue, HeaderColor: UIColor = UIColor.black,
                                                  FontName: String = "Avenir", HeaderFontName: String = "Avenir-Heavy",
                                                  FontSize: Double = 24.0) -> NSAttributedString
    {
        let Parts = MakeVersionParts()
        let HeaderFont = UIFont(name: HeaderFontName, size: CGFloat(FontSize))
        let StandardFont = UIFont(name: FontName, size: CGFloat(FontSize))
        
        let HeaderAttributes: [NSAttributedString.Key: Any] =
            [
                .font: HeaderFont as Any,
                .foregroundColor: HeaderColor as Any
        ]
        let Line1Attributes: [NSAttributedString.Key: Any] =
            [
                .font: UIFont(name: HeaderFontName, size: CGFloat(FontSize + 4)) as Any,
                .foregroundColor: TextColor as Any
        ]
        let StandardLineAttributes: [NSAttributedString.Key: Any] =
            [
                .font: StandardFont as Any,
                .foregroundColor: TextColor as Any
        ]
        
        let Line1 = NSMutableAttributedString(string: Parts[0].1 + "\n", attributes: Line1Attributes)
        let Line2 = NSMutableAttributedString(string: Parts[1].1 + "\n", attributes: StandardLineAttributes)
        let Line3 = NSMutableAttributedString(string: Parts[2].1 + "\n", attributes: StandardLineAttributes)
        let Line4H = NSMutableAttributedString(string: Parts[3].0 + " ", attributes: HeaderAttributes)
        let Line4T = NSMutableAttributedString(string: Parts[3].1 + "\n", attributes: StandardLineAttributes)
        let Line5 = NSMutableAttributedString(string: Parts[4].1 + "\n", attributes: StandardLineAttributes)
        let Line6H = NSMutableAttributedString(string: Parts[5].0 + " ", attributes: HeaderAttributes)
        let Line6T = NSMutableAttributedString(string: Parts[5].1, attributes: StandardLineAttributes)
        let Working = NSMutableAttributedString()
        Working.append(Line1)
        Working.append(Line2)
        Working.append(Line3)
        Working.append(Line4H)
        Working.append(Line4T)
        Working.append(Line5)
        Working.append(Line6H)
        Working.append(Line6T)
        return Working
    }
    
    /// Return an XML-formatted key-value pair string.
    ///
    /// - Parameters:
    ///   - Key: The key part of the key-value pair.
    ///   - Value: The value part of the key-value pair.
    /// - Returns: XML-formatted key-value pair string.
    private static func MakeKVP(_ Key: String, _ Value: String) -> String
    {
        let KVP = "\(Key)=\"\(Value)\""
        return KVP
    }
    
    /// Emit version information as an XML string.
    ///
    /// - Parameter LeadingSpaceCount: The number of leading spaces to insert before
    ///                                each line of the returned result. If not specified,
    ///                                no extra leading spaces are used.
    /// - Returns: XML string with version information.
    public static func EmitXML(_ LeadingSpaceCount: Int = 0) -> String
    {
        let Spaces = String(repeating: " ", count: LeadingSpaceCount)
        var Emit = Spaces + "<Version "
        Emit = Emit + MakeKVP("Application", ApplicationName) + " "
        Emit = Emit + MakeKVP("Version", MajorVersion + "." + MinorVersion) + " "
        Emit = Emit + MakeKVP("Build", String(describing: Build)) + " "
        Emit = Emit + MakeKVP("BuildDate", BuildDate + ", " + BuildTime) + " "
        Emit = Emit + MakeKVP("BuildID", BuildID)
        Emit = Emit + ">\n"
        Emit = Emit + Spaces + "  " + CopyrightText() + "\n"
        Emit = Emit + Spaces + "</Version>"
        return Emit
    }
}
