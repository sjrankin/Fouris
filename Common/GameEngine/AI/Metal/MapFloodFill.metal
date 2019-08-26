//
//  MapFloodFill.metal
//  Fouris
//
//  Created by Stuart Rankin on 5/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/// Flood fill parameters partially populated by the calling swift code. The caller is required to allocate
/// enough space in `XStack` and `YStack` for the size of the "image." This is how the non-recursive flood
/// fill algorithm can work here - by having our own, sneaky stack (for which we also have to provide push
/// and pop operations).
struct FloodFillParameters
{
    /// The occupied color.
    float4 OccupiedValue;
    /// The unoccupied color.
    float4 UnoccupiedValue;
    /// The unreachable color.
    float4 UnreachableValue;
    /// The X coordinate stack.
    device int *XStack;
    /// The Y coordinate stack.
    device int *YStack;
    /// The "stack pointer" index.
    int StackPointer;
    /// Stack count value.
    int Count;
};

/// Pop the contents of the stack, combining the two values into one integer value. The X value is multiplied by 100000 and added
/// the the Y value, then returned.
int Pop(FloodFillParameters device *StackData)
{
    int PopX = StackData->XStack[StackData->StackPointer];
    int PopY = StackData->YStack[StackData->StackPointer];
    int Result = (PopX * 100000) + PopY;
    StackData->StackPointer = StackData->StackPointer - 1;
    StackData->Count = StackData->Count - 1;
    if (StackData->StackPointer < 0)
        {
        StackData->StackPointer = 0;
        }
    if (StackData->Count < 0)
        {
        StackData->Count = 0;
        }
    return Result;
}

/// Push the passed S and Y values onto the "stack" (two stacks, actually, one for each value).
void Push(int X, int Y, FloodFillParameters device *StackData)
{
    StackData->StackPointer = StackData->StackPointer + 1;
    StackData->XStack[StackData->StackPointer] = X;
    StackData->YStack[StackData->StackPointer] = Y;
    StackData->Count = StackData->Count + 1;
}

/// Perform a non-recursive (because Metal C++ doesn't do memory operations) flood fill operation on the passed image. The image
/// should consist of colors (specified in `FloodFillDelta`) that indicate if a given location in the game map is empty or occupied.
kernel void MetalFloodFill(texture2d<float, access::read> InMap [[texture(0)]],
                           texture2d<float, access::write> OutMap [[texture(1)]],
                           device FloodFillParameters &FloodFillData [[buffer(0)]],
                           device float *Output [[buffer(1)]],
                           uint2 gid [[thread_position_in_grid]])
{
    int Height = InMap.get_height();
    int Width = InMap.get_width();
    FloodFillData.StackPointer = 0;
    FloodFillData.Count = 0;
    gid.x = 0;
    gid.y = 0;
    Push(0, 0, &FloodFillData);
    
    for (int Y = 0; Y < Height; Y++)
        {
        for (int X = 0; X < Width; X++)
            {
            gid.x = X;
            gid.y = Y;
            float4 InVal = InMap.read(gid);
            if (InVal.r == FloodFillData.OccupiedValue.r && InVal.g == FloodFillData.OccupiedValue.g && InVal.b == FloodFillData.OccupiedValue.b)
                {
                OutMap.write(FloodFillData.OccupiedValue, gid);
                }
            else
                {
                OutMap.write(FloodFillData.UnoccupiedValue, gid);
                }
            }
        }
    
    while (FloodFillData.Count > 0)
        {
        int XVal = 0;
        int YVal = 0;
        int Raw = Pop(&FloodFillData);
        YVal = Raw % 100000;
        XVal = Raw / 100000;
        if (YVal < 0 || YVal > Height - 1 || XVal < 0 || XVal > Width - 1)
            {
            continue;
            }
        gid.x = XVal;
        gid.y = YVal;
        float4 InVal = InMap.read(gid);
        if (InVal.r == FloodFillData.UnoccupiedValue.r && InVal.g == FloodFillData.UnoccupiedValue.g && InVal.b == FloodFillData.UnoccupiedValue.b)
            {
            OutMap.write(FloodFillData.UnreachableValue, gid);
            Push(XVal + 1, YVal, &FloodFillData);
            Push(XVal - 1, YVal, &FloodFillData);
            Push(XVal, YVal + 1, &FloodFillData);
            Push(XVal, YVal - 1, &FloodFillData);
            }
        }
}
