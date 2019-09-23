//
//  GroupField.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/20/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains information on one field for the raw theme viewer.
class GroupField
{
    /// Initializer.
    /// - Note:
    ///   - If the type is `.StringList`, the `Starting` and `Default` parameters must be a member of the contents
    ///     of 'List'. All strings are treated as case sensitive.
    /// - Parameter ID: ID of the field.
    /// - Parameter Title: Title of the field. Intended to be used as a high-level, short description of the field.
    /// - Parameter Description: Longer description of the field.
    /// - Parameter ControlTitle: String to use to describe the control. Not all types use this value.
    /// - Parameter Starting: The starting value to show intially. The `State` property is set to this value.
    /// - Parameter Default: The default value.
    /// - Parameter FieldType: The type of data, eg, String, Double, and the like.
    /// - Parameter List: List of string for the `.StringList` type.
    /// - Parameter Handler: Code to execute when the value of the field changes.
    /// - Parameter DisableControl: If true, the input control is disabled. Defaults to false.
    init(ID: UUID, Title: String, Description: String, ControlTitle: String, Starting: Any, Default: Any,
         FieldType: FieldTypes, List: [String]? = nil, Handler: ((Any) -> ())? = nil,
         DisableControl: Bool = false)
    {
        self.ID = ID
        self.Title = Title
        self.Description = Description
        self.ControlTitle = ControlTitle
        self.Starting = Starting
        self.State = Starting
        self.Default = Default
        self.FieldType = FieldType
        self.StringList = List
        self.Handler = Handler
        self.DisableControl = DisableControl
    }
    
    /// Holds the dirty flag.
    private var _Dirty: Bool = false
    /// Get or set the dirty flag.
    public var Dirty: Bool
    {
        get
        {
            return _Dirty
        }
        set
        {
            _Dirty = newValue
        }
    }
    
    /// Holds the ID of the field.
    public var ID: UUID = UUID.Empty
    
    /// Holds the title of the field.
    public var Title: String = ""
    
    /// Holds the default value of the field.
    public var Default: Any!
    
    /// Holds the starting value of the field. Sets `State` to the same value
    /// and clears the dirty flag.
    public var Starting: Any!
    {
        didSet
        {
            State = Starting
            _Dirty = false
        }
    }
    
    /// Current state value.
    public var State: Any!
    {
        didSet
        {
            _Dirty = true
        }
    }
    
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
    
    /// String list warning trigger values. If a selected item is in this list, a warning
    /// (the value to the item key) will be displayed.
    public var WarningTriggers: [String: String] = [String: String]()
    
    /// Disable control flag.
    public var DisableControl: Bool!
    
    /// Border color for the action view.
    public var ActionBorderColor: UIColor = UIColor.clear
    
    /// Text color for the action button.
    public var ActionButtonTextColor: UIColor = UIColor.systemBlue
    
    /// Background color for the action button.
    public var ActionButtonBackgroundColor = UIColor.clear
}

