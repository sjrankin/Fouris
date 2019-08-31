//
//  GSlider.swift
//  Fouris
//  Adapted from BumpCamera.
//
//  Created by Stuart Rankin on 3/2/19. Adapted for use in Fouris on 8/30/2019.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// This class is the first version implementation of a gradient-backed slider control that allows
/// vertical as well as horizontal orientations.
@IBDesignable class GSlider: UIControl
{
    /// Initializer.
    ///
    /// - Parameter frame: See iOS documentation.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        LocalInit()
    }
    
    /// Initializer.
    ///
    /// - Parameter aDecoder: See iOS documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        LocalInit()
    }
    
    /// Delegate to the control owner to notify the owner of value changes.
    weak var ParentDelegate: GSliderProtocol? = nil
    
    /// Local initialization.
    func LocalInit()
    {
        clipsToBounds = true
        self.isUserInteractionEnabled = true
        UpdateGradient()
        DrawIndicator()
        UpdateBorder()
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleTapped))
        addGestureRecognizer(Tap)
    }
    
    var TouchStartPoint: CGPoint? = nil
    var TouchMovePoint: CGPoint? = nil
    var TouchEndPoint: CGPoint? = nil
    
    private var _UsesStopList: Bool = false
    {
        didSet
        {
            UpdateGradient()
            DrawIndicator()
            UpdateBorder()
        }
    }
    /// Set to true to use a stop list. A stop list determines where the indicator stops
    /// after being moved - the indicator will always snap to the closest stop list value.
    /// This is how you can use GSlider for descrete, not continuous, values. Setting this
    /// flag takes effect immediately if `StopList` has been defined.
    @IBInspectable public var UsesStopList: Bool
        {
        get
        {
            return _UsesStopList
        }
        set
        {
            _UsesStopList = newValue
        }
    }
    
    private var _StopList: [Double] = [Double]()
    {
        didSet
        {
            UpdateGradient()
            DrawIndicator()
            UpdateBorder()
        }
    }
    /// Get or set the stop list. Setting this value when `UseStopList` is false has no immediate
    /// effect. When `UserStopList` is enabled, the change will take effect immediately. Values in
    /// the passed list are sorted before use. Values that are out of the range of `MinValue` -
    /// `MaxValue` are removed. The initial stop list is empty.
    @IBInspectable public var StopList: [Double]
        {
        get
        {
            return _StopList
        }
        set
        {
            var Scratch = newValue
            Scratch.sort{$0 < $1}
            Scratch.removeAll(where: {$0 < MinValue || $0 > MaxValue})
            _StopList = Scratch
        }
    }
    
    private var _BackgroundTracksIndicator: Bool = false
    {
        didSet
        {
            UpdateGradient()
            DrawIndicator()
            UpdateBorder()
        }
    }
    /// If you set this property to true, the background tracks the indicator. This way,
    /// you can use two colors to show the background. Takes effect immediately.
    @IBInspectable public var BackgroundTracksIndicator: Bool
        {
        get
        {
            return _BackgroundTracksIndicator
        }
        set
        {
            _BackgroundTracksIndicator = newValue
        }
    }
    
    private var _LowBackgroundColor: UIColor = UIColor.black
    {
        didSet
        {
            UpdateGradient()
            DrawIndicator()
            UpdateBorder()
        }
    }
    /// Get or set the background color to use when `BackgroundTracksIndicator` is true
    /// for the background portion between `MinValue` and `Value`. Takes effect immediately.
    /// Ignored if `BackgroundTracksIndicator` is false.
    @IBInspectable public var LowBackgroundColor: UIColor
        {
        get
        {
            return _LowBackgroundColor
        }
        set
        {
            _LowBackgroundColor = newValue
        }
    }
    
    private var _HighBackgroundColor: UIColor = UIColor.white
    {
        didSet
        {
            UpdateGradient()
            DrawIndicator()
            UpdateBorder()
        }
    }
    /// Get or set the background color to use when `BackgroundTracksIndicator` is true
    /// for the background portion between `Value` and `MaxValue`. Takes effect immediately.
    /// Ignored if `BackgroundTracksIndicator` is false.
    @IBInspectable public var HighBackgroundColor: UIColor
        {
        get
        {
            return _HighBackgroundColor
        }
        set
        {
            _HighBackgroundColor = newValue
        }
    }
    
    func IsValidPoint(_ Point: CGPoint) -> Bool
    {
        if IsHorizontal
        {
            if Point.x < 0.0 || Point.x > frame.width
            {
                return false
            }
            else
            {
                return true
            }
        }
        else
        {
            if Point.y < 0.0 || Point.y > frame.height
            {
                return false
            }
            else
            {
                return true
            }
        }
    }
    
    func ValidateLocation(_ Point: CGPoint) -> CGPoint
    {
        if IsHorizontal
        {
            if Point.x <= 0.0
            {
                return CGPoint(x: 0.0, y: Point.y)
            }
            if Point.x >= frame.width
            {
                return CGPoint(x: frame.width, y: Point.y)
            }
            return Point
        }
        else
        {
            if Point.y <= 0.0
            {
                return CGPoint(x: Point.x, y: 0.0)
            }
            if Point.y >= frame.height
            {
                return CGPoint(x: Point.x, y: frame.height)
            }
            return Point
        }
    }
    
    //https://www.techotopia.com/index.php/Detecting_iOS_8_Touch_Screen_Gesture_Motions_in_Swift
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let Touch = touches.first
        {
            TouchStartPoint = Touch.location(in: self)
            HandleMoved(ToWhere: TouchStartPoint!)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let Touch = touches.first
        {
            TouchMovePoint = Touch.location(in: self)
            HandleMoved(ToWhere: TouchMovePoint!)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let Touch = touches.first
        {
            TouchEndPoint = Touch.location(in: self)
            HandleMoved(ToWhere: TouchEndPoint!)
        }
    }
    
    func HandleMoved(ToWhere: CGPoint)
    {
        let Validated = ValidateLocation(ToWhere)
        let Percent = PercentFromLocation(Location: Validated)
        let Range = MaxValue - MinValue
        print("**** HandleMoved")
        print("Value=(Range[\(Range)] * Percent[\(Percent)]) + MinValue[\(MinValue)]")
        Value = (Range * Percent) + MinValue
        //DrawIndicator()
        ParentDelegate?.NewSliderValue(Name: Name, NewValue: Value)
    }
    
    override func draw(_ rect: CGRect)
    {
        guard let _ = UIGraphicsGetCurrentContext() else
        {
            return
        }
        UpdateGradient()
        DrawIndicator()
        UpdateBorder()
    }
    
    /// Handle taps on the slider. The value is recalculated and the indicator is moved as
    /// appropriate. The parent of the control is notified.
    ///
    /// - Parameter TapGesture: The tap gesture that describes the tap.
    @objc func HandleTapped(TapGesture: UITapGestureRecognizer)
    {
        let Where = TapGesture.location(in: self)
        let Percent = PercentFromLocation(Location: Where)
        print("Tapped in \(Name) at \(Where), Percent=\(Percent)")
        let Range = MaxValue - MinValue
        Value = (Range * Percent) + MinValue
        DrawIndicator()
        if TapGesture.state == .ended
        {
            ParentDelegate?.NewSliderValue(Name: Name, NewValue: Value)
        }
    }
    
    /// Calculates the percent location (depending on the orientation) of the tap in the control.
    ///
    /// - Parameter Location: Location to calculate the percentage from.
    /// - Returns: Percent along the long axis of the control where the tap was. (The long axis is
    ///            defined by the IsHorizontal property regardless of the actual geometry of the
    ///            control.)
    func PercentFromLocation(Location: CGPoint) -> Double
    {
        if IsHorizontal
        {
            let Width = self.frame.width
            let Adjusted = Width - Location.x
            let WPercent = Adjusted / Width
            return Double(1.0 - WPercent)
        }
        else
        {
            let Height = self.frame.height
            let Adjusted = Height - Location.y
            let HPercent = Adjusted / Height
            return Double(1.0 - HPercent)
        }
    }
    
    /// Refresh the layout of the control. This function must be called by the parent's viewDidLayoutSubviews
    /// code in order for gradients to properly fill the control. This is because UIView events are not as
    /// extensive as a UIViewController and the event that fires to tell the UIView to draw may come before it
    /// is fully laid out, meaning things don't fit the final geometry.
    ///
    /// - Parameters:
    ///   - SliderName: Name of the slider to refresh. Debug use only.
    ///   - WithRect: The rectangle to use to draw the control.
    func Refresh(SliderName: String, WithRect: CGRect)
    {
        NewFrame = WithRect
        UpdateGradient()
        DrawIndicator()
    }
    
    /// Used to store the refrehed geometry.
    var NewFrame = CGRect.zero
    
    /// Update the border of the control. Called when a public attribute changes.
    func UpdateBorder()
    {
        if DrawBorder
        {
            self.layer.borderColor = _BorderColor.cgColor
            self.layer.borderWidth = 0.5
            if RoundCorneredBorders
            {
                self.layer.cornerRadius = 5.0
            }
            else
            {
                self.layer.cornerRadius = 0.0
            }
        }
        else
        {
            self.layer.borderWidth = 0.0
        }
    }
    
    /// Holds the color to use to draw the outline of the indicator. Setting this value updates
    /// the UI immediately.
    private var _IndicatorStrokeColor: UIColor = UIColor.yellow
    {
        didSet
        {
            DrawIndicator()
        }
    }
    /// Get or set the color to use to draw the stroke (outline) of the indicator.
    @IBInspectable public var IndicatorStrokeColor: UIColor
        {
        get
        {
            return _IndicatorStrokeColor
        }
        set
        {
            _IndicatorStrokeColor = newValue
        }
    }
    
    /// Holds the color to use to draw the interior of the indicator. Setting this value updates
    /// the UI immediately.
    private var _IndicatorFillColor: UIColor = UIColor.black
    {
        didSet
        {
            DrawIndicator()
        }
    }
    /// Get or set the color to use to draw the interior (fill) of the indicator.
    @IBInspectable public var IndicatorFillColor: UIColor
        {
        get
        {
            return _IndicatorFillColor
        }
        set
        {
            _IndicatorFillColor = newValue
        }
    }
    
    /// Holds the value that determines if the border of the control is rounded. Updates the border
    /// when set.
    private var _RoundCorneredBorders: Bool = true
    {
        didSet
        {
            UpdateBorder()
        }
    }
    /// Get or set the value that determines whether the border of the control has rounded
    /// corners. Setting this value causes an immediate visual update (if DrawBorder is true).
    @IBInspectable var RoundCorneredBorders: Bool
        {
        get
        {
            return _RoundCorneredBorders
        }
        set
        {
            _RoundCorneredBorders = newValue
        }
    }
    
    /// Holds the value that determines whether borders are drawn around the control or not. Updates
    /// the border when set.
    private var _DrawBorder: Bool = true
    {
        didSet
        {
            UpdateBorder()
        }
    }
    /// Get or set the border is visible flag. Setting this value causes an immediate visual upate.
    @IBInspectable var DrawBorder: Bool
        {
        get
        {
            return _DrawBorder
        }
        set
        {
            _DrawBorder = newValue
        }
    }
    
    /// Holds the color of the border. Updates the border when set.
    private var _BorderColor: UIColor = UIColor.black
    {
        didSet
        {
            UpdateBorder()
        }
    }
    /// Get or set the color used to paint the border. Setting this value causes an immediate visual
    /// update (if DrawBorder is true).
    @IBInspectable var BorderColor: UIColor
        {
        get
        {
            return _BorderColor
        }
        set
        {
            _BorderColor = newValue
        }
    }
    
    /// Holds the flag that shows or hides shadows. Shadow state is changed when set.
    private var _ShowShadows: Bool = true
    {
        didSet
        {
            DrawIndicator()
        }
    }
    /// Get or set the flag that tells the control to show or hide shadows under the indicator.
    /// Setting this value causes an immediate visual update.
    @IBInspectable var ShowShadows: Bool
        {
        get
        {
            return _ShowShadows
        }
        set
        {
            _ShowShadows = newValue
        }
    }
    
    /// Holds the value that determines which axis is the varying axis. Updates the gradient and indicator
    /// when set.
    private var _IsHorizontal: Bool = true
    {
        didSet
        {
            UpdateGradient()
            DrawIndicator()
        }
    }
    /// Get or set the value that indicates if the long axis is the horizontal axis. If false, the vertical axis
    /// is used instead. The visual geometry of the control has no bearing on this value or how Value is calculated
    /// or reported. Setting this value causes an immediate visual update.
    @IBInspectable var IsHorizontal: Bool
        {
        get
        {
            return _IsHorizontal
        }
        set
        {
            _IsHorizontal = newValue
        }
    }
    
    /// Holds the use hue gradient flag. Updates the control gradient when set.
    private var _UseHueGradient: Bool = false
    {
        didSet
        {
            UpdateGradient()
        }
    }
    /// Get or set the flag that determines if the hue gradient is used. Setting this property causes an immediate visual update.
    @IBInspectable var UseHueGradient: Bool
        {
        get
        {
            return _UseHueGradient
        }
        set
        {
            _UseHueGradient = newValue
        }
    }
    
    func SetHueGradient(InitialSaturation: CGFloat = 1.0, InitialBrightness: CGFloat = 1.0, Steps: Int = 36)
    {
        HueColors.removeAll()
        var ColorAngle: CGFloat = 0.0
        let StepCount = 360 / Steps
        for Angle in stride(from: 0, to: 361, by: StepCount)
        {
            ColorAngle = ColorAngle + (CGFloat(Angle) / 360.0)
            let ColorStop = UIColor(hue: ColorAngle, saturation: InitialSaturation, brightness: InitialBrightness, alpha: 1.0)
            HueColors.append(ColorStop as Any)
        }
        UpdateGradient()
    }
    
    var HueColors = [Any]()
    
    func UpdateHueGradient(Saturation: CGFloat, Brightness: CGFloat)
    {
        for Index in 0 ..< HueColors.count
        {
            if let Color = HueColors[Index] as? UIColor
            {
                let NewColor = UIColor(hue: Color.Hue, saturation: Saturation, brightness: Brightness, alpha: 1.0)
                HueColors[Index] = NewColor as Any
            }
        }
        UpdateGradient()
    }
    
    /// Holds the flag that indicates whether to use the start gradient color as a solid color
    /// instead of a gradient. Takes effect immediately.
    private var _UseStartAsSolidColor: Bool = false
    {
        didSet
        {
            UpdateGradient()
        }
    }
    /// Get or set the flag that indicates the start gradient color as a solid color instead a
    /// gradient color. Setting this value causes an immediate visual update.
    @IBInspectable var UseStartAsSolidColor: Bool
        {
        get
        {
            return _UseStartAsSolidColor
        }
        set
        {
            _UseStartAsSolidColor = newValue
        }
    }
    
    /// Holds the initial gradient color. Updates the control gradient when set.
    private var _GradientStart: UIColor = UIColor.white
    {
        didSet
        {
            UpdateGradient()
        }
    }
    /// Get or set the initial gradient color. Setting this value causes an immediate visual update.
    @IBInspectable var GradientStart: UIColor
        {
        get
        {
            return _GradientStart
        }
        set
        {
            _GradientStart = newValue
        }
    }
    
    /// Holds the final gradient color. Updates the control gradient when set.
    private var _GradientEnd: UIColor = UIColor.black
    {
        didSet
        {
            UpdateGradient()
        }
    }
    /// Get or set the final gradient color. Setting this value causes an immediate visual update.
    @IBInspectable var GradientEnd: UIColor
        {
        get
        {
            return _GradientEnd
        }
        set
        {
            _GradientEnd = newValue
        }
    }
    
    private var _EnableRangedValues: Bool = false
    {
        didSet
        {
            DrawIndicator()
        }
    }
    /// Enables the ranged values mode. In this mode, there are two indicators and the
    /// range is the "value" rather than any indicator. In the range values mode, there
    /// are two indicators, one for the low end of the range and one for the high end of
    /// the range.
    @IBInspectable var EnableRangedValues: Bool
        {
        get
        {
            return _EnableRangedValues
        }
        set
        {
            _EnableRangedValues = newValue
        }
    }
    
    private var _Range: (Double, Double) = (0.0, 1.0)
    {
        didSet
        {
            DrawIndicator()
        }
    }
    /// Get or set the range. Valid only when `EnableRangedValues` is true.
    var Range: (Double, Double)
    {
        get
        {
            return _Range
        }
        set
        {
            _Range = newValue
        }
    }
    
    private var _RangeLow: Double = 0.0
    {
        didSet
        {
            let (_, OldHigh) = _Range
            Range = (_RangeLow, OldHigh)
        }
    }
    /// Get or set the low range value. Valid only when `EnableRangedValue` is true.
    /// Provided for the Interface Builder, which doesn't support tuples.
    @IBInspectable var RangeLow: Double
        {
        get
        {
            return _RangeLow
        }
        set
        {
            _RangeLow = newValue
        }
    }
    
    private var _RangeHigh: Double = 0.0
    {
        didSet
        {
            let (OldLow, _) = _Range
            Range = (OldLow, _RangeHigh)
        }
    }
    /// Get or set the high range value. Valid only when `EnableRangedValue` is true.
    /// Provided for the Interface Builder, which doesn't support tuples.
    @IBInspectable var RangeHigh: Double
        {
        get
        {
            return _RangeHigh
        }
        set
        {
            _RangeHigh = newValue
        }
    }
    
    /// Holds the current value of the control.
    private var _Value: Double = 0.0
    /// Get or set the value of the control. Setting this property causes an immediate visual update.
    @IBInspectable var Value: Double
        {
        get
        {
            return _Value
        }
        set
        {
            if InRange(newValue)
            {
                let ClampedValue = newValue.Clamp(0.0, 1.0)
                if ClampedValue == _Value
                {
                    print("Ignoring same value set \(ClampedValue) for \(Name)")
                    return
                }
                _Value = ClampedValue
                DrawIndicator()
            }
        }
    }
    
    /// Determines if the passed value is within the current property range (MinValue and MaxValue).
    ///
    /// - Parameter SomeValue: The value to test against MinValue and MaxValue.
    /// - Returns: True if SomeValue is in the MinValue:MaxValue range, false if not.
    func InRange(_ SomeValue: Double) -> Bool
    {
        if SomeValue < _MinValue || SomeValue > _MaxValue
        {
            return false
        }
        return true
    }
    
    /// Holds the minimum valid value. Setting this value will update the indicator.
    var _MinValue: Double = 0.0
    {
        didSet
        {
            DrawIndicator()
        }
    }
    /// Get or set the minimum valid value for the control. Setting this property will cause an
    /// immediate visual update.
    @IBInspectable var MinValue: Double
        {
        get
        {
            return _MinValue
        }
        set
        {
            if newValue > _MaxValue
            {
                return
            }
            if _Value < newValue
            {
                _Value = newValue
            }
            _MinValue = newValue
        }
    }
    
    /// Holds the maximum valid value. Setting this value will update the indicator.
    var _MaxValue: Double = 1.0
    {
        didSet
        {
            DrawIndicator()
        }
    }
    /// Get or set the maximum valid value for the control. Setting this property will cause an
    /// immediate visual update.
    @IBInspectable var MaxValue: Double
        {
        get
        {
            return _MaxValue
        }
        set
        {
            if newValue < _MinValue
            {
                return
            }
            if _Value > _MaxValue
            {
                _Value = newValue
            }
            _MaxValue = newValue
        }
    }
    
    /// Holds the name of the control.
    var _Name: String = ""
    /// Get or set the name of the control. No functional action taken by setting this property.
    @IBInspectable var Name: String
        {
        get
        {
            return _Name
        }
        set
        {
            _Name = newValue
        }
    }
    
    /// Draw the indicator showing the value in the control using previously set properties.
    func DrawIndicator()
    {
        print("At DrawIndicator for \(Name), Value=\(Value)")
        if Name == "Red"
        {
            print(Thread.callStackSymbols.filter({$0.contains("Fouris")}).forEach{print($0)})
        }
        if IndicatorLevel == nil
        {
            IndicatorLevel = CAShapeLayer()
            IndicatorLevel?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            IndicatorLevel?.bounds = self.bounds
            IndicatorLevel?.name = "indicator"
            IndicatorLevel?.zPosition = 501
            self.layer.addSublayer(IndicatorLevel!)
        }
        else
        {
            IndicatorLevel?.frame = CGRect(x: 0, y: 0, width: NewFrame.width, height: NewFrame.height)
        }
        IndicatorLevel?.strokeColor = IndicatorStrokeColor.cgColor
        IndicatorLevel?.fillColor = IndicatorFillColor.cgColor
        IndicatorLevel?.lineWidth = 2.0
        let Indicator = UIBezierPath()
        if IsHorizontal
        {
            let Range = MaxValue - MinValue
            let Percent = (Value + MinValue) / Range
            let XPoint = self.frame.width * CGFloat(Percent)
            if Name == "Red"
            {
            print("Range[\(Range)]=MaxValue[\(MaxValue)]-MinValue[\(MinValue)]")
            print("Percent[\(Percent)]=Value[\(Value)]/Range[\(Range)]")
            print("DrawHIndicator(\(Name)) = \(Percent.Round(To: 3))")
            }
            Indicator.move(to: CGPoint(x: XPoint, y: self.frame.height / 2.0))
            Indicator.addLine(to: CGPoint(x: XPoint - 8, y: self.frame.height - 2))
            Indicator.addLine(to: CGPoint(x: XPoint + 8, y: self.frame.height - 2))
            Indicator.addLine(to: CGPoint(x: XPoint, y: self.frame.height / 2.0))
        }
        else
        {
            let Range = MaxValue - MinValue
            let Percent = (Value + MinValue) / Range
            let YPoint = self.frame.height * CGFloat(Percent)
            if Name == "Red"
            {
            print("Range[\(Range)]=MaxValue[\(MaxValue)]-MinValue[\(MinValue)]")
            print("Percent[\(Percent)]=Value[\(Value)]/Range[\(Range)]")
            print("DrawYIndicator(\(Name)) = \(Percent.Round(To: 3))")
            }
            Indicator.move(to: CGPoint(x: self.frame.width / 2.0, y: YPoint))
            Indicator.addLine(to: CGPoint(x: 2, y: YPoint - 8))
            Indicator.addLine(to: CGPoint(x: 2, y: YPoint + 8))
            Indicator.addLine(to: CGPoint(x: self.frame.width / 2.0, y: YPoint))
        }
        IndicatorLevel?.path = Indicator.cgPath
        IndicatorLevel?.shadowPath = Indicator.cgPath
        IndicatorLevel?.shadowOffset = CGSize(width: 3.0, height: 3.0)
        IndicatorLevel?.shadowOpacity = 0.7
    }
    
    /// The indicator shape layer.
    var IndicatorLevel: CAShapeLayer? = nil
    
    /// Draw the gradient. Either the hue gradient or the standard two-color gradient will be drawn.
    func UpdateGradient()
    {
        if UseHueGradient
        {
            DrawHueGradient()
        }
        else
        {
            DrawNormalGradient()
        }
    }
    
    func DrawHueGradient()
    {
        layer.sublayers?.forEach{if $0.name == "gradient"
        {
            $0.removeFromSuperlayer()
            GradientLayer = nil
            }
        }
        let HueRect = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
        let HueGradient = GradientManager.GetGradient(.Hue)
        HueLayer = GradientManager.CreateGradientLayer(From: HueGradient!, WithFrame: HueRect,
                                                       IsVertical: !_IsHorizontal, ReverseColors: false)
        HueLayer?.name = "hue"
        self.layer.addSublayer(HueLayer!)
    }
    
    var HueLayer: CAGradientLayer? = nil
    
    /// Draw a two-color gradient for the background of the slider control.
    func DrawNormalGradient()
    {
        layer.sublayers?.forEach{if $0.name == "hue"
        {
            $0.removeFromSuperlayer()
            HueLayer = nil
            }
        }
        if GradientLayer == nil
        {
            GradientLayer = CAGradientLayer()
            GradientLayer?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            GradientLayer?.bounds = self.bounds
            GradientLayer?.name = "gradient"
            GradientLayer?.zPosition = 500
            self.layer.addSublayer(GradientLayer!)
        }
        else
        {
            GradientLayer?.frame = CGRect(x: 0, y: 0, width: NewFrame.width, height: NewFrame.height)
        }
        if UseStartAsSolidColor
        {
            GradientLayer?.colors = [GradientStart.cgColor as Any, GradientStart.cgColor as Any]
        }
        else
        {
            GradientLayer?.colors = [GradientStart.cgColor as Any, GradientEnd.cgColor as Any]
        }
        if _IsHorizontal
        {
            GradientLayer?.startPoint = CGPoint(x: 0.0, y: 0.0)
            GradientLayer?.endPoint = CGPoint(x: 1.0, y: 0.0)
        }
        else
        {
            GradientLayer?.startPoint = CGPoint(x: 0.0, y: 0.0)
            GradientLayer?.endPoint = CGPoint(x: 0.0, y: 1.0)
        }
    }
    
    /// The gradient layer.
    var GradientLayer: CAGradientLayer? = nil
}
//
//  GSlider.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
