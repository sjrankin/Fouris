//
//  +BoardRemoval.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Extension for board removal and addition.
extension View3D
{
    /// Create nodes for the visual game board.
    func CreateGameBoard()
    {
        CreateBucket()
        CreateGrid()
    }
    
    /// Remove nodes containing the visual game board.
    func RemoveGameBoard()
    {
        BucketNode?.removeFromParentNode()
        BucketNode = nil
        BucketGridNode?.removeFromParentNode()
        BucketGridNode = nil
        OutlineNode?.removeFromParentNode()
        OutlineNode = nil
    }
    
    /// Selects a random enum in `HideBoardMethods` excluding any value in `Exluding`.
    /// - Parameter Excluding: List of value to not return - eg, not in the pool of random values to select.
    /// - Returns: Randomly selected `HideBoardMethods` enum value that is not in `Excluding`.
    func RandomHideMethod(Excluding: [HideBoardMethods]) -> HideBoardMethods
    {
        while true
        {
            let RandomMethod = HideBoardMethods.allCases.randomElement()
            if !Excluding.contains(RandomMethod!)
            {
                return RandomMethod!
            }
        }
    }
    
    /// Hides the board with specified visual effects.
    /// - Note: This function will delete the grid, grid outline, and bucket nodes once the visual transition is finished.
    /// - Parameter Method: The method to use to hide the board. If this value is `.Disappear`, the game board is hidden with no delay.
    /// - Parameter Duration: The amount of time from start to finish of the visual effect to hide
    ///                       the board, in seconds.
    func HideBoard(Method: HideBoardMethods, Duration: Double)
    {
        var HideMethod = Method
        if HideMethod == .Random
        {
            HideMethod = RandomHideMethod(Excluding: [.Random])
        }
        switch HideMethod
        {
            case .Random:
                fallthrough
            case .Disappear:
                RemoveGameBoard()
            
            case .FadeOut:
                let FadeOut = SCNAction.fadeOut(duration: Duration)
                BucketNode?.runAction(FadeOut,
                                      completionHandler:
                    {
                        self.BucketNode?.removeFromParentNode()
                        self.BucketNode = nil
                })
                BucketGridNode?.runAction(FadeOut,
                                          completionHandler:
                    {
                        self.BucketGridNode?.removeFromParentNode()
                        self.BucketGridNode = nil
                })
                OutlineNode?.runAction(FadeOut,
                                       completionHandler:
                    {
                        self.OutlineNode?.removeFromParentNode()
                        self.OutlineNode = nil
                }
            )
            
            case .Grow:
                let FadeOut = SCNAction.fadeOut(duration: Duration)
                let Grow = SCNAction.scale(by: 10.0, duration: Duration)
                let AnimationGroup = SCNAction.group([FadeOut, Grow])
                BucketNode?.runAction(AnimationGroup,
                                      completionHandler:
                    {
                        self.BucketNode?.removeFromParentNode()
                        self.BucketNode = nil
                })
                BucketGridNode?.runAction(AnimationGroup,
                                          completionHandler:
                    {
                        self.BucketGridNode?.removeFromParentNode()
                        self.BucketGridNode = nil
                })
                OutlineNode?.runAction(AnimationGroup,
                                       completionHandler:
                    {
                        self.OutlineNode?.removeFromParentNode()
                        self.OutlineNode = nil
                }
            )
            
            case .Shrink:
                let FadeOut = SCNAction.fadeOut(duration: Duration)
                let Shrink = SCNAction.scale(by: 0.1, duration: Duration)
                let AnimationGroup = SCNAction.group([FadeOut, Shrink])
                BucketNode?.runAction(AnimationGroup,
                                      completionHandler:
                    {
                        self.BucketNode?.removeFromParentNode()
                        self.BucketNode = nil
                })
                BucketGridNode?.runAction(AnimationGroup,
                                          completionHandler:
                    {
                        self.BucketGridNode?.removeFromParentNode()
                        self.BucketGridNode = nil
                })
                OutlineNode?.runAction(AnimationGroup,
                                       completionHandler:
                    {
                        self.OutlineNode?.removeFromParentNode()
                        self.OutlineNode = nil
                }
            )
            
            case .SpinLarger:
                let FadeOut = SCNAction.fadeOut(duration: Duration)
                let Spin = SCNAction.rotateBy(x: 0.0, y: 0.0, z: CGFloat.pi * 360.0 / 180.0, duration: Duration / 5.0)
                let SpinForever = SCNAction.repeatForever(Spin)
                let Grow = SCNAction.scale(by: 10.0, duration: Duration)
                let AnimationGroup = SCNAction.group([FadeOut, Grow, SpinForever])
                BucketNode?.runAction(AnimationGroup,
                                      completionHandler:
                    {
                        self.BucketNode?.removeFromParentNode()
                        self.BucketNode = nil
                })
                BucketGridNode?.runAction(AnimationGroup,
                                          completionHandler:
                    {
                        self.BucketGridNode?.removeFromParentNode()
                        self.BucketGridNode = nil
                })
                OutlineNode?.runAction(AnimationGroup,
                                       completionHandler:
                    {
                        self.OutlineNode?.removeFromParentNode()
                        self.OutlineNode = nil
                }
            )
            
            case .SpinSmaller:
                let FadeOut = SCNAction.fadeOut(duration: Duration)
                let Spin = SCNAction.rotateBy(x: 0.0, y: 0.0, z: CGFloat.pi * 360.0 / 180.0, duration: Duration / 5.0)
                let SpinForever = SCNAction.repeatForever(Spin)
                let Shrink = SCNAction.scale(by: 0.1, duration: Duration)
                let AnimationGroup = SCNAction.group([FadeOut, Shrink, SpinForever])
                BucketNode?.runAction(AnimationGroup,
                                      completionHandler:
                    {
                        self.BucketNode?.removeFromParentNode()
                        self.BucketNode = nil
                })
                BucketGridNode?.runAction(AnimationGroup,
                                          completionHandler:
                    {
                        self.BucketGridNode?.removeFromParentNode()
                        self.BucketGridNode = nil
                })
                OutlineNode?.runAction(AnimationGroup,
                                       completionHandler:
                    {
                        self.OutlineNode?.removeFromParentNode()
                        self.OutlineNode = nil
                }
            )
        }
    }
    
