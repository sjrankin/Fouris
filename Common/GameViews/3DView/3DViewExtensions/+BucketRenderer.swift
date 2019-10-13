//
//  +BucketRenderer.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension View3D
{
    /// Renders an empty board with the specified bucket shape.
    /// - Note:
    ///    - Intended for use only for the `.Rotating4` game type.
    ///    - Intended for use for generating game assets using the graphics engine rather than an external program.
    /// - Parameter WithShape: The shape of the bucket to render.
    /// - Returns: An image of the rendered empty board.
    public func RenderBucket(WithShape: CenterShapes) -> UIImage
    {
        let BView = SCNView(frame: self.frame)
        BView.scene = SCNScene()
        let Light = SCNLight()
        Light.type = .ambient
        Light.color = UIColor.white
        let LightNode = SCNNode()
        LightNode.light = Light
        LightNode.position = SCNVector3(-10.0, 15.0, 40.0)
        BView.scene?.rootNode.addChildNode(LightNode)
        let Camera = SCNCamera()
        Camera.fieldOfView = 92.5
        Camera.usesOrthographicProjection = true
        Camera.orthographicScale = 20.0
        let CameraNode = SCNNode()
        CameraNode.camera = Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 15.0)
        BView.scene?.rootNode.addChildNode(CameraNode)
        BView.scene?.background.contents = ColorServer.ColorFrom(ColorNames.YellowProcess)
        let (Grid, Outline) = DrawGridInBucket(ShowGrid: true, DrawOutline: true, InitialOpacity: 1.0,
                                               LineColorOverride: UIColor.darkGray,
                                               OutlineColorOverride: ColorServer.ColorFrom(ColorNames.ReallyDarkGray))
        let Bucket = CreateBucket(InitialOpacity: 1.0, Shape: WithShape)
        BView.scene?.rootNode.addChildNode(Grid)
        BView.scene?.rootNode.addChildNode(Outline)
        BView.scene?.rootNode.addChildNode(Bucket)
        BView.play(nil)
        let BoardImage = BView.snapshot()
        return BoardImage
    }
    
    /// Renders all buckets for the `.Rotating4` game and returns all images in an array.
    /// - Returns: Array of tuples with the shape and the shape's image.
    public func RenderAllBuckets() -> [(CenterShapes, UIImage)]
    {
        var Results = [(CenterShapes, UIImage)]()
        for Shape in CenterShapes.allCases
        {
            let BucketImage = RenderBucket(WithShape: Shape)
            Results.append((Shape, BucketImage))
        }
        return Results
    }
    
    /// Renders and saves all `.Rotating4` game boards. Images are saved to Fouris' debug directory.
   public func SaveAllBucketImages()
    {
        let AllBuckets = RenderAllBuckets()
        for (Shape, BucketImage) in AllBuckets
        {
            let FileName = "\(Shape).png"
            let _ = FileIO.SaveImageEx(BucketImage, WithName: FileName, InDirectory: FileIO.DebugDirectory, AsJPG: false)
        }
    }
}
