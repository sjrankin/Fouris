//
//  GridCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GridCell: UIView, IntraGridProtocol
{
    weak var CellParentDelegate: IntraGridProtocol? = nil
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    func Initialize()
    {
        let SingleTap = UITapGestureRecognizer(target: self, action: #selector(SingleTapHandler))
        SingleTap.numberOfTapsRequired = 1
        self.addGestureRecognizer(SingleTap)
    }
    
    func Start()
    {
        DrawCell()
    }
    
    @objc func SingleTapHandler(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            CellParentDelegate?.GridCellTapped(Column: Column, Row: Row, TapCount: 1)
            _IsSelected = !_IsSelected
            CellParentDelegate?.GridCellSelected(Column: Column, Row: Row, IsInSelectedState: _IsSelected)
        }
    }
    
    private var _IsSelected: Bool = false
    {
        didSet
        {
            DrawCell()
        }
    }
    public var IsSelected: Bool
    {
        get
        {
            return _IsSelected
        }
        set
        {
            _IsSelected = newValue
        }
    }
    
    private var _IsPivot: Bool = false
    {
        didSet
        {
            DrawCell()
        }
    }
    public var IsPivot: Bool
    {
        get
        {
            return _IsPivot
        }
        set
        {
            _IsPivot = newValue
        }
    }
    
    func DrawCell()
    {
        var BGColor = UIColor.white
        if _IsPivot
        {
            BGColor = (CellParentDelegate?.GetPivotBackgroundColor())!
        }
        else
        {
            if _IsSelected
            {
                BGColor = (CellParentDelegate?.GetSelectedBackgroundColor())!
            }
            else
            {
                BGColor = (CellParentDelegate?.GetBaseBackgroundColor())!
            }
        }
        self.backgroundColor = BGColor
        self.layer.borderWidth = (CellParentDelegate?.GetBorderWidth())!
        self.layer.borderColor = (CellParentDelegate?.GetBaseBorderColor())!.cgColor
    }
    
    func Redraw()
    {
        DrawCell()
    }
    
    private var _Column: Int = -1
    public var Column: Int
    {
        get
        {
            return _Column
        }
        set
        {
            _Column = newValue
        }
    }
    
    private var _Row: Int = -1
    public var Row: Int
    {
        get
        {
            return _Row
        }
        set
        {
            _Row = newValue
        }
    }
    
    func GridCellTapped(Column: Int, Row: Int, TapCount: Int)
    {
        //Not used in this class.
    }
    
    func GridCellSelected(Column: Int, Row: Int, IsInSelectedState: Bool)
    {
        //Not used in this class.
    }
    
    func GetBaseBackgroundColor() -> UIColor
    {
        return UIColor.clear
    }
    
    func GetSelectedBackgroundColor() -> UIColor
    {
        return UIColor.clear
    }
    
    func GetPivotBackgroundColor() -> UIColor
    {
        return UIColor.clear
    }
    
    func GetBaseBorderColor() -> UIColor
    {
        return UIColor.clear
    }
    
    func GetBorderWidth() -> CGFloat
    {
        return 0.0
    }
}
