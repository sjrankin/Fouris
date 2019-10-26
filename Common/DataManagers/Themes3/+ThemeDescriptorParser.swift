//
//  +ThemeDescriptorParser.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Code for deserialization/parsing.
extension ThemeDescriptor2
{
    /// Deserialize the passed node.
    /// - Note: The node is from a high level in the XML document - we just traverse the node tree ourself rather than responding to
    ///         individual node traversal events.
    func DeserializedNode(_ Node: XMLNode)
    {
        switch Node.Name
        {
            case "Theme":
                let ThID = XMLNode.GetAttributeNamed("ID", InNode: Node)!
                let ThName = XMLNode.GetAttributeNamed("Name", InNode: Node)!
                let UTheme = XMLNode.GetAttributeNamed("UserTheme", InNode: Node)!
                _ID = UUID(uuidString: ThID)!
                _ThemeName = ThName
                _IsUserTheme = Bool(UTheme)!
                
                for Child in Node.Children
                {
                    switch Child.Name
                    {
                        case "Runtime":
                            let MinVer = XMLNode.GetAttributeNamed("MinimumVersion", InNode: Child)!
                            let MinBld = XMLNode.GetAttributeNamed("MinimumBuild", InNode: Child)!
                            _MinimumVersion = Double(MinVer)!
                            _MinimumBuild = Int(MinBld)!
                        
                        case "Game":
                            let Shape = XMLNode.GetAttributeNamed("BucketShape", InNode: Child)!
                            _BucketShape = BucketShapes(rawValue: Shape)!
                        
                        case "Dates":
                            let CDate = XMLNode.GetAttributeNamed("Created", InNode: Child)!
                            let EDate = XMLNode.GetAttributeNamed("Edited", InNode: Child)!
                            _Created = CDate
                            _Edited = EDate
                        
                        case "Quality":
                            for QChild in Child.Children
                            {
                                switch QChild.Name
                                {
                                    case "Antialiasing":
                                        let AA = XMLNode.GetAttributeNamed("Mode", InNode: QChild)!
                                        _AntialiasingMode = AntialiasingModes(rawValue: AA)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Camera":
                            for CChild in Child.Children
                            {
                                switch CChild.Name
                                {
                                    case "FieldOfView":
                                        let Ang = XMLNode.GetAttributeNamed("Angle", InNode: CChild)!
                                        _CameraFieldOfView = Double(Ang)!
                                    
                                    case "Positions":
                                        let Loc = XMLNode.GetAttributeNamed("Location", InNode: CChild)!
                                        _CameraPosition = SCNVector3.Parse(Loc)!
                                        let Ori = XMLNode.GetAttributeNamed("Orientation", InNode: CChild)!
                                        _CameraOrientation = SCNVector4.Parse(Ori)!
                                    
                                    case "Projection":
                                        let IsOrtho = XMLNode.GetAttributeNamed("IsOrthographic", InNode: CChild)!
                                        _IsOrthographic = Bool(IsOrtho)!
                                        let OrthoScale = XMLNode.GetAttributeNamed("OrthographicScale", InNode: CChild)!
                                        _OrthographicScale = Double(OrthoScale)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Lights":
                            for LChild in Child.Children
                            {
                                switch LChild.Name
                                {
                                    case "DefaultLighting":
                                        let Use = XMLNode.GetAttributeNamed("Use", InNode: LChild)!
                                        _UseDefaultLighting = Bool(Use)!
                                    
                                    case "GameLight":
                                        let LType = XMLNode.GetAttributeNamed("Type", InNode: LChild)!
                                        _LightType = GameLights(rawValue: LType)!
                                        for GLChild in LChild.Children
                                        {
                                            //print("GameLight Child: \(GLChild.Name)")
                                            switch GLChild.Name
                                            {
                                                case "Position":
                                                    let Loc = XMLNode.GetAttributeNamed("Location", InNode: GLChild)!
                                                    _LightPosition = SCNVector3.Parse(Loc)!
                                                
                                                case "Light":
                                                    let LColor = XMLNode.GetAttributeNamed("Color", InNode: GLChild)!
                                                    _LightColor = LColor
                                                    let LInten = XMLNode.GetAttributeNamed("Intensity", InNode: GLChild)!
                                                    _LightIntensity = Double(LInten)!
                                                
                                                default:
                                                    break
                                            }
                                    }
                                    
                                    case "ControlLight":
                                        let LType = XMLNode.GetAttributeNamed("Type", InNode: LChild)!
                                        _ControlLightType = GameLights(rawValue: LType)!
                                        for GLChild in LChild.Children
                                        {
                                            switch GLChild.Name
                                            {
                                                case "Position":
                                                    let Loc = XMLNode.GetAttributeNamed("Location", InNode: GLChild)!
                                                    _ControlLightPosition = SCNVector3.Parse(Loc)!
                                                
                                                case "Light":
                                                    let LColor = XMLNode.GetAttributeNamed("Color", InNode: GLChild)!
                                                    _ControlLightColor = LColor
                                                    let LInten = XMLNode.GetAttributeNamed("Intensity", InNode: GLChild)!
                                                    _ControlLightIntensity = Double(LInten)!
                                                
                                                default:
                                                    break
                                            }
                                    }
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Background":
                            let BGType = XMLNode.GetAttributeNamed("Type", InNode: Child)!
                            _BackgroundType = BackgroundTypes3D(rawValue: BGType)!
                            for BChild in Child.Children
                            {
                                switch BChild.Name
                                {
                                    case "Color":
                                        let BGColor = XMLNode.GetAttributeNamed("Color", InNode: BChild)!
                                        _BackgroundSolidColor = BGColor
                                        let BGColorCycle = XMLNode.GetAttributeNamed("CycleDuration", InNode: BChild)!
                                        _BackgroundSolidColorCycleTime = Double(BGColorCycle)!
                                    
                                    case "Gradient":
                                        let BGGrad = XMLNode.GetAttributeNamed("Definition", InNode: BChild)!
                                        _BackgroundGradientColor = BGGrad
                                        let BGGradCycle = XMLNode.GetAttributeNamed("CycleDuration", InNode: BChild)!
                                        _BackgroundGradientCycleTime = Double(BGGradCycle)!
                                    
                                    case "Image":
                                        let ImgFile = XMLNode.GetAttributeNamed("FileName", InNode: BChild)!
                                        _BackgroundImageName = ImgFile
                                        let FromRoll = XMLNode.GetAttributeNamed("FromCameraRoll", InNode: BChild)!
                                        _BackgroundImageFromCameraRoll = Bool(FromRoll)!
                                    
                                    case "LiveView":
                                        let WhichCamera = XMLNode.GetAttributeNamed("Camera", InNode: BChild)!
                                        _BackgroundLiveImageCamera = CameraLocations(rawValue: WhichCamera)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Bucket":
                            for BChild in Child.Children
                            {
                                switch BChild.Name
                                {
                                    case "Material":
                                        let Spec = XMLNode.GetAttributeNamed("Specular", InNode: BChild)!
                                        _BucketSpecularColor = Spec
                                        let Difs = XMLNode.GetAttributeNamed("Diffuse", InNode: BChild)!
                                        _BucketDiffuseColor = Difs
                                    
                                    case "Grid":
                                        let SGrid = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        _ShowBucketGrid = Bool(SGrid)!
                                        let GColor = XMLNode.GetAttributeNamed("Color", InNode: BChild)!
                                        _BucketGridColor = GColor
                                        let GFade = XMLNode.GetAttributeNamed("Fade", InNode: BChild)!
                                        _FadeBucketGrid = Bool(GFade)!
                                    
                                    case "Outline":
                                        let SGrid = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        _ShowBucketGridOutline = Bool(SGrid)!
                                        let GColor = XMLNode.GetAttributeNamed("Color", InNode: BChild)!
                                        _BucketGridOutlineColor = GColor
                                        let GFade = XMLNode.GetAttributeNamed("Fade", InNode: BChild)!
                                        _FadeBucketOutline = Bool(GFade)!
                                    
                                    case "Rotation":
                                        let EnableR = XMLNode.GetAttributeNamed("Enable", InNode: BChild)!
                                        _RotateBucket = Bool(EnableR)!
                                        let RotateD = XMLNode.GetAttributeNamed("Direction", InNode: BChild)!
                                        _RotatingBucketDirection = BucketRotationTypes(rawValue: RotateD)!
                                        let RotateDur = XMLNode.GetAttributeNamed("Duration", InNode: BChild)!
                                        _RotationDuration = Double(RotateDur)!
                                    
                                    case "Destruction":
                                        let Mth = XMLNode.GetAttributeNamed("Method", InNode: BChild)!
                                        _DestructionMethod = DestructionMethods(rawValue: Mth)!
                                        let DestDur = XMLNode.GetAttributeNamed("Duration", InNode: BChild)!
                                        _DestructionDuration = Double(DestDur)!
                                    
                                    case "GameOver":
                                        let ShowOffS = XMLNode.GetAttributeNamed("ShowOff", InNode: BChild)!
                                        _ShowOffAfterGameOver = Bool(ShowOffS)! 
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Board":
                            for BChild in Child.Children
                            {
                                switch BChild.Name
                                {
                                    case "Show":
                                        let ShowMethod = XMLNode.GetAttributeNamed("Method", InNode: BChild)!
                                        _ShowBoardMethod = ShowBoardMethods(rawValue: ShowMethod)!
                                        let ShowDuration = XMLNode.GetAttributeNamed("Duration", InNode: BChild)!
                                        _ShowBoardDuration = Double(ShowDuration)!
                                    
                                    case "Hide":
                                        let HideMethod = XMLNode.GetAttributeNamed("Method", InNode: BChild)!
                                        _HideBoardMethod = HideBoardMethods(rawValue: HideMethod)!
                                        let HideDuration = XMLNode.GetAttributeNamed("Duration", InNode: BChild)!
                                        _HideBoardDuration = Double(HideDuration)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Buttons":
                            for BChild in Child.Children
                            {
                                switch BChild.Name
                                {
                                    case "AllButtons":
                                        let HideAll = XMLNode.GetAttributeNamed("Hide", InNode: BChild)!
                                        _HideAllButtons = Bool(HideAll)!
                                    
                                    case "UpButton":
                                        let ShowUp = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        _ShowUpButton = Bool(ShowUp)!
                                    
                                    case "FlyAwayButton":
                                        let ShowFly = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        _ShowFlyAwayButton = Bool(ShowFly)!
                                    
                                    case "DropDownButton":
                                        let ShowDrop = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        _ShowDropDownButton = Bool(ShowDrop)!
                                    
                                    case "FreezeButton":
                                        let ShowFreeze = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        _ShowFreezeButton = Bool(ShowFreeze)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Feedback":
                            for FChild in Child.Children
                            {
                                switch FChild.Name
                                {
                                    case "Haptic":
                                        let EnableHaptic = XMLNode.GetAttributeNamed("Enable", InNode: FChild)!
                                        _UseHapticFeedback = Bool(EnableHaptic)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "TextOverlay":
                            for TChild in Child.Children
                            {
                                switch TChild.Name
                                {
                                    case "NextPiece":
                                        let ShowNext = XMLNode.GetAttributeNamed("Show", InNode: TChild)!
                                        let RotateNext = XMLNode.GetAttributeNamed("Rotate", InNode: TChild)!
                                        _ShowNextPiece = Bool(ShowNext)!
                                        _RotateNextPiece = Bool(RotateNext)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "AI":
                            for AChild in Child.Children
                            {
                                switch AChild.Name
                                {
                                    case "Controls":
                                        let ShowAI = XMLNode.GetAttributeNamed("ShowAIActions", InNode: AChild)!
                                        _ShowAIActionsOnControls = Bool(ShowAI)!
                                    
                                    case "SneekPeek":
                                        let PeekCount = XMLNode.GetAttributeNamed("Count", InNode: AChild)!
                                        _AISneakPeakCount = Int(PeekCount)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Timing":
                            for TChild in Child.Children
                            {
                                switch TChild.Name
                                {
                                    case "AfterGameWaitDuration":
                                        let AfterGame = XMLNode.GetAttributeNamed("Seconds", InNode: TChild)!
                                        _AfterGameWaitDuration = Double(AfterGame)!
                                    
                                    case "AutoStartInterval":
                                        let AutoStart = XMLNode.GetAttributeNamed("Seconds", InNode: TChild)!
                                        _AutoStartDuration = Double(AutoStart)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Debug":
                            let DbgEn = XMLNode.GetAttributeNamed("Enable", InNode: Child)!
                            _EnableDebug = Bool(DbgEn)!
                            for DChild in Child.Children
                            {
                                switch DChild.Name
                                {
                                    case "Camera":
                                        let UseCtrl = XMLNode.GetAttributeNamed("UserCanControl", InNode: DChild)!
                                        _CanControlCamera = Bool(UseCtrl)!
                                    
                                    case "Statistics":
                                        let ShowStat = XMLNode.GetAttributeNamed("ShowStatistics", InNode: DChild)!
                                        _ShowStatistics = Bool(ShowStat)!
                                    
                                    case "Heartbeat":
                                        let ShowBeat = XMLNode.GetAttributeNamed("Show", InNode: DChild)!
                                    _ShowHeartbeat = Bool(ShowBeat)! 
                                        let BeatInterval = XMLNode.GetAttributeNamed("Interval", InNode: DChild)!
                                    _HeartbeatInterval = Double(BeatInterval)!
                                    
                                    case "Rotating":
                                        for RChild in DChild.Children
                                        {
                                            switch RChild.Name
                                            {
                                                case "Center":
                                                    let ChangeColors = XMLNode.GetAttributeNamed("ChangeColorAfterRotation", InNode: RChild)!
                                                _ChangeColorAfterRotation = Bool(ChangeColors)!
                                                
                                                default:
                                                break
                                            }
                                    }
                                    
                                    case "GridLines":
                                        for GridChild in DChild.Children
                                        {
                                            switch GridChild.Name
                                            {
                                                case "BackgroundGrid":
                                                    let ShowBGGrid = XMLNode.GetAttributeNamed("Show", InNode: GridChild)!
                                                    _ShowBackgroundGrid = Bool(ShowBGGrid)!
                                                    let BGGridClr = XMLNode.GetAttributeNamed("Color", InNode: GridChild)!
                                                    _BackgroundGridColor = BGGridClr
                                                    let BGGridWidth = XMLNode.GetAttributeNamed("Width", InNode: GridChild)!
                                                    _BackgroundGridWidth = Double(BGGridWidth)!
                                                
                                                case "CenterLines":
                                                    let ShowCtrLines = XMLNode.GetAttributeNamed("Show", InNode: GridChild)!
                                                    _ShowCenterLines = Bool(ShowCtrLines)!
                                                    let CtrLineColor = XMLNode.GetAttributeNamed("Color", InNode: GridChild)!
                                                    _CenterLineColor = CtrLineColor
                                                    let CtrLineWidth = XMLNode.GetAttributeNamed("Width", InNode: GridChild)!
                                                    _CenterLineWidth = Double(CtrLineWidth)!
                                                
                                                default:
                                                    break
                                            }
                                    }
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Pieces":
                            _PieceList.removeAll()
                            for PieceChild in Child.Children
                            {
                                if PieceChild.Name == "Piece"
                                {
                                    let PieceID = XMLNode.GetAttributeNamed("ID", InNode: PieceChild)!
                                    _PieceList.append(UUID(uuidString: PieceID)!)
                                }
                        }
                        
                        default:
                            break
                    }
            }
            
            default:
                break
        }
    }
}
