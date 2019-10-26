//
//  PredefinedColors.swift
//  Fouris
//  Adapted from BumpCamera and Visualizer Clock.
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2018, 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Maintains predefined colors and color groups.
class PredefinedColors
{

    
    /// Return a list of color groups defined and ordered by the passed color order.
    /// - Parameter Order: Order of the colors. Also defines the type of color groups returned.
    /// - Returns: List of color groups.
    public static func ColorsInOrder(_ Order: ColorOrders) -> [PredefinedColorGroup]
    {
        switch Order
        {
            case .Name:
                return GetNameSortedColors()
            
            case .NameList:
                return GetNameSortedColorsUngrouped()
            
            case .Hue:
                return GetHueSortedColors()
            
            case .Brightness:
                return GetBrightnessSortedColors()
            
            case .Palette:
                return GetPaletteSortedColors()
        }
    }
    
    /// Cached list of color group/palette names.
    private static var ColorGroupNames: [String]? = nil
    
    /// Return a list of all group/palette names in the predefined list of colors.
    /// - Returns: Sorted list of color group/palette names.
    public static func GetColorGroupNames() -> [String]
    {
        if ColorGroupNames != nil
        {
            return ColorGroupNames!
        }
        ColorGroupNames = [String]()
        for SomeColor in PredefinedColorTable.Colors
        {
            if (ColorGroupNames?.contains(SomeColor.Palette))!
            {
                continue
            }
            ColorGroupNames?.append(SomeColor.Palette)
        }
        ColorGroupNames?.sort{$0 < $1}
        return ColorGroupNames!
    }
    
    /// Cache of colors in groups.
    private static var CachedColors: [String: [PredefinedColor]]? = nil
    
    /// Return a list of all colors in the specified color group.
    /// - Parameter Group: Name of the color group (AKA palette name) whose colors will be returned. If
    ///                    the specified name is undefined (eg, not in the list of colors palettes), an
    ///                    empty list is returned.
    /// - Returns: List of all colors in the specified group/palette.
    public static func GetColorsIn(Group: String) -> [PredefinedColor]
    {
        if CachedColors == nil
        {
            CachedColors = [String: [PredefinedColor]]()
        }
        if let ColorList = CachedColors![Group]
        {
            return ColorList
        }
        let ColorList = PredefinedColorTable.Colors.filter{$0.Palette == Group}
        CachedColors![Group] = ColorList
        return ColorList
    }
    
    /// Determines the distance between two three-dimensional points. Specifically used to determine
    /// how far away colors are from each other. The semantics of the passed values are not of
    /// importance here.
    /// - Parameters:
    ///   - First: First point, tuple of three dimensions.
    ///   - Second: Second point, tuple of three dimensions.
    /// - Returns: Distance between the two specified three-dimensional points.
    private static func DistanceBetween(_ First: (Int, Int, Int), _ Second: (Int, Int, Int)) -> Double
    {
        var Term1 = (Second.0 - First.0)
        Term1 = Term1 * Term1
        var Term2 = (Second.1 - First.1)
        Term2 = Term2 * Term2
        var Term3 = (Second.2 - First.2)
        Term3 = Term3 * Term3
        return sqrt(Double(Term1 + Term2 + Term3))
    }
    
    /// Return the color in the list of colors specified by Group that is closest to the test color
    /// passed in ToColor. This function uses a brute-force method that determines the distance between
    /// the passed color and each color in the color group. The color in the specified group with the
    /// shortest distance from the passed color is the closest color.
    /// - Parameters:
    ///   - Group: Name of the color palette/group to compare against ToColor.
    ///   - ToColor: The color to test against the colors in the group specified by Group.
    /// - Returns: The index of the closest color in the specified group on success, nil
    ///            on error.
    public static func GetClosestColorIn(Group: String, ToColor: UIColor) -> Int?
    {
        let GroupColors = GetColorsIn(Group: Group)
        if GroupColors.count < 1
        {
            return nil
        }
        return GetClosestColorIn(Group: GroupColors, ToColor: ToColor)
    }
    
