//
//  ActionButton.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 5/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ActionButton
{
    
}

/// Types of action buttons.
///
/// - SomethingGood: A good action button (meaning, it can help the user stay in the game longer).
/// - SomethingBad: A bad action button (meaning, it's harder for the user to stay in the game).
enum ActionButtonTypes: Int, CaseIterable
{
    case SomethingGood = 0
    case SomethingBad = 1
}

/// Types of good action buttons.
///
/// - StopGravity: Gravity stops temporarily.
/// - Delete1Row: One random row is deleted.
/// - Delete2Rows: Two random rows are deleted.
/// - Delete3Rows: Three random rows are deleted.
/// - DeleteRandomly: Some blocks are randomly deleted.
/// - EmptyBucket: The bucket is emptied.
/// - MakeRoom: Enough room is made for the current piece.
/// - InvisibleBucketWallsRemoved: Any invisible bucket walls are removed.
/// - RemoveAllOfCurrentType: All retired blocks from a peice which is the same as the current piece are removed.
enum GoodButtonTypes: Int, CaseIterable
{
    case StopGravity = 0
    case Delete1Row = 1
    case Delete2Rows = 2
    case Delete3Rows = 3
    case DeleteRandomly = 4
    case EmptyBucket = 5
    case MakeRoom = 6
    case InvisibleBucketWallsRemoved = 7
    case RemoveAllOfCurrentType = 8
}

/// Types of bad action buttons.
///
/// - IncreaseGravity: Gravity is temporarily increased.
/// - AddRandomBucketWalls: Random bucket wall pieces are added.
/// - AddRandomBlocks: Random retired pieces are added.
/// - RemoveMotion: One motion is temporarily removed.
/// - AddInvisibleBucketWalls: Random, invisible bucket walls are added.
/// - RandomGravity: Gravity changes randomly for a short amount of time.
/// - NegativeGravity: Gravity works negatively for a short amount of time.
/// - MirrorImagePiece: The piece is turned into a mirror image (for non-symmetrical pieces).
/// - MutatesPieceShape: The piece's shape is mutated.
/// - RetiredPiecesTurnInvisible: Retired pieces in the bucket turn invisible for a short amount of time.
enum BadButtonTypes: Int, CaseIterable
{
    case IncreaseGravity = 0
    case AddRandomBucketWalls = 1
    case AddRandomBlocks = 2
    case RemoveMotion = 3
    case AddInvisibleBucketWalls = 4
    case RandomGravity = 5
    case NegativeGravity = 6
    case MirrorImagePiece = 7
    case MutatesPieceShape = 8
    case RetiredPiecesTurnInvisible = 9
}
