//
//  GroupData.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds groups of data for the raw theme viewer.
class GroupData
{
    /// Initializer.
    /// - Parameter Title: Group title.
    init(_ Title: String)
    {
        HeaderTitle = Title
    }
    
    /// Add a new field to the group.
    /// - Parameter NewField: The field to add.
    public func AddField(_ NewField: GroupField)
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
    /// - Parameter DisableControl: If true, the input control is disabled. Defaults to false.
    public func AddField(ID: UUID, Title: String, Description: String, ControlTitle: String,
                         Default: Any, Starting: Any, FieldType: FieldTypes, List: [String]? = nil,
                         Handler: ((Any) -> ())? = nil, DisableControl: Bool = false)
    {
        let NewField = GroupField(ID: ID, Title: Title, Description: Description, ControlTitle: ControlTitle,
                                   Starting: Starting, Default: Default, FieldType: FieldType,
                                   List: List, Handler: Handler, DisableControl: DisableControl)
        AddField(NewField)
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
    /// - Parameter DisableControl: If true, the input control is disabled. Defaults to false.
    /// - Parameter Warnings: List of terms in the list that will cause a warning to appear.
    public func AddField(ID: UUID, Title: String, Description: String, ControlTitle: String,
                         Default: Any, Starting: Any, FieldType: FieldTypes, List: [String]? = nil,
                         Handler: ((Any) -> ())? = nil, DisableControl: Bool = false,
                         Warnings: [String: String]? = nil)
    {
        let NewField = GroupField(ID: ID, Title: Title, Description: Description, ControlTitle: ControlTitle,
                                  Starting: Starting, Default: Default, FieldType: FieldType,
                                  List: List, Handler: Handler, DisableControl: DisableControl)
        NewField.Warnings = Warnings
        AddField(NewField)
    }
    
    /// Holds a list of all fields in the group.
    public var Fields: [GroupField] = [GroupField]()
    
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