    /// Return the color in the passed list of colors that is closest to the test color passed
    /// in ToColor. This function uses a brute-force method that determines the distance between
    /// the passed color and each color in the list. The color in the list with the shortest
    /// distance from the passed color is the closest color.
    /// - Parameters:
    ///   - Group: List of colors to search for the closest color.
    ///   - ToColor: The color to test against the passed list of colors.
    /// - Returns: The index of the closest color in the passed list on success, nil
    ///            on error.
    public static func GetClosestColorIn(Group: [PredefinedColor], ToColor: UIColor) -> Int?
    {
        if Group.count < 1
        {
            return nil
        }
        if let (Index, _) = GetClosestColorInEx(Group: Group, ToColor: ToColor)
        {
            return Index
        }
        return nil
    }
    
    /// Return the color in the passed list of colors that is closest to the test color passed
    /// in ToColor. This function uses a brute-force method that determines the distance between
    /// the passed color and each color in the list. The color in the list with the shortest
    /// distance from the passed color is the closest color.
    /// - Parameters:
    ///   - Group: List of colors to search for the closest color.
    ///   - ToColor: The color to test against the passed list of colors.
    /// - Returns: Tuple of the index of the closest color in the passed list on success and the
    ///            actual distance, nil on error.
    public static func GetClosestColorInEx(Group: [PredefinedColor], ToColor: UIColor) -> (Int, Double)?
    {
        if Group.count < 1
        {
            return nil
        }
        var ClosestDistance = Double.greatestFiniteMagnitude
        var ClosestIndex = -1
        let (R, G, B) = Utility.GetRGB(ToColor)
        var Index = 0
        for SomeColor in Group
        {
            let (TR, TG, TB) = Utility.GetRGB(SomeColor.Color) 
            let SomeDistance = DistanceBetween((R, G, B), (TR, TG, TB))
            if SomeDistance < ClosestDistance
            {
                ClosestIndex = Index
                ClosestDistance = SomeDistance
            }
            Index = Index + 1
        }
        return (ClosestIndex, ClosestDistance)
    }
    
    /// Return the color at the specified index in the specified color group.
    /// - Parameters:
    ///   - Group: The group from with the color will be returned.
    ///   - At: The index of the color in the specified group.
    /// - Returns: The predefined color in the group at the specified index on success, nil if not
    ///            found or bad index.
    public static func GetColorIn(Group: String, At: Int) -> PredefinedColor?
    {
        let Colors = GetColorsIn(Group: Group)
        if Colors.count < 1
        {
            return nil
        }
        if At < 0 || At > Colors.count - 1
        {
            return nil
        }
        return Colors[At]
    }
    
    /// Sorts a list of predefined colors by the pass sort type.
    /// - Parameters:
    ///   - List: List of predefined colors to sort. Unaltered by this function.
    ///   - By: How to sort the list. .NameList and .Palette are not supported. If specified, the
    ///         original list is returned unchanged.
    /// - Returns: New list of sorted predefined colors.
    public static func SortColorList(_ List: [PredefinedColor], By: ColorOrders) -> [PredefinedColor]
    {
        switch By
        {
            case .Brightness:
                return List.sorted{$0.Brightness < $1.Brightness}
            
            case .Hue:
                return List.sorted{$0.Hue < $1.Hue}
            
            case .Name:
                return List.sorted{$0.ColorName < $1.ColorName}
            
            case .NameList:
                return List
            
            case .Palette:
                return List
        }
    }
    
    /// Return a color with the specified ID.
    /// - Parameter ID: ID of the color to return.
    /// - Returns: The color with the specified ID if found, nil if no color with the ID found.
    public static func ColorByID(_ ID: UUID) -> PredefinedColor?
    {
        for Color in PredefinedColorTable.Colors
        {
            if Color.ID == ID
            {
                return Color
            }
        }
        return nil
    }
    
