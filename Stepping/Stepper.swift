//
//  Stepper.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Handles stepping through logical sections of code at runtime without using Xcode's debugger.
/// - Note: This class is intended for use only in the debug release.
class Stepper
{
    /// Holds the delegate that does the actual display of the step.
    private weak static var _Delegate: StepperHelper? = nil
    /// Get or set the delegate that does the UI display of the step.
    weak static var Delegate: StepperHelper?
        {
        get
        {
            return _Delegate
        }
        set
        {
            _Delegate = newValue
        }
    }
    
    /// Holds the stepping enabled flag.
    private static var _SteppingEnabled: Bool = true
    /// Get or set the enable stepping flag.
    public static var SteppingEnabled: Bool
    {
        get
        {
            return _SteppingEnabled
        }
        set
        {
            _SteppingEnabled = newValue
        }
    }
    
    /// Holds the enable remote log flag.
    private static var _RemoteLogEnabled: Bool = true
    /// Get or set the enable remote log flag.
    public static var RemoteLogEnabled: Bool
    {
        get
        {
            return _RemoteLogEnabled
        }
        set
        {
            _RemoteLogEnabled = newValue
        }
    }
    
    /// "Stops" execution by displaying a modal UI element of some type with information from the caller.
    /// - Note:
    ///   - If stepping is not enabled (see `SteppingEnabled`), control will return immediately.
    ///   - If the value of `Stepped` is **.NOP**, control will return immediately.
    /// - Parameter From: Description of the source of the step call.
    /// - Parameter Message: Message from the source that is (hopefully) relevant to the user.
    /// - Parameter Steps: Uniform type of step (see enum `Steps`).
    /// - Parameter WaitForUser: Determines if the modal UI element is actually shown or not.
    /// - Parameter Completed: Completion handler.
    public static func Step(From: String, Message: String, Stepped: Steps, WaitForUser: Bool, Completed: (() -> ())?)
    {
        if !SteppingEnabled
        {
            return
        }
        if Stepped == .NOP
        {
            return
        }
        
        Delegate?.DisplayStep(From: From, Message: Message, Stepped: Stepped)
        
        Completed?()
    }
    
    /// "Stops" execution by displaying a modal UI element of some type with information from the caller.
    /// - Note:
    ///   - If stepping is not enabled (see `SteppingEnabled`), control will return immediately.
    ///   - If the value of `Stepped` is **.NOP**, control will return immediately.
    /// - Parameter From: Description of the source of the step call.
    /// - Parameter Message: Message from the source that is (hopefully) relevant to the user.
    /// - Parameter Steps: Uniform type of step (see enum `Steps`).
    /// - Parameter WaitForUser: Determines if the modal UI element is actually shown or not.
    /// - Parameter SendtoRemoteLog: If true, appropriate stepping information is sent to the remote debugger/logger.
    /// - Parameter Completed: Completion handler.
    public static func Step(From: String, Message: String, Stepped: Steps, WaitForUser: Bool, SendToRemoteLog: Bool, Completed: (() -> ())?)
    {
        if !SteppingEnabled
        {
            return
        }
        if Stepped == .NOP
        {
            return
        }
        
        Delegate?.DisplayStep(From: From, Message: Message, Stepped: Stepped)
        
        if SendToRemoteLog
        {
            
        }
        
        Completed?()
    }
    
    /// Converts the step category to a string.
    /// - Parameter Stepped: The **Steps** value to convert.
    /// - Returns: A string equivalent of the passed enum.
    public static func ConvertStepToString(_ Stepped: Steps) -> String
    {
        switch Stepped
        {
            case .NOP:
                return "NOP"
            
            case .Map:
                return "Board Map"
            
            case .Board:
                return "Game Board"
            
            case .GameLogic:
                return "Game Logic"
            
            case .Piece:
                return "Piece"
            
            case .UI:
                return "UI"
            
            case .View3D:
                return "3D View"
            
            case .General:
                return "General/Miscellaneous"
        }
    }
}

/// Step catagories.
/// - **NOP**: No operation - step call ignored.
/// - **Map**: Map stepping.
/// - **Board**: Board stepping.
/// - **GameLogic**: Game logic stepping
/// - **Piece**: Piece stepping.
/// - **UI**: UI-level stepping.
/// - **View3D**: 3D view stepping.
/// - **General**: General purpose/miscellaneous category. Should minimize use.
enum Steps: Int, CaseIterable
{
    case NOP = 0
    case Map = 1
    case Board = 2
    case GameLogic = 3
    case Piece = 4
    case UI = 5
    case View3D = 6
    case General = 7
}
