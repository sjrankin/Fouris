//
//  ConstrainedQueue.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/15/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements a simple generic queue with a limit on the number of items that can be stored.
/// - Note: When more items are inserted into the queue than it can hold, the oldest items are removed and discarded.
class ConstrainedQueue<T>
{
    /// Initializer.
    /// - Note: Sets the `ConstraintSize` to `1000`.
    init()
    {
        _ConstraintSize = 1000
        Q = [T]()
    }
    
    /// Initializer.
    /// - Parameter MaximumSize: The maximum number of items the queue can hold.
    init(MaximumSize: Int)
    {
        _ConstraintSize = MaximumSize
        Q = [T]()
    }
    
    /// Initializer.
    /// - Parameter Other: The other queue to use to populate this instance. Th other queue's `ConstraintSize` is used to
    ///                    set this instance's `ConstraintSize`.
    init(_ Other: ConstrainedQueue<T>)
    {
        _ConstraintSize = Other.ConstraintSize
        Q = [T]()
        let OtherItems = Other.AsArray()
        for SomeItem in OtherItems
        {
            Enqueue(SomeItem)
        }
    }
    
    /// Holds the maximum number of items.
    private var _ConstraintSize: Int = 1000
    {
        didSet
        {
            while Q!.count > _ConstraintSize
            {
                let _ = Dequeue()
            }
        }
    }
    /// Get or set the maximum number of items. If the caller sets this value small than the number of items
    /// in the current queue, the excess will be discarded. Setting this value to a larger number than the number
    /// of items in the queue will have no immediate effect.
    /// - Note: Default value is 1000 items.
    public var ConstraintSize: Int
    {
        get
        {
            return _ConstraintSize
        }
        set
        {
            _ConstraintSize = newValue
        }
    }
    
    /// Holds the queue's data.
    private var Q: [T]? = nil
    
    /// Clear the contents of the queue.
    public func Clear()
    {
        Q?.removeAll()
    }
    
    /// Returns the number of items in the queue.
    public var Count: Int
    {
        get
        {
            return Q!.count
        }
    }
    
    /// Returns true if the queue is empty, false if not.
    public var IsEmpty: Bool
    {
        get
        {
            return Q!.count == 0
        }
    }
    
    /// Enqueue the passed item. If enqueuing the item results in more items than is specified in `ConstraintSize`, the
    /// oldest item will be dequeued and discarded.
    public func Enqueue(_ Item: T)
    {
        if Q?.count == ConstraintSize
        {
            let _ = Dequeue()
        }
        Q?.append(Item)
    }
    
    /// Dequeue the oldest item in the queue. Nil returned if the queue is empty.
    public func Dequeue() -> T?
    {
        if Q!.count < 1
        {
            return nil
        }
        let First = Q?.first
        Q?.removeFirst()
        return First
    }
    
    /// Peek at the top of the queue (the most recent entry).
    /// - Returns: A copy of the top of the queue. Nil if no items are in the queue.
    public func PeekTop() -> T?
    {
        if Q!.count < 1
        {
            return nil
        }
        return Q?.first
    }
    
    /// Peek at the bottom of the queue (the earliest entry).
    /// - Returns: A copy of the bottom of the queue. Nil if no items are in the queue.
    public func PeekBottom() -> T?
    {
        if Q!.count < 1
        {
            return nil
        }
        return Q?.last
    }
    
    /// Read the queue at the specified index. Nil return if the queue is empty or the value of `Index` is
    /// out of bounds.
    subscript(Index: Int) -> T?
    {
        get
        {
            if Count < 1
            {
                return nil
            }
            if Index < 0
            {
                return nil
            }
            if Index > Count - 1
            {
                return nil
            }
            return Q?[Index]
        }
    }
    
    /// Return the contents of the queue as an array.
    /// - Returns: Contents of the queue as an array.
    public func AsArray() -> [T]
    {
        var Results = [T]()
        for SomeT in Q!
        {
            Results.append(SomeT)
        }
        return Results
    }
}