    /// Holds the ranges for hue descriptions.
    static let HueRanges =
        [
            (355, 360, "Red", "355° - 10°"),
            (0, 10, "Red", "355° - 10°"),
            (11, 20, "Red-Orange", "11° - 20°"),
            (21, 40, "Orange & Brown", "21° - 40°"),
            (41, 50, "Orange-Yellow", "41° - 50°"),
            (51, 60, "Yellow", "51° - 60°"),
            (61, 80, "Yellow-Green", "61° - 80°"),
            (81, 140, "Green", "81° - 140°"),
            (141, 169, "Green-Cyan", "141° - 169°"),
            (170, 200, "Cyan", "170° - 200°"),
            (201, 220, "Cyan-Blue", "201° - 220°"),
            (221, 240, "Blue", "221° - 240°"),
            (241, 280, "Blue-Magenta", "241° - 280°ß"),
            (281, 320, "Magenta", "281° - 320°"),
            (321, 330, "Magenta-Pink", "321° - 330°"),
            (331, 345, "Pink", "331° - 345°"),
            (346, 355, "Pink-Red", "346° - 355°")
    ]
    
    /// Return the largest delta in the list of passed numbers.
    /// - Parameter Numbers: List of integers.
    /// - Returns: Largest delta in the list.
    private static func MaxDelta(_ Numbers: [CGFloat]) -> CGFloat
    {
        var Biggest: CGFloat = -1000000.0
        var Smallest: CGFloat = 1000000.0
        for Index in 0 ..< Numbers.count
        {
            if Numbers[Index] > Biggest
            {
                Biggest = Numbers[Index]
            }
            if Numbers[Index] < Smallest
            {
                Smallest = Numbers[Index]
            }
        }
        return abs(Biggest - Smallest)
    }
    
    /// Return the largest delta in the list of passed numbers.
    /// - Parameter Numbers: List of integers.
    /// - Returns: Largest delta in the list.
    private static func MaxDelta(_ Numbers: [Int]) -> Int
    {
        var Biggest: Int = -1000000
        var Smallest: Int = 1000000
        for Index in 0 ..< Numbers.count
        {
            if Numbers[Index] > Biggest
            {
                Biggest = Numbers[Index]
            }
            if Numbers[Index] < Smallest
            {
                Smallest = Numbers[Index]
            }
        }
        return abs(Biggest - Smallest)
    }
    
    /// Determines if the passed color is monochromatic.
    /// - Parameter TheColor: The color to test.
    /// - Returns: True if the color is monochromatic, false if not.
    private static func IsMonochromatic(_ TheColor: UIColor) -> Bool
    {
        let (R, G, B) = Utility.GetRGB(TheColor)
        let Delta = MaxDelta([R, G, B])
        return Delta == 0
    }
    
    /// Returns the starting range value for a given hue.
    /// - Parameter HueValue: The hue whose starting range value will be returned. Assumed to be normalized.
    /// - Returns: Starting hue range for the hue (see also HueRanges).
    private static func HueStartingRange(_ HueValue: Double) -> Double
    {
        let Hue = HueValue * 360.0
        let IHue = Int(Hue)
        for Range in HueRanges
        {
            if IHue >= Range.0 && IHue <= Range.1
            {
                return Double(Range.0)
            }
        }
        return -1.0
    }
    
    /// Return the name and range (as a string) of the hue passed to us.
    /// - Parameter HueValue: The hue value (normalized).
    /// - Returns: Tuple in the order name, range. If not found, "??","??" is returned.
    private static func GetHueGroupName(_ HueValue: Double) -> (String, String)
    {
        let Hue = HueValue * 360.0
        let IHue = Int(Hue)
        for Range in HueRanges
        {
            if IHue >= Range.0 && IHue <= Range.1
            {
                return (Range.2, Range.3)
            }
        }
        return ("??", "??")
    }
    