    /// Selects a random enum in `ShowBoardMethods` excluding any value in `Exluding`.
    /// - Parameter Excluding: List of value to not return - eg, not in the pool of random values to select.
    /// - Returns: Randomly selected `ShowBoardMethods` enum value that is not in `Excluding`.
    func RandomShowMethod(Excluding: [ShowBoardMethods]) -> ShowBoardMethods
    {
        while true
        {
            let RandomMethod = ShowBoardMethods.allCases.randomElement()
            if !Excluding.contains(RandomMethod!)
            {
                return RandomMethod!
            }
        }
    }
    
    /// Shows the board with specified visual effects.
    /// - Note: This function will create the grid, grid outline, and bucket nodes before starting the visual transition.
    /// - Parameter Method: The method to use to show the board.
    /// - Parameter Duration: The amount of time from start to finish of the visual effect to show
    ///                       the board, in seconds.
    func ShowBoard(Method: ShowBoardMethods, Duration: Double)
    {
        var ShowMethod = Method
        if ShowMethod == .Random
        {
            ShowMethod = RandomShowMethod(Excluding: [.Random])
        }
        
        CreateGameBoard()
        
        switch ShowMethod
        {
            case .Random:
            fallthrough
            case .Appear:
            CreateGrid()
            
            case .FadeIn:
                let FadeIn = SCNAction.fadeIn(duration: Duration)
                BucketNode?.opacity = 0.0
                BucketNode?.runAction(FadeIn)
                BucketGridNode?.opacity = 0.0
                BucketGridNode?.runAction(FadeIn)
                OutlineNode?.opacity = 0.0
                OutlineNode?.runAction(FadeIn)
            
            case .GrowToView:
                let FadeIn = SCNAction.fadeIn(duration: Duration)
                let Grow = SCNAction.scale(to: 1.0, duration: Duration)
                let Group = SCNAction.group([FadeIn, Grow])
                BucketNode?.opacity = 0.0
                BucketNode?.scale = SCNVector3(0.1, 0.1, 0.1)
                BucketNode?.runAction(Group)
                BucketGridNode?.scale = SCNVector3(0.1, 0.1, 0.1)
                BucketGridNode?.opacity = 0.0
                BucketGridNode?.runAction(Group)
                OutlineNode?.scale = SCNVector3(0.1, 0.1, 0.1)
                OutlineNode?.opacity = 0.0
                OutlineNode?.runAction(Group)
            
            case .ShrinkToView:
                let FadeIn = SCNAction.fadeIn(duration: Duration)
                let Shrink = SCNAction.scale(to: 1.0, duration: Duration)
                let Group = SCNAction.group([FadeIn, Shrink])
                BucketNode?.opacity = 0.0
                BucketNode?.scale = SCNVector3(10.0, 10.0, 10.0)
                BucketNode?.runAction(Group)
                BucketGridNode?.scale = SCNVector3(10.0, 10.0, 10.0)
                BucketGridNode?.opacity = 0.0
                BucketGridNode?.runAction(Group)
                OutlineNode?.scale = SCNVector3(10.0, 10.0, 10.0)
                OutlineNode?.opacity = 0.0
                OutlineNode?.runAction(Group)
            
            case .SpinDown:
                let FadeIn = SCNAction.fadeIn(duration: Duration)
                let Shrink = SCNAction.scale(to: 1.0, duration: Duration)
                let Spin = SCNAction.rotateTo(x: 0.0, y: 0.0, z: CGFloat.pi * 360.0 / 180.0, duration: Duration / 5.0)
                let Group = SCNAction.group([FadeIn, Shrink, Spin])
                BucketNode?.opacity = 0.0
                BucketNode?.scale = SCNVector3(10.0, 10.0, 10.0)
                BucketNode?.runAction(Group)
                BucketGridNode?.scale = SCNVector3(10.0, 10.0, 10.0)
                BucketGridNode?.opacity = 0.0
                BucketGridNode?.runAction(Group)
                OutlineNode?.scale = SCNVector3(10.0, 10.0, 10.0)
                OutlineNode?.opacity = 0.0
                OutlineNode?.runAction(Group)
            
            case .SpinUp:
                let FadeIn = SCNAction.fadeIn(duration: Duration)
                let Grow = SCNAction.scale(to: 1.0, duration: Duration)
                let Spin = SCNAction.rotateTo(x: 0.0, y: 0.0, z: CGFloat.pi * 360.0 / 180.0, duration: Duration / 5.0)
                let Group = SCNAction.group([FadeIn, Grow, Spin])
                BucketNode?.opacity = 0.0
                BucketNode?.scale = SCNVector3(0.1, 0.1, 0.1)
                BucketNode?.runAction(Group)
                BucketGridNode?.scale = SCNVector3(0.1, 0.1, 0.1)
                BucketGridNode?.opacity = 0.0
                BucketGridNode?.runAction(Group)
                OutlineNode?.scale = SCNVector3(0.1, 0.1, 0.1)
                OutlineNode?.opacity = 0.0
                OutlineNode?.runAction(Group)
        }
    }
}

