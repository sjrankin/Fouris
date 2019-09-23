//
//  GroupData.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

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
        if let WarningList = Warnings
        {
            NewField.WarningTriggers = WarningList
        }
        else
        {
            NewField.WarningTriggers = [String: String]()
        }
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
    
    /// Takes the double values in three text fields and returns an SCNVector3 value.
    /// - Parameter XBox: X value text field.
    /// - Parameter YBox: Y value text field.
        /// - Parameter ZBox: Z value text field.
    /// - Returns: SCNVector3 value based on the text fields. Nil if any text field has invalid data.
    public static func AssembleVector3(XBox: UITextField, YBox: UITextField, ZBox: UITextField) -> SCNVector3?
    {
        let XRaw = XBox.text
        let YRaw = YBox.text
        let ZRaw = ZBox.text
        if XRaw == nil || YRaw == nil || ZRaw == nil
        {
            return nil
        }
        let XVal = Double(XRaw!)
        let YVal = Double(YRaw!)
        let ZVal = Double(ZRaw!)
        if XVal == nil || YVal == nil || ZVal == nil
        {
            return nil
        }
        return SCNVector3(XVal!, YVal!, ZVal!)
    }
    
    /// Takes the double values in four text fields and returns an SCNVector4 value.
    /// - Parameter XBox: X value text field.
    /// - Parameter YBox: Y value text field.
    /// - Parameter ZBox: Z value text field.
    /// - Parameter WBox: W value text field.
    /// - Returns: SCNVector4 value based on the text fields. Nil if any text field has invalid data.
    public static func AssembleVector4(XBox: UITextField, YBox: UITextField, ZBox: UITextField, WBox: UITextField) -> SCNVector4?
    {
        let XRaw = XBox.text
        let YRaw = YBox.text
        let ZRaw = ZBox.text
        let WRaw = WBox.text
        if XRaw == nil || YRaw == nil || ZRaw == nil || WRaw == nil
        {
            return nil
        }
        let XVal = Double(XRaw!)
        let YVal = Double(YRaw!)
        let ZVal = Double(ZRaw!)
        let WVal = Double(WRaw!)
        if XVal == nil || YVal == nil || ZVal == nil || WVal == nil
        {
            return nil
        }
        return SCNVector4(XVal!, YVal!, ZVal!, WVal!)
    }
}

