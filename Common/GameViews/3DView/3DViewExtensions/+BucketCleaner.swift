//
//  +BucketCleaner.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

extension View3D
{
    /// Visually cleans the bucket by removing all retired blocks/pieces.
    /// - Note:
    ///   - Should be called only after the game ends.
    ///   - The list of blocks in **Blocks** is *not* modified.
    ///   - Control is not returned until all blocks' actions have been completed.
    /// - Parameter Method: The visual method to use to remove the blocks.
    /// - Parameter Completion: Completion block.
    func BucketCleaner(_ Method: DestructionMethods, Completion: (() -> ())?)
    {
        let BlockCount = self.BlockList.count
        if BlockCount < 1
        {
            print("Nothing to clean in BucketCleaner.")
            Completion?()
            return
        }
        
        var Completed = 0
        switch Method
        {
            case .None:
                //Regardless of the number of blocks in the block list, do nothing other
                //than call the completion block then return.
                Completion?()
                return
            
            case .Drop:
                break
            
            case .Explode:
                break
            
            case .ExplodingBlocks:
                break
            
            case .FadeAway:
                for Block in self.BlockList
                {
                    OperationQueue.main.addOperation
                        {
                            #if false
                            Block.removeAllActions()
                            let FadeOut = SCNAction.fadeOut(duration: Double.random(in: 0.25 ... 1.25))
                            //let Remove = SCNAction.removeFromParentNode()
                            //let AnimationGroup = SCNAction.group([FadeOut, Remove])
                            //Block.runAction(AnimationGroup, completionHandler:
                            Block.runAction(FadeOut, completionHandler:
                                {
                                    Completed = Completed + 1
                                    if Completed == BlockCount
                                    {
                                        Completion?()
                                    }
                            })
                            #else
                            UIView.animate(withDuration: Double.random(in: 0.25 ... 1.0), animations:
                                {
                                    Block.opacity = 0.0
                            }, completion:
                                {
                                    _ in
                                    Block.opacity = 0.0
                                    Completed = Completed + 1
                                    if Completed == BlockCount
                                    {
                                        Completion?()
                                    }
                            })
                            #endif
                    }
            }
            
            case .Shrink:
                for Block in self.BlockList
                {
                    #if false
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute:
                        {
                            Block.removeAllActions()
                            let Scale = SCNAction.scale(to: 0.0, duration: Double.random(in: 0.25 ... 1.25))
                            Block.runAction(Scale, completionHandler:
                                {
                                    Completed = Completed + 1
                                    if Completed == BlockCount
                                    {
                                        Completion?()
                                    }
                            })
                    })
                    #else
                    OperationQueue.main.addOperation
                        {
                            UIView.animate(withDuration: Double.random(in: 0.25 ... 1.0), animations:
                                {
                                    Block.scale = SCNVector3(0.0, 0.0, 0.0)
                                    Block.opacity = 0.0
                            }, completion:
                                {
                                           _ in
                                Completed = Completed + 1
                                if Completed == BlockCount
                                {
                                Completion?()
                                }
                            }
                                )
                    }
                    #endif
            }
            
            case .SpinDown:
                for Block in self.BlockList
                {
                    OperationQueue.main.addOperation
                        {
                            let AnimationDuration = Double.random(in: 0.25 ... 1.0)
                            let SpinAction = SCNAction.rotateBy(x: 1.0, y: 1.0, z: 1.0, duration: AnimationDuration)
                            let ShrinkAction = SCNAction.scale(to: 0.01, duration: AnimationDuration)
                            let ActionGroup = SCNAction.group([SpinAction, ShrinkAction])
                            Block.runAction(ActionGroup, completionHandler:
                                {
                                    Block.opacity = 0.0
                                    Completed = Completed + 1
                                    if Completed == BlockCount
                                    {
                                        Completion?()
                                    }
                            }
                            )
                    }
            }
            
            case .Scatter:
                break
            
            case .ScatterRadially:
                break
            
            case .ScatterHorizontally:
                break
            
            case .ScatterVertially:
                break
            
            case .FlyFromSides:
                //Valid only for .Rotating4 games. If called for a non-.Rotating4 game,
                //this case is treated the same as .None.
                if BaseGameType == .Rotating4
                {
                    
                }
                else
                {
                    //We're not a .Rotating4 game so just call the completion block and return.
                    Completion?()
                    return
            }
        }
    }
}
