//
//  BoardDescriptor2.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BoardDescriptor2
{
    public var _BucketShape: CenterShapes = .Empty
    public var BucketShape: CenterShapes
    {
        get
        {
            return _BucketShape
        }
        set
        {
            _BucketShape = newValue
        }
    }
    
    public var _GameType: BaseGameTypes = .Standard
    public var GameType: BaseGameTypes
    {
        get
        {
            return _GameType
        }
        set
        {
            _GameType = newValue
        }
    }
    
    public var _GameBoardWidth: Int = 30
    public var GameBoardWidth: Int
    {
        get
        {
            return _GameBoardWidth
        }
        set
        {
            _GameBoardWidth = newValue
        }
    }
    
    public var _GameBoardHeight: Int = 30
    public var GameBoardHeight: Int
    {
        get
        {
            return _GameBoardHeight
        }
        set
        {
            _GameBoardHeight = newValue
        }
    }
    
    public func GameBoardSize() -> CGSize
    {
        return CGSize(width: _GameBoardWidth, height: _GameBoardHeight)
    }
    
    public var _BucketX: Int = 5
    public var BucketX: Int
    {
        get
        {
            return _BucketX
        }
        set
        {
            _BucketX = newValue
        }
    }
    
    public var _BucketY: Int = 5
    public var BucketY: Int
    {
        get
        {
            return _BucketY
        }
        set
        {
            _BucketY = newValue
        }
    }
    
    public var _BucketWidth: Int = 10
    public var BucketWidth: Int
    {
        get
        {
            return _BucketWidth
        }
        set
        {
            _BucketWidth = newValue
        }
    }
    
    public var _BucketHeight: Int = 20
    public var BucketHeight: Int
    {
        get
        {
            return _BucketHeight
        }
        set
        {
            _BucketHeight = newValue
        }
    }
    
    public func BucketCorner() -> CGPoint
    {
        return CGPoint(x: _BucketX, y: _BucketY)
    }
    
    public func BucketSize() -> CGSize
    {
        return CGSize(width: _BucketWidth, height: _BucketHeight)
    }
    
    public func BucketRectangle() -> CGRect
    {
        return CGRect(origin: BucketCorner(), size: BucketSize())
    }
    
    public var _BucketRotates: Bool = false
    public var BucketRotates: Bool
    {
        get
        {
            return _BucketRotates
        }
        set
        {
            _BucketRotates = newValue
        }
    }
    
    public var _PiecesRotate: Bool = false
    public var PiecesRotate: Bool
    {
        get
        {
            return _PiecesRotate
        }
        set
        {
            _PiecesRotate = newValue
        }
    }
    
    public var _LeftButtonVisible: Bool = true
    public var LeftButtonVisible: Bool
    {
        get
        {
            return _LeftButtonVisible
        }
        set
        {
            _LeftButtonVisible = newValue
        }
    }
    
    public var _RightButtonVisible: Bool = true
    public var RightButtonVisible: Bool
    {
        get
        {
            return _RightButtonVisible
        }
        set
        {
            _RightButtonVisible = newValue
        }
    }
    
    public var _UpButtonVisible: Bool = true
    public var UpButtonVisible: Bool
    {
        get
        {
            return _UpButtonVisible
        }
        set
        {
            _UpButtonVisible = newValue
        }
    }
    
    public var _DownButtonVisible: Bool = true
    public var DownButtonVisible: Bool
    {
        get
        {
            return _DownButtonVisible
        }
        set
        {
            _DownButtonVisible = newValue
        }
    }
    
    public var _DropDownButtonVisible: Bool = true
    public var DropDownButtonVisible: Bool
    {
        get
        {
            return _DropDownButtonVisible
        }
        set
        {
            _DropDownButtonVisible = newValue
        }
    }
    
    public var _FlyAwayButtonVisible: Bool = true
    public var FlyAwayButtonVisible: Bool
    {
        get
        {
            return _FlyAwayButtonVisible
        }
        set
        {
            _FlyAwayButtonVisible = newValue
        }
    }
    
    public var _RotateLeftButtonVisisble: Bool = true
    public var RotateLeftButtonVisisble: Bool
    {
        get
        {
            return _RotateLeftButtonVisisble
        }
        set
        {
            _RotateLeftButtonVisisble = newValue
        }
    }
    
    public var _FreezeButton: FreezeButtonActions = .Invisible
    public var FreezeButton: FreezeButtonActions
    {
        get
        {
            return _FreezeButton
        }
        set
        {
            _FreezeButton = newValue
        }
    }
}

enum FreezeButtonActions: String, CaseIterable
{
    case Visible = "Visible"
    case Invisible = "Invisible"
    case Once = "Once"
    case Rotations2 = "Rotations2"
    case Rotations4 = "Rotations4"
}
