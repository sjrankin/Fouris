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
    
    /// Sub-directory for game background images selected by the user.
        public static let SampleDirectory = "/Images"
    
    /// Returns an URL for the document directory.
    ///
    /// - Returns: Document directory URL on success, nil on error.
    public static func GetDocumentDirectory() -> URL?
    {
        let Dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return Dir
    }
    
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
    
    /// Determines if the passed directory exists. The document directory is used as the root directory (eg,
    /// the directory name is appended to the document directory).
    ///
    /// - Parameter DirectoryName: The directory to check for existence. The name of the directory is searched
    ///                            from the document directory.
    /// - Returns: True if the directory exists, false if not.
    public static func DirectoryExists(DirectoryName: String) -> Bool
    {
        let CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
        if CPath == nil
        {
            return false
        }
        return FileManager.default.fileExists(atPath: CPath!.path)
    }
    
    /// Create a directory in the document directory.
    ///
    /// - Parameter DirectoryName: Name of the directory to create.
    /// - Returns: URL of the newly created directory on success, nil on error.
    @discardableResult public static func CreateDirectory(DirectoryName: String) -> URL?
    {
        var CPath: URL!
        do
        {
            CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
            try FileManager.default.createDirectory(atPath: CPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            print("Error creating directory \(CPath.path): \(error.localizedDescription)")
            return nil
        }
        return CPath
    }
    
    /// Save an image to the specified directory.
    ///
    /// - Parameters:
    ///   - Image: The UIImage to save.
    ///   - WithName: The name to use when saving the image.
    ///   - InDirectory: The directory in which to save the image.
    ///   - AsJPG: If true, save as a .JPG image. If false, save as a .PNG image.
    /// - Returns: True on success, nil on failure.
    public static func SaveImage(_ Image: UIImage, WithName: String, InDirectory: URL, AsJPG: Bool = true) -> Bool
    {
        if AsJPG
        {
            if let Data = Image.jpegData(compressionQuality: 1.0)
            {
                let FileName = InDirectory.appendingPathComponent(WithName)
                do
                {
                    try Data.write(to: FileName)
                }
                catch
                {
                    print("Error writing \(FileName.path): \(error.localizedDescription)")
                    return false
                }
            }
        }
        else
        {
            if let Data = Image.pngData()
            {
                let FileName = InDirectory.appendingPathComponent(WithName)
                do
                {
                    try Data.write(to: FileName)
                }
                catch
                {
                    print("Error writing \(FileName.path): \(error.localizedDescription)")
                    return false
                }
            }
        }
        return true
    }
    
    /// Returns the URL of the passed directory. The directory is assumed to be a sub-directory of the
    /// document directory.
    ///
    /// - Parameter DirectoryName: Name of the directory whose URL is returned.
    /// - Returns: URL of the directory on success, nil if not found.
    public static func GetDirectoryURL(DirectoryName: String) -> URL?
    {
        if !DirectoryExists(DirectoryName: DirectoryName)
        {
            return nil
        }
        let CPath = GetDocumentDirectory()?.appendingPathComponent(DirectoryName)
        return CPath
    }
    
    /// Save an image to the specified directory.
    ///
    /// - Parameters:
    ///   - Image: The UIImage to save.
    ///   - WithName: The name to use when saving the image.
    ///   - Directory: Name of the directory where to save the image.
    ///   - AsJPG: If true, save as a .JPG image. If false, save as a .PNG image.
    /// - Returns: True on success, nil on failure.
    public static func SaveImage(_ Image: UIImage, WithName: String, Directory: String, AsJPG: Bool = true) -> Bool
    {
        if !DirectoryExists(DirectoryName: Directory)
        {
            CreateDirectory(DirectoryName: Directory)
        }
        let FinalDirectory = GetDirectoryURL(DirectoryName: Directory)
        return SaveImage(Image, WithName: WithName, InDirectory: FinalDirectory!, AsJPG: AsJPG)
    }
    
    /// Save an image the user has selected as a sample image for filter settings.
    ///
    /// - Parameter SampleImage: The sample image in UIImage format.
    /// - Returns: True on success, false on failure.
    public static func SaveImage(_ SampleImage: UIImage) -> Bool
    {
        return SaveImage(SampleImage, WithName: "UserSelected.jpg", Directory: SampleDirectory, AsJPG: true)
    }
    
    /// Return an image from the passed URL.
    ///
    /// - Parameter From: URL of the image (including all directory parts).
    /// - Returns: UIImage form of the image at the passed URL. Nil on error or file not found.
    public static func LoadImage(_ From: URL) -> UIImage?
    {
        do
        {
            let ImageData = try Data(contentsOf: From)
            let Final = UIImage(data: ImageData)
            return Final
        }
        catch
        {
            print("Error loading image at \(From.path): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Return a list of all files (in URL form) in the passed directory.
    ///
    /// - Parameters:
    ///   - Directory: URL of the directory whose contents will be returned.
    ///   - FilterBy: How to filter the results. This is assumed to be a list of file extensions.
    /// - Returns: List of files in the specified directory.
    public static func GetFilesIn(Directory: URL, FilterBy: String? = nil) -> [URL]?
    {
        var URLs: [URL]!
        do
        {
            URLs = try FileManager.default.contentsOfDirectory(at: Directory, includingPropertiesForKeys: nil)
        }
        catch
        {
            return nil
        }
        if FilterBy != nil
        {
            let Scratch = URLs.filter{$0.pathExtension == FilterBy!}
            URLs.removeAll()
            for SomeURL in Scratch
            {
                URLs.append(SomeURL)
            }
        }
        return URLs
    }
    
    /// Return the user-selected sample image previously stored in the sample image directory.
    ///
    /// - Returns: The sample image as a UIImage on success, nil if not found or on failure.
    public static func GetSampleImage() -> UIImage?
    {
        if !DirectoryExists(DirectoryName: SampleDirectory)
        {
            CreateDirectory(DirectoryName: SampleDirectory)
        }
        if let SampleURL = GetDirectoryURL(DirectoryName: SampleDirectory)
        {
            if let Images = GetFilesIn(Directory: SampleURL)
            {
                if Images.count < 1
                {
                    print("No files returned from " + SampleDirectory)
                    return nil
                }
                return LoadImage(Images[0])
            }
            else
            {
                print("No images found in " + SampleDirectory)
                return nil
            }
        }
        else
        {
            print("Error getting URL for " + SampleDirectory)
            return nil
        }
    }
    
    /// Return the name of the user-selected sample image previously stored in the sample image directory.
    ///
    /// - Returns: The name of the sample image on success, nil on failure.
    public static func GetSampleImageName() -> String?
    {
        if !DirectoryExists(DirectoryName: SampleDirectory)
        {
            return nil
        }
        if let SampleURL = GetDirectoryURL(DirectoryName: SampleDirectory)
        {
            if let Images = GetFilesIn(Directory: SampleURL)
            {
                if Images.count < 1
                {
                    print("No files returned.")
                    return nil
                }
                return Images[0].path
            }
            else
            {
                print("No files found in " + SampleDirectory)
                return nil
            }
        }
        else
        {
            print("Error getting URL for " + SampleDirectory)
            return nil
        }
    }
}
