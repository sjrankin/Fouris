//
//  FieldCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class FieldCell: UITableViewCell
{
    weak var FieldDelegate: RawThemeFieldEditProtocol? = nil
    
    public static let FieldCellHeight: CGFloat = 75.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    func DrawUI()
    {
        if !WasInitialized
        {
            print("Tried to draw UI when not initialized.")
            return
        }
    }
    
    func Initialize(FieldID: UUID, Title: String, Default: Any, Current: Any, FieldType: FieldTypes,
                    ParentWidth: CGFloat, ChangeHandler: ((Any) -> ())? = nil)
    {
        self.selectionStyle = .none
        FieldTitle = Title
        ID = FieldID
        self.Current = Current
        self.Default = Default
        self.FieldType = FieldType
        self.ParentWidth = ParentWidth
        WasInitialized = true
    }
    
    func Initialize(With: GroupField, ParentWidth: CGFloat)
    {
        self.selectionStyle = .none
        FieldTitle = With.Title
        ID = With.ID
        Default = With.Default
        Current = With.Starting
        FieldType = With.FieldType
        ChangeHandler = With.Handler
        self.ParentWidth = ParentWidth
        WasInitialized = true
    }
    
    public var Parent: UIViewController? = nil
    
    public var ChangeHandler: ((Any) -> ())? = nil
    
    public var FieldLabel: UILabel? = nil
    
    public var WasInitialized = false
    
    public var FieldTitle: String = ""
    
    public var ParentWidth: CGFloat = 0.0
    
    public var ID: UUID = UUID.Empty
    
    public var Default: Any!
    
    public var Current: Any!
    
    public var FieldType: FieldTypes!
    
    func StyleTextBox(_ Box: UITextField)
    {
        Box.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.regular)
        Box.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        Box.borderStyle = .roundedRect
        Box.autocorrectionType = .no
        Box.keyboardType = .default
        Box.returnKeyType = .done
        Box.enablesReturnKeyAutomatically = true
        Box.smartDashesType = .no
        Box.autocorrectionType = .no
        Box.autocapitalizationType = .none
        Box.spellCheckingType = .no
    }
    
    func StyleTitle(_ TitleView: UILabel)
    {
        TitleView.font = UIFont(name: "Avenir", size: 24.0)
    }
}
