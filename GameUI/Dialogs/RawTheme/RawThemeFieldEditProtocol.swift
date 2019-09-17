//
//  RawThemeFieldEditProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for communication between editor fields and the parent view controller.
protocol RawThemeFieldEditProtocol: class
{
    /// Notification that the user edited a field.
    /// - Parameter ID: ID of the field that was edited.
    /// - Parameter NewValue: The field's edited value.
    /// - Parameter DefaultValue: The field's default value.
    /// - Parameter FieldType: The field's type.
    func EditedField(_ ID: UUID, NewValue: Any, DefaultValue: Any, FieldType: FieldTypes)
}

/// Field types for editing.
/// - **Bool**: Boolean fields.
/// - **Int**: Integer fields.
/// - **Double**: Double fields.
/// - **Vector3**: SCNVector3 fields.
/// - **Vector4**: SCNVector4 fields.
/// - **String**: String fields.
/// - **Color**: UIColor fields.
/// - **Gradient**: Color gradient fields.
/// - **StringList**: List of strings fields.
/// - **Image**: An image (uses image picker).
enum FieldTypes: String, CaseIterable
{
    case Bool = "Bool"
    case Int = "Int"
    case Double = "Double"
    case Vector3 = "Vector3"
    case Vector4 = "Vector4"
    case String = "String"
    case Color = "Color"
    case Gradient = "Gradient"
    case StringList = "StringList"
    case Image = "Image"
}
