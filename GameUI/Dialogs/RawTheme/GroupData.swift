//
//  GroupData.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/16/19.
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
    /// - Parameter Default: Default value of the field.
    /// - Parameter Starting: Starting value of the field.
    /// - Parameter FieldType: Data type for the field.
    /// - Parameter Handler: Change handler.
    public func AddField(ID: UUID, Title: String, Default: Any, Starting: Any, FieldType: FieldTypes,
                         Handler: ((Any) -> ())? = nil)
    {
        let NewField = GroupField(ID: ID, Title: Title, Default: Default, Starting: Starting,
                                  FieldType: FieldType, Handler: Handler)
        AddField(NewField)
    }
    
    /// Holds a list of all fields in the group.
    public var Fields: [GroupField] = [GroupField]()
    
    /// Holds the group's title.
    public var HeaderTitle: String = "No Title"
}

/// Contains information on one field for the raw theme viewer.
class GroupField
{
    /// Initializer.
    /// - Parameter ID: ID of the field.
    /// - Parameter Title: Title of the field.
    /// - Parameter Default: Default value of the field.
    /// - Parameter Starting: Starting value of the field.
    /// - Parameter FieldType: Data type for the field.
    /// - Parameter Handler: Change handler.
    init(ID: UUID, Title: String, Default: Any, Starting: Any, FieldType: FieldTypes,
         Handler: ((Any) -> ())? = nil)
    {
        self.ID = ID
        self.Title = Title
        self.Default = Default
        self.Starting = Starting
        self.FieldType = FieldType
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
    
    /// Holds the data type of the field.
    public var FieldType: FieldTypes!
    
    /// Holds the change handler of the field.
    public var Handler: ((Any) -> ())? = nil
}
