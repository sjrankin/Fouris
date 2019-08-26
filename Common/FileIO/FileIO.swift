//
//  FileIO.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 5/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Simple encapsulations of some FileManager function calls to save and read files from the directory where app files are stored.
class FileIO
{
    /// Sub-directory for storage.
    private static var AppDocDirectory = "Fouris"
    
    /// Returns the contents of a file (in string format) that resides in the bundle's resource directory.
    ///
    /// - Note: A fatal error will be generated if either `FileName` or `WithExtension` is empty.
    ///
    /// - Parameters:
    ///   - FileName: Name of the file.
    ///   - WithExtension: Extension of the file.
    /// - Returns: Contents of the file on success, nil on error.
    public static func GetFileContentsFromResource(_ FileName: String, _ WithExtension: String) -> String?
    {
        if FileName.isEmpty || WithExtension.isEmpty
        {
            fatalError("Either FileName or WithExtension is empty.")
        }
        let FileURL = Bundle.main.url(forResource: FileName, withExtension: WithExtension)
        do
        {
            return try String(contentsOfFile: FileURL!.path)
        }
        catch
        {
            print("Error \(error.localizedDescription) from reading \((FileURL?.path)!).")
            return nil
        }
    }
    
    /// Write the contents of the string to a file in the app's resource directory.
    ///
    /// - Note: A fatal error will be generated if either `FileName` or `WithExtension` is empty.
    ///
    /// - Parameters:
    ///   - WithContents: The string to write.
    ///   - FileName: The name of the file.
    ///   - WithExtension: The extension of the file.
    /// - Returns: True on success, false on failure. False is also returned if `WithContents` is empty.
    public static func SaveFileContentsToResource(WithContents: String, _ FileName: String, _ WithExtension: String) -> Bool
    {
        if FileName.isEmpty || WithExtension.isEmpty
        {
            fatalError("Either FileName or WithExtension is empty.")
        }
        if WithContents.isEmpty
        {
            return false
        }
        let FileURL = Bundle.main.url(forResource: FileName, withExtension: WithExtension)
        do
        {
            try WithContents.write(to: FileURL!, atomically: true, encoding: String.Encoding.utf8)
            return true
        }
        catch
        {
            print("Error \(error.localizedDescription) from writing to \((FileURL?.path)!)")
            return false
        }
    }
    
    /// Returns the URL of the user's document directory.
    ///
    /// - Returns: URL of the user's document directory.
    public static func DocumentDirectory() -> URL
    {
        let Paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return Paths[0]
    }
    
    /// Returns the URL of the directory used to store app-related files.
    ///
    /// - Returns: URL of the directory used to store app-related files.
    public static func AppDirectory() -> URL
    {
        return DocumentDirectory().appendingPathComponent(AppDocDirectory)
    }
    
    /// Return the directory where we can read and write data. This is assumed to be a sub-directory off of the user's
    /// Documents directory.
    ///
    /// - Note: If nil is returned, there is something very wrong going on and the caller should most likely report an error
    ///         to the user and stop execution.
    ///
    /// - Parameter CreateIfDoesntExist: If true, the directory will be created if it doesn't exist.
    /// - Returns: The name and URL of the requested directory if it exists, nil if it does not.
    public static func GetStorageDirectory(CreateIfDoesntExist: Bool = true) -> (String, URL)?
    {
        if let SubDirectories = GetDocumentSubDirectories()
        {
            for (DirName, DirURL) in SubDirectories
            {
                if DirName == AppDocDirectory
                {
                    return (DirName, DirURL)
                }
            }
        }
        else
        {
            return nil
        }
        //If we're here, the app directory doesn't exist. If necessary, create it.
        if CreateIfDoesntExist
        {
            do
            {
                let NewDir = DocumentDirectory().appendingPathComponent(AppDocDirectory, isDirectory: true)
                try FileManager.default.createDirectory(at: NewDir, withIntermediateDirectories: true, attributes: nil)
                return (AppDocDirectory, NewDir)
            }
            catch
            {
                print("Error creating \(AppDocDirectory): \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    /// Returns the list of sub-directories in the user's Documents directory.
    ///
    /// - Returns: List of sub-directory names and URLs off of the Documents directory.
    public static func GetDocumentSubDirectories() -> [(String, URL)]?
    {
        var StorageDirectories = [(String, URL)]()
        do
        {
            let ResourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
            let Enumerator = FileManager.default.enumerator(at: DocumentDirectory(),
                                                            includingPropertiesForKeys: ResourceKeys,
                                                            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
                                                            errorHandler:
                {
                    (url, error) -> Bool in
                    print("Directory enumerator error at \(URL.self): ", error)
                    return true
            })!
            for case let FileURL as URL in Enumerator
            {
                let ResourceValues = try FileURL.resourceValues(forKeys: Set(ResourceKeys))
                //print(FileURL.path, ResourceValues.creationDate!, ResourceValues.isDirectory!)
                if ResourceValues.isDirectory!
                {
                    StorageDirectories.append((FileURL.path, FileURL))
                }
            }
        }
        catch
        {
            print(error)
        }
        return StorageDirectories
    }
    
    /// Returns the contents of the specified file name in the specified directory, as a string.
    /// - Parameters:
    ///   - InDirectory: URL of the directory where the file exists.
    ///   - FromFile: Name of the file to read.
    ///   - DumpErrorMessage: If true, error messages are dumped to the debug console. If false,
    ///                       error messages are not displayed.
    /// - Returns: String contents of the file. On failure, nil returned.
    public static func GetFileContents(InDirectory: URL, FromFile: String,
                                       DumpErrorMessage: Bool = false) -> String?
    {
        let FinalPath = InDirectory.appendingPathComponent(FromFile)
        do
        {
            return try String(contentsOfFile: FinalPath.path)
        }
        catch
        {
            if DumpErrorMessage
            {
            print("Error reading \(FinalPath.path): \(error.localizedDescription)")
            }
            return nil
        }
    }
    
    /// Write a string to a file. The file's old contents are overwritten by the string passed here.
    ///
    /// - Parameters:
    ///   - InDirectory: Directory of the file.
    ///   - ToFile: Name of the file.
    ///   - WithContents: String to write to the file.
    /// - Returns: True on success, false on error.
    public static func SetFileContents(InDirectory: URL, ToFile: String, WithContents: String) -> Bool
    {
        let FileToWriteTo = InDirectory.appendingPathComponent(ToFile)
        do
        {
            try WithContents.write(to: FileToWriteTo, atomically: true, encoding: String.Encoding.utf8)
            return true
        }
        catch
        {
            print("Error writing string to file: \(FileToWriteTo): \(error.localizedDescription)")
            return false
        }
    }
    
    /// Delete the specified file in the specified directory.
    ///
    /// - Parameters:
    ///   - InDirectory: The directory in which the file to delete resides.
    ///   - WithName: Name of the file to delete.
    /// - Returns: True on success, false on error or file not removed.
    public static func DeleteFile(InDirectory: URL, WithName: String) -> Bool
    {
        let FileToDelete = InDirectory.appendingPathComponent(WithName)
        do
        {
            try FileManager.default.removeItem(at: FileToDelete)
            return true
        }
        catch
        {
            print("Error deleting file \(FileToDelete): \(error.localizedDescription)")
            return false
        }
    }
}