/// Determines the method to hide a board visually.
/// - **Random**: The code will select a method randomly.
/// - **Disappear**: The board will disappear with no effects or transition.
/// - **Shrink**: The board will shrink and fade out.
/// - **FadeOut**: The board will fade out from alpha 1 to alpha 0.
/// - **Grow**: The board will grow to a large size while fading out.
/// - **SpinLarger**: The board will spin in place (around the Z axis) while getting larger and fading out.
/// - **SpinSmaller**: The board will spin in place (around the Z axis) while getting smaller and fading out.
enum HideBoardMethods: String, CaseIterable
{
    case Random = "Random"
    case Disappear = "Disappear"
    case Shrink = "Shrink"
    case FadeOut = "FadeOut"
    case Grow = "Gow"
    case SpinLarger = "SpinLarger"
    case SpinSmaller = "SpinSmaller"
}

/// Determines the method to show a board visually.
/// - **Random**: The code will select a method randomly.
/// - **Appear**: The board will appear with no effects or transition.
/// - **ShrinkToView**: The board will start with a very large size and shink to the normal size.
/// - **GrowToView**: The board will start very small and grow to the normal size.
/// - **FadeIn**: The board will fade in from alpha 0 to alpha 1.
/// - **SpinDown**: The board will start with a large size and spin (rotate on the Z axis) to the final position.
/// - **SpinUp**: The board will start with a very small size and spin (rotate on the Z axis) to the final position.
enum ShowBoardMethods: String, CaseIterable
{
    case Random = "Random"
    case Appear = "Appear"
    case ShrinkToView = "ShrinkToView"
    case GrowToView = "GrowToView"
    case FadeIn = "FadeIn"
    case SpinDown = "SpinDown"
    case SpinUp = "SpinUp"
}
