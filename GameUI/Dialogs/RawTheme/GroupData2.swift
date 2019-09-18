//
//  GroupData2.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds groups of data for the raw theme viewer.
class GroupData2
{
    /// Initializer.
    /// - Parameter Title: Group title.
    init(_ Title: String)
    {
        HeaderTitle = Title
    }
    
    /// Add a new field to the group.
    /// - Parameter NewField: The field to add.
    public func AddField(_ NewField: GroupField2)
    {
        Fields.append(NewField)
    }
    
    /// Add a new field to the group using passed data.
    /// - Parameter ID: ID of the field.
    /// - Parameter Title: Title of the field.
    /// - Parameter Description: Description of the field setting.
    /// - Parameter ControlTitle: Title for the actual control (not always used).
    /// - Parameter Default: Default value of the field.
    /// - Parameter Starting: Starting value of the field.
    /// - Parameter FieldType: Data type for the field.
    /// - Parameter List: String list.
    /// - Parameter Handler: Change handler.
    public func AddField(ID: UUID, Title: String, Description: String, ControlTitle: String,
                         Default: Any, Starting: Any, FieldType: FieldTypes, List: [String]? = nil,
                         Handler: ((Any) -> ())? = nil)
    {
        let NewField = GroupField2(ID: ID, Title: Title, Description: Description, ControlTitle: ControlTitle,
                                   Starting: Starting, Default: Default, FieldType: FieldType,
                                   List: List, Handler: Handler)
        AddField(NewField)
    }
    
    /// Holds a list of all fields in the group.
    public var Fields: [GroupField2] = [GroupField2]()
    
    /// Holds the group's title.
    public var HeaderTitle: String = "No Title"
    
    /// Convert the list of allCases from a CaseIterable enum to a list of string.
    /// - Parameter List: Result of call to allCases on a CaseIterable enum.
    /// - Returns: List of string based on the values in `List`.
    public static func EnumListToStringList<T>(_ List: [T]) -> [String]
    {
        var result = [String]()
        for ListItem in List
        {
            result.append("\(ListItem)")
        }
        return result
    }
}

/// Contains information on one field for the raw theme viewer.
class GroupField2
{
    init(ID: UUID, Title: String, Description: String, ControlTitle: String, Starting: Any, Default: Any,
         FieldType: FieldTypes, List: [String]? = nil, Handler: ((Any) -> ())? = nil)
    {
        self.ID = ID
        self.Title = Title
        self.Description = Description
        self.ControlTitle = ControlTitle
        self.Starting = Starting
        self.Default = Default
        self.FieldType = FieldType
        self.StringList = List
        self.Handler = Handler
    }
    
    /// Holds the ID of the field.
    public var ID: UUID = UUID.Empty
    
    /// Holds the title of the field.
    public var Title: String = ""
    
    /// Holds the default value of the field.
    public var Default: Any!
    
    /// Holds the starting value of the field.
    public var Starting: Any!
    
    /// Holds the string list for as appropriate.
    public var StringList: [String]!
    
    /// Holds the data type of the field.
    public var FieldType: FieldTypes!
    
    /// Holds the change handler of the field.
    public var Handler: ((Any) -> ())? = nil
    
    /// Holds the description string.
    public var Description: String = ""
    
    /// Title for the control itself - not all views use titles.
    public var ControlTitle: String = ""
}