    /// Return a list of sorted color groups. Sorted by hue.
    /// - Returns: List of predefined color groups, sorted by hue.
    private static func GetHueSortedColors() -> [PredefinedColorGroup]
    {
        var Results = [PredefinedColorGroup]()
        
        for Color in PredefinedColorTable.Colors
        {
            if IsMonochromatic(Color.Color)
            {
                print("Found monochromatic color \(Color.ColorName)")
                let HueGroup = GroupWithName("Monochrome", Groups: Results)
                if HueGroup == nil
                {
                    let NewGroup = PredefinedColorGroup()
                    NewGroup.SortValue = -500.0
                    NewGroup.GroupName = "Monochrome"
                    NewGroup.GroupSubTitle = ""
                    NewGroup.OrderedBy = .Hue
                    NewGroup.GroupColors.append(Color)
                    Results.append(NewGroup)
                }
                else
                {
                    let HGroup = GroupWithName("Monochrome", Groups: Results)
                    if HGroup != nil
                    {
                        HGroup?.GroupColors.append(Color)
                    }
                }
                continue
            }
            let (HueGroupName, SubGroupName) = GetHueGroupName(Color.Hue)
            let HueGroup = GroupWithName(HueGroupName, Groups: Results)
            if HueGroup != nil
            {
                let HGroup = GroupWithName(HueGroupName, Groups: Results)
                if HGroup != nil
                {
                    HGroup?.GroupColors.append(Color)
                }
            }
            else
            {
                let NewGroup = PredefinedColorGroup()
                NewGroup.SortValue = HueStartingRange(Color.Hue)
                NewGroup.GroupName = HueGroupName
                NewGroup.GroupSubTitle = SubGroupName
                NewGroup.OrderedBy = .Hue
                NewGroup.GroupColors.append(Color)
                Results.append(NewGroup)
            }
        }
        
        Results.sort{$0.SortValue < $1.SortValue}
        for Result in Results
        {
            if Result.GroupName == "Monochrome"
            {
                Result.GroupColors.sort{$0.Brightness < $1.Brightness}
            }
            else
            {
                Result.GroupColors.sort{$0.Hue < $1.Hue}
            }
        }
        
        return Results
    }
    
    /// Create a brightness group name.
    /// - Parameter Value: Value of the brightness.
    /// - Returns: Name of a brightness group.
    private static func MakeBrightnessGroupName(_ Value: Double) -> String
    {
        var Working = Value
        Working = min(1.0, Working)
        Working = max(0.0, Working)
        let IWork = Int(Working * 10.0)
        switch IWork
        {
            case 0:
                return "0.0"
            
            case 1:
                return "0.1"
            
            case 2:
                return "0.2"
            
            case 3:
                return "0.3"
            
            case 4:
                return "0.4"
            
            case 5:
                return "0.5"
            
            case 6:
                return "0.6"
            
            case 7:
                return "0.7"
            
            case 8:
                return "0.8"
            
            case 9:
                return "0.9"
            
            case 10:
                return "1.0"
            
            default:
                return "???"
        }
    }
    
    /// Return a list of sorted color groups. Sorted by brightness.
    /// - Returns: List of predefined color groups, sorted by brightness.
    private static func GetBrightnessSortedColors() -> [PredefinedColorGroup]
    {
        var Results = [PredefinedColorGroup]()
        
        for Color in PredefinedColorTable.Colors
        {
            let BGroupName = MakeBrightnessGroupName(Color.Brightness)
            let BrightnessGroup = GroupWithName(BGroupName, Groups: Results)
            if BrightnessGroup != nil
            {
                let BGroup = GroupWithName(BGroupName, Groups: Results)
                if BGroup != nil
                {
                    BGroup?.GroupColors.append(Color)
                }
            }
            else
            {
                let NewGroup = PredefinedColorGroup()
                NewGroup.GroupName = BGroupName
                NewGroup.OrderedBy = .Brightness
                NewGroup.GroupColors.append(Color)
                Results.append(NewGroup)
            }
        }
        
        Results.sort{$0.GroupName < $1.GroupName}
        for Result in Results
        {
            Result.GroupColors.sort{$0.Brightness < $1.Brightness}
        }
        
        return Results
    }
    
