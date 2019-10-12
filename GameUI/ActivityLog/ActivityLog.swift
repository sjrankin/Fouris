//
//  ActivityLog.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/12/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Maintains a log of activites in the application.
class ActivityLog
{
    /// Starts the log with the program's version block.
    /// - Parameter AddInitialVersionData: If true, versioning information is added to the log. Defaults to true.
    /// - Parameter DeleteOldLogs: If true, logs over a certain age are deleted. Defaults to true.
    public static func Initialize(AddInitialVersionData: Bool = true, DeleteOldLogs: Bool = true)
    {
        if DeleteOldLogs
        {
            DeleteOldActivityLogs(OlderThan: 30)
        }
        let VersionKVP = Versioning.GetKeyValueData()
        let VersionEntry = LogEntry(Title: "Version", Source: "Activity Log", KVPList: VersionKVP)
        LogItems.append(VersionEntry)
    }
    
    /// Delete old activity logs.
    /// - Parameter OlderThan: Number of days old or older for logs to be deleted.
    public static func DeleteOldActivityLogs(OlderThan: Int)
    {
        let DeletedOK = FileIO.DeleteFiles(InDirectory: FileIO.LogDirectory, OlderThan: OlderThan)
        if !DeletedOK
        {
            print("Error deleting files in \(FileIO.LogDirectory) older than \(OlderThan) days old.")
        }
    }
    
    /// List of log items.
    public static var LogItems = [LogEntry]()
    
    /// Create a file name for the log. The base of each file name is a UUID so there should be little to no overlap.
    /// - Returns: File name.
    public static func MakeFileName() -> String
    {
        var Working = "Log "
        Working.append(UUID().uuidString)
        Working.append(".xml")
        return Working
    }
    
    ///Save the log.
    /// - Parameter WithName: If not nil, the name of the file to use to save the log.
    /// - Returns: The name of the file used to save the log. Reuse this name for subsequent calls to update the log file over the
    ///            course of the game.
    public static func SaveLog(WithName: String? = nil) -> String
    {
        var FileName = WithName == nil ? MakeFileName() : WithName!
        //Make sure someone didn't try to slip us an empty file name.
        if FileName.isEmpty
        {
            FileName = MakeFileName()
        }
        let _ = FileIO.SaveLogFile(Name: FileName, Contents: ToString())
        LastLogName = FileName
        return FileName
    }
    
    /// Holds the last file name used.
    public static var LastLogName: String? = nil
    
    /// Add an entry to the activity log.
    /// - Parameter Title: The title of the entry. Also used for the XML node name.
    /// - Parameter Source: The source of the entry.
    /// - Parameter KVPs: Array of key-value pairs that will be converted to XML attributes for the log node.
    /// - Parameter SaveAfterWrite: If true, the log will be saved after the entry is written. Defaults to false.
    /// - Parameter LogFileName: The name of the file to write the log to. If nil on entry, a new file name will be generated and
    ///                          returned in this parameter.
    public static func AddEntry(Title: String, Source: String, KVPs: [(String, String)], SaveAfterWrite: Bool = false, LogFileName: inout String?)
    {
        let NewEntry = LogEntry(Title: Title, Source: Source, KVPList: KVPs)
        LogItems.append(NewEntry)
        if SaveAfterWrite
        {
            LogFileName = SaveLog(WithName: LogFileName)
        }
    }
    
    /// Add an entry to the activity log.
    /// - Parameter Title: The title of the entry. Also used for the XML node name.
    /// - Parameter SaveAfterWrite: If true, the log will be saved after the entry is written. Defaults to false.
    /// - Parameter LogFileName: The name of the file to write the log to. If nil on entry, a new file name will be generated and
    ///                          returned in this parameter.
    public static func AddEntry(Title: String, SaveAfterWrite: Bool = false, LogFileName: inout String?)
    {
        let NewEntry = LogEntry(Title: Title)
        LogItems.append(NewEntry)
        if SaveAfterWrite
        {
            LogFileName = SaveLog(WithName: LogFileName)
        }
    }
    
    /// Add an entry to the activity log.
    /// - Parameter Title: The title of the entry. Also used for the XML node name.
    /// - Parameter Source: The source of the entry.
    /// - Parameter SaveAfterWrite: If true, the log will be saved after the entry is written. Defaults to false.
    /// - Parameter LogFileName: The name of the file to write the log to. If nil on entry, a new file name will be generated and
    ///                          returned in this parameter.
    public static func AddEntry(Title: String, Source: String, SaveAfterWrite: Bool = false, LogFileName: inout String?)
    {
        let NewEntry = LogEntry(Title: Title, Source: Source)
        LogItems.append(NewEntry)
        if SaveAfterWrite
        {
            LogFileName = SaveLog(WithName: LogFileName)
        }
    }
    
    /// Returns a string with the passed number of spaces in it.
    /// - Parameter Count: Number of spaces to include in the string.
    /// - Returns: String with the specified number of spaces in it.
    private static func Spaces(_ Count: Int) -> String
    {
        var SpaceString = ""
        for _ in 0 ..< Count
        {
            SpaceString = SpaceString + " "
        }
        return SpaceString
    }
    
    /// Returns the passed string surrounded by quotation marks.
    /// - Parameter Raw: The string to return surrounded by quotation marks.
    /// - Returns: `Raw` surrounded by quotation marks.
    private static func Quoted(_ Raw: String) -> String
    {
        return "\"\(Raw)\""
    }
    
    /// Returns the contents of the log as an XML document.
    /// - Parameter AppendTerminalReturn: Determines if a return is appended to the end of the string.
    /// - Returns: XML document consisting of the contents of the log file.
    public static func ToString(AppendTerminalReturn: Bool = true) -> String
    {
        var Working = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        for Item in LogItems
        {
            Working.append(Item.ToString(Indent: 4, AddTerminalReturn: true))
        }
        if AppendTerminalReturn
        {
            Working.append("\n")
        }
        return Working
    }
}
