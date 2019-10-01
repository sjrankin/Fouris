//
//  TextLayerManager.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

/// Implements an overlay placed over the main game views that allows the game to shows text that isn't actually in the
/// game view. This is especially useful for the 3D view which can rotated and move - if the text were part of the 3D game
/// view, it would move around, too, making it difficult to see.
class TextLayerManager: UIView, ParentSizeChangedProtocol
{
    /// Initializer
    /// - Parameter frame: Rectangle for the frame.
    override init(frame frameRect: CGRect)
    {
        super.init(frame: frameRect)
    }
    
    /// Required initializer
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Initializer.
    /// - Parameter ID: ID of the theme to use to draw the text.
    /// - Parameter LayerFrame: Frame to use for the text layer.
    func Initialize(With ID: UUID, LayerFrame: CGRect)
    {
        self.layer.backgroundColor = UIColor.clear.cgColor
        ThemeID = ID
        CurrentSize = CGSize(width: LayerFrame.width, height: LayerFrame.height)
        Redraw()
    }
    
    /// Holds the current size of the layer.
    private var CurrentSize: CGSize? = nil
    
    /// Handle size changes at run-time.
    /// - Parameter Frame: The new frame to use for the layer.
    func NewSize(Frame: CGRect)
    {
        self.frame = Frame
        self.bounds = Frame
        CurrentSize = CGSize(width: Frame.width, height: Frame.height)
        Redraw()
    }
    
    func NewParentSize(Bounds: CGRect, Frame: CGRect)
    {
        
    }
    
    /// Holds the ID of the current theme.
    private var _ThemeID: UUID = UUID.Empty
    /// Get or set the ID of the theme to use.
    public var ThemeID: UUID
    {
        get
        {
            return _ThemeID
        }
        set
        {
            _ThemeID = newValue
            //CurrentTheme = ThemeManager.ThemeFrom(ID: _ThemeID)
            Redraw()
        }
    }

    private func Redraw()
    {
        if CurrentSize == nil
        {
            return
        }
    }
    
    /// Holds the current theme.
    //private var CurrentTheme: ThemeDescriptor? = nil
}