    /// Determines if the list of groups contains the passed color name.
    /// - Parameters:
    ///   - Name: Name of the color to search for.
    ///   - Groups: List of groups to search for the passed name.
    /// - Returns: True if the name exists somewhere in the list of groups, false if not.
    private static func ContainsName(_ Name: String, Groups: [PredefinedColorGroup]) -> Bool
    {
        for Group in Groups
        {
            if Group.GroupName == Name
            {
                return true
            }
        }
        return false
    }
    
    /// Returns a predefined color group that contains a color with the passed name.
    /// - Parameters:
    ///   - Name: Name of the color to search for.
    ///   - Groups: List of pre-defined color groups to search.
    /// - Returns: The first pre-defined color group with the passed name if found, nil if nothing found.
    private static func GroupWithName(_ Name: String, Groups: [PredefinedColorGroup]) -> PredefinedColorGroup?
    {
        for Group in Groups
        {
            if Group.GroupName == Name
            {
                return Group
            }
        }
        return nil
    }
    
    /// Return a list of sorted color groups. Sorted by palette name.
    /// - Returns: List of predefined color groups, sorted by palette name.
    private static func GetPaletteSortedColors() -> [PredefinedColorGroup]
    {
        var Results = [PredefinedColorGroup]()
        
        for Color in PredefinedColorTable.Colors
        {
            let PaletteName = Color.Palette
            let PaletteGroup = GroupWithName(PaletteName, Groups: Results)
            if PaletteGroup != nil
            {
                PaletteGroup?.GroupColors.append(Color)
            }
            else
            {
                let NewGroup = PredefinedColorGroup()
                NewGroup.GroupName = PaletteName
                NewGroup.OrderedBy = .Palette
                NewGroup.GroupColors.append(Color)
                Results.append(NewGroup)
            }
        }
        
        Results.sort{$0.GroupName.lowercased() < $1.GroupName.lowercased()}
        for Result in Results
        {
            Result.GroupColors.sort{$0.ColorName < $1.ColorName}
        }
        
        return Results
    }
    
    /// Return a list of sorted color groups. Sorted by color name. (Returned list of pre-defined colors is sorted by
    /// pre-defined color group name.)
    /// - Returns: List of predefined color groups, sorted by color name.
    private static func GetNameSortedColors() -> [PredefinedColorGroup]
    {
        var Results = [PredefinedColorGroup]()
        
        for Color in PredefinedColorTable.Colors
        {
            var Added = false
            let Initial = Color.FirstLetter
            for Result in Results
            {
                if Result.GroupName == Initial
                {
                    Added = true
                    Result.GroupColors.append(Color)
                    continue
                }
            }
            if !Added
            {
                let NewGroup = PredefinedColorGroup()
                NewGroup.GroupName = Initial
                NewGroup.OrderedBy = .Name
                NewGroup.GroupColors.append(Color)
                Results.append(NewGroup)
            }
        }
        Results.sort{$0.GroupName < $1.GroupName}
        for Result in Results
        {
            Result.GroupColors.sort{$0.ColorName < $1.ColorName}
        }
        for Result in Results
        {
            let FirstColorName: String = (Result.GroupColors.first?.ColorName)!
            let LastColorName: String = (Result.GroupColors.last?.ColorName)!
            let SubTitle = "\(FirstColorName) - \(LastColorName)"
            Result.GroupSubTitle = SubTitle
        }
        return Results
    }
    
