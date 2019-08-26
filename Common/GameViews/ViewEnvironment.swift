//
//  ViewEnvironment.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/12/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains utility functions related to the running environment.
class Environment
{
    /// Returns the type of device the program is running on.
    /// - Note: If running on a Mac (eg, AppKit), `.Desktop` is always returned.
    /// - Returns: The type of device the program is running on. Returns `ExecutingDevice.Unknown` if the device type
    ///            is not comprehended.
    static func DeviceType() -> ExecutingDevice
    {
        switch UIDevice.current.userInterfaceIdiom
        {
        case.pad:
            return .iPad
            
        case .phone:
            return .iPhone
            
        default:
            return .Unknown
        }
     }
    
    /// Returns the model name (eg, iPhone8,2).
    ///
    /// - Note: [How to determine the current iPhone device model.](https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model)
    ///
    /// - Returns: Model name.
    static func ModelName() -> String
    {
        var SystemInfo = utsname()
        uname(&SystemInfo)
        let MirroredMachine = Mirror(reflecting: SystemInfo.machine)
        let Identifier = MirroredMachine.children.reduce("")
        {
            identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return Identifier
    }
    
    /// Maps phone model names to phone types.
    private static let PhoneMap: [String: PhoneTypes] =
    [
        "iPhone3,1": .iPhone4,
        "iPhone3,2": .iPhone4,
        "iPhone3,3": .iPhone4,
        "iPhone4,1": .iPhone4s,
        "iPhone5,1": .iPhone5,
        "iPhone5,2": .iPhone5,
        "iPhone5,3": .iPhone5c,
        "iPhone5,4": .iPhone5c,
        "iPhone6,1": .iPhone5s,
        "iPhone6,2": .iPhone5s,
        "iPhone7,2": .iPhone6,
        "iPhone7,1": .iPhone6Plus,
        "iPhone8,1": .iPhone6s,
        "iPhone8,2": .iPhone6sPlus,
        "iPhone9,1": .iPhone7,
        "iPhone9,3": .iPhone7,
        "iPhone9,2": .iPhone7Plus,
        "iPhone9,4": .iPhone7Plus,
        "iPhone8,4": .iPhoneSE,
        "iPhone10,1": .iPhone8,
        "iPhone10,4": .iPhone8,
        "iPhone10,2": .iPhone8Plus,
        "iPhone10,5": .iPhone8Plus,
        "iPhone10,3": .iPhoneX,
        "iPhone10,6": .iPhoneX,
        "iPhone11,2": .iPhoneXS,
        "iPhone11,4": .iPhoneXSMax,
        "iPhone11,6": .iPhoneXSMax,
        "iPhone11,8": .iPhoneXR,
        "i386": .Simulator,
        "x86_64": .Simulator,
    ]
    
    /// Returns the type of phone we're running on. If not running on a phone, the type returned
    /// will reflect that.
    ///
    /// - Returns: Phone type if on a phone. If not on a phone, either `.Simulator` or `.NotOnPhone` will be returned.
    static func PhoneType() -> PhoneTypes
    {
        let MachineName = ModelName()
        if let CurrentMachine = PhoneMap[MachineName]
        {
            return CurrentMachine
        }
        return .NotOnPhone
    }
    
    /// Determines if the current phone is on a "plus"-sized phone.
    ///
    /// - Returns: True if on a plus (large) phone, false if not (or if on the simulator or non-phone device).
    static func OnPlusPhone() -> Bool
    {
        return [.iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .iPhone8Plus, .iPhoneX, .iPhoneXSMax, .iPhoneXR].contains(PhoneType())
    }
}

/// Types of known and/or supported phones.
///
/// - iPhone4: iPhone 4 (not supported)
/// - iPhone4s: iPhone 4s (not supported)
/// - iPhone5: iPhone 5 (not supported)
/// - iPhone5c: iPhone 5c (not supported)
/// - iPhone5s: iPhone 5s (not supported)
/// - iPhone6: iPhone 6
/// - iPhone6Plus: iPhone 6+
/// - iPhone6s: iPhone 6s
/// - iPhone6sPlus: iPhone 6s+
/// - iPhone7: iPhone 7
/// - iPhone7Plus: iPhone 7+
/// - iPhoneSE: iPhone SE
/// - iPhone8: iPhone 8
/// - iPhone8Plus: iPhone 8+
/// - iPhoneX: iPhone X
/// - iPhoneXS: iPhone XS
/// - iPhoneXSMax: iPhone XS Max
/// - iPhoneXR: iPhone XR
/// - Simulator: Running on simulator.
/// - NotOnPhone: Not on a phone.
enum PhoneTypes: Int, CaseIterable
{
    case iPhone4 = 0
    case iPhone4s = 1
    case iPhone5 = 2
    case iPhone5c = 3
    case iPhone5s = 4
    case iPhone6 = 5
    case iPhone6Plus = 6
    case iPhone6s = 7
    case iPhone6sPlus = 8
    case iPhone7 = 9
    case iPhone7Plus = 10
    case iPhoneSE = 11
    case iPhone8 = 12
    case iPhone8Plus = 13
    case iPhoneX = 14
    case iPhoneXS = 15
    case iPhoneXSMax = 16
    case iPhoneXR = 17
    case Simulator = 1000
    case NotOnPhone = 2000
}

/// Where the program is running.
///
/// - iPhone: On an iPhone (iOS).
/// - iPad: On an iPad (iOS).
/// - Unknown: On an unknown device.
enum ExecutingDevice: Int, CaseIterable
{
    case iPhone = 1
    case iPad = 2
    case Unknown = 1000
}