    /// Return all colors sorted by name. All colors are in one color group in the returned array.
    /// - Returns: Array with one entry with all color names, sorted by primary name.
    private static func GetNameSortedColorsUngrouped() -> [PredefinedColorGroup]
    {
        var Results = [PredefinedColorGroup]()
        let Sole = PredefinedColorGroup()
        
        for Color in PredefinedColorTable.Colors
        {
            Sole.GroupColors.append(Color)
        }
        
        Sole.GroupColors.sort{$0.ColorName < $1.ColorName}
        
        Results.append(Sole)
        return Results
    }
    
    /// Given a color, return the name of the color, if any. If more than one color matches the passed color, the first color
    /// found will have its name returned.
    /// - Parameter Color: The color whose name will be returned.
    /// - Returns: The name of the passed color if found, nil if no name for the passed color is available.
    public static func NameFrom(Color: UIColor) -> String?
    {
        for SomeColor in PredefinedColorTable.Colors
        {
            if SomeColor.SameColor(Color)
            {
                return SomeColor.ColorName
            }
        }
        return nil
    }
    
    /// Return all names for the passed color, if any. If more than on color matches the passed color, the first color
    /// found will be used as the source for the returned names.
    /// - Parameter FindColor: The color whose names will be returned.
    /// - Returns: Array of names for the color. If the returned array is empty, no colors were found that matched the passed
    ///            color. The first name is the primary name and subsquent names are alternative names.
    public static func NamesFrom(FindColor: UIColor) -> [String]
    {
        for Color in PredefinedColorTable.Colors
        {
            if Color.SameColor(FindColor)
            {
                if !Color.AlternativeName.isEmpty
                {
                    return [Color.ColorName, Color.AlternativeName]
                }
                else
                {
                    return [Color.ColorName]
                }
            }
        }
        return [String]()
    }
    
    /// Given a color name, return its color value.
    /// - Parameters:
    ///   - Name: The name of the color. Spaces are relevant. Case sensitive search.
    ///   - SearchAlternativeNames: If true, alternative names are searched as well as the primary name.
    /// - Returns: If found, the color value for the name. If not found, nil is returned.
    public static func ColorFrom(Name: String, SearchAlternativeNames: Bool = true) -> UIColor?
    {
        for Color in PredefinedColorTable.Colors
        {
            if Color.ColorName == Name
            {
                return Color.Color
            }
            if SearchAlternativeNames
            {
                if Color.AlternativeName == Name
                {
                    return Color.Color
                }
            }
        }
        return nil
    }
    
    /// Determines if the passed name exists as a color name (or optionally, an alternative name) in the set of predefined colors.
    /// - Parameters:
    ///   - Name: Name of the color to search for. Spaces are relevant.
    ///   - SearchAlternativeNames: If true, alternative names are searched as well as the primary name.
    ///   - IgnoreAlpha: If true, searching is case insensitive. Otherwise, case is sensitive.
    /// - Returns: True if the passed name exists as a color name (or alternative), false if not.
    public static func ColorNameExists(Name: String, SearchAlternativeNames: Bool = true, IgnoreAlpha: Bool = true) -> Bool
    {
        for Color in PredefinedColorTable.Colors
        {
            if IgnoreAlpha
            {
                if Color.ColorName.caseInsensitiveCompare(Name) == .orderedSame
                {
                    return true
                }
                if SearchAlternativeNames
                {
                    if !Color.AlternativeName.isEmpty
                    {
                        if Color.AlternativeName.caseInsensitiveCompare(Name) == .orderedSame
                        {
                            return true
                        }
                    }
                }
            }
            else
            {
                if Color.ColorName == Name
                {
                    return true
                }
                if SearchAlternativeNames
                {
                    if Color.AlternativeName == Name
                    {
                        return true
                    }
                }
            }
        }
        return false
    }
}

/// Ways to order predefined colors.
public enum ColorOrders
{
    /// Alphabetical by name.
    case Name
    /// Alphabetcial by name but ungrouped.
    case NameList
    /// By hue group.
    case Hue
    /// By brightness level.
    case Brightness
    /// Alphabetical by palette name.
    case Palette
}
