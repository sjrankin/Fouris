//
//  RawThemeViewerCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import Photos

class RawThemeViewerCode: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UIPickerViewDelegate, UIPickerViewDataSource,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    PHPhotoLibraryChangeObserver,
    ThemeEditingProtocol, RawThemeFieldEditProtocol,
    GradientPickerProtocol, ColorPickerProtocol
{
    weak var ColorDelegate: ColorPickerProtocol? = nil
    weak var ThemeDelegate: ThemeEditingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ThemeDataTable.layer.borderColor = UIColor.black.cgColor
        DetailContainer.layer.borderColor = UIColor.black.cgColor
        DetailContainer.backgroundColor = UIColor.clear
        
        StringListPicker.delegate = self
        StringListPicker.dataSource = self
        
        DetailViews.append(StartingView)
        DetailViews.append(BoolView)
        DetailViews.append(StringView)
        DetailViews.append(IntView)
        DetailViews.append(DoubleView)
        DetailViews.append(Vector3View)
        DetailViews.append(Vector4View)
        DetailViews.append(ColorView)
        DetailViews.append(GradientView)
        DetailViews.append(ImageView)
        DetailViews.append(StringListView)
        DetailViews.append(ActionView)
        InitializeViews()
        PopulateFields()
        InitializeColorSwatch()
        InitializeGradientPicker()
        InitializeImagePicker()
    }
    
    deinit
    {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    var CurrentField: GroupField? = nil
    
    private var DetailViews: [UIView] = [UIView]()
    
    private func InitializeViews()
    {
        for View in DetailViews
        {
            View.alpha = 0.0
        }
        StartingView.alpha = 1.0
        CurrentView = StartingView
    }
    
    func InitializeColorSwatch()
    {
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleColorTapped))
        Tap.numberOfTapsRequired = 1
        ColorSwatch.addGestureRecognizer(Tap)
    }
    
    func InitializeGradientPicker()
    {
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleGradientTapped))
        Tap.numberOfTapsRequired = 1
        GradientViewer.addGestureRecognizer(Tap)
    }
    
    func InitializeImagePicker()
    {
        PHPhotoLibrary.shared().register(self)
    }
    
    private var CurrentView: UIView? = nil
    
    func ShowViewType(_ FieldType: FieldTypes)
    {
        var NewView: UIView? = nil
        switch FieldType
        {
            case .Bool:
                NewView = BoolView
            
            case .Int:
                NewView = IntView
            
            case .Double:
                NewView = DoubleView
            
            case .Vector3:
                NewView = Vector3View
            
            case .Vector4:
                NewView = Vector4View
            
            case .String:
                NewView = StringView
            
            case .Color:
                NewView = ColorView
            
            case .Gradient:
                NewView = GradientView
            
            case .StringList:
                NewView = StringListView
            
            case .Image:
                NewView = ImageView
            
            case .Action:
                NewView = ActionView
        }
        
        UIView.animate(withDuration: 0.1, animations:
            {
                self.CurrentView?.alpha = 0.0
                NewView?.alpha = 1.0
        }, completion:
            {
                _ in
                self.CurrentView = NewView
        })
    }
    
    public var FieldTables: [GroupData] = [GroupData]()
    
    func GetFieldFrom(ID: UUID) -> GroupField?
    {
        for Group in FieldTables
        {
            for Field in Group.Fields
            {
                if Field.ID == ID
                {
                    return Field
                }
            }
        }
        return nil
    }
    
    func GetViewForType(_ FieldType: FieldTypes) -> UIView?
    {
        switch FieldType
        {
            case .Bool:
                return BoolView
            
            case .Color:
                return ColorView
            
            case .Double:
                return DoubleView
            
            case .Gradient:
                return GradientView
            
            case .Image:
                return ImageView
            
            case .Int:
                return IntView
            
            case .String:
                return StringView
            
            case .StringList:
                return StringListView
            
            case .Vector3:
                return Vector3View
            
            case .Vector4:
                return Vector4View
            
            case .Action:
                return ActionView
        }
    }
    
    func PopulateFieldView(With: GroupField)
    {
        if let Field = GetFieldFrom(ID: With.ID)
        {
            switch Field.FieldType
            {
                case .Bool:
                    PopulateBooleanView(WithField: Field)
                
                case .Int:
                    PopulateIntView(WithField: Field)
                
                case .Double:
                    PopulateDoubleView(WithField: Field)
                
                case .String:
                    PopulateStringView(WithField: Field)
                
                case .StringList:
                    PopulateStringListView(WithField: Field)
                
                case .Color:
                    PopulateColorView(WithField: Field)
                
                case .Vector3:
                    PopulateVector3View(WithField: Field)
                
                case .Vector4:
                    PopulateVector4View(WithField: Field)
                
                case .Image:
                    PopulateImageView(WithField: Field)
                
                case .Gradient:
                    PopulateGradientView(WithField: Field)
                
                case .Action:
                    PopulateActionView(WithField: Field)
                
                case .none:
                    break
            }
        }
    }
    
    // MARK: Picker functions.
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return StringListData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return StringListData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        LastSelectedPickerViewItem = StringListData[row]
        CurrentPickedString = LastSelectedPickerViewItem
        StringListViewDirty.alpha = 1.0
        StringListViewDirty.tintColor = UIColor.red
        ThrobApplyButton(StringListApplyButton)
    }
    
    var LastSelectedPickerViewItem: String? = nil
    
    // MARK: Table view functions.
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let View = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 35.0))
        let Header = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.bounds.size.width - 20, height: 35))
        Header.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        if FieldTables[section].HeaderTitle == "Reset"
        {
            View.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.Maroon)
            Header.textColor = UIColor.yellow
        }
        else
        {
            View.layer.backgroundColor = UIColor.black.cgColor
            Header.textColor = UIColor.white
        }
        Header.text = FieldTables[section].HeaderTitle
        View.addSubview(Header)
        return View
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return FieldTables[section].HeaderTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let SelectedCell = tableView.cellForRow(at: indexPath) as? RawThemeViewerTitleCell
        if let Field = GetFieldFrom(ID: (SelectedCell?.CellID!)!)
        {
            print("Selected field \"\(Field.Title)\"")
            PopulateFieldView(With: Field)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return RawThemeViewerTitleCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return FieldTables[section].Fields.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return FieldTables.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = RawThemeViewerTitleCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TitleCell")
        let CellID = FieldTables[indexPath.section].Fields[indexPath.row].ID
        let CellTitle = FieldTables[indexPath.section].Fields[indexPath.row].Title
        Cell.Initialize(Title: CellTitle, ID: CellID, ParentWidth: tableView.bounds.size.width)
        return Cell
    }
    
    // MARK: Gradient picker functions.
    
    @objc func HandleGradientTapped(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            let GradientControllerUI = UIStoryboard(name: "Theming", bundle: nil)
            let GradientController = GradientControllerUI.instantiateViewController(identifier: "GradientEditorUI") as! GradientEditorCode
            GradientController.GradientDelegate = self
            var FinalDescriptor = ""
            if let RawDescriptor = CurrentField?.State as? String
            {
                FinalDescriptor = RawDescriptor
            }
            else
            {
                FinalDescriptor = "(White)@(0.0),(Black)@(1.0)"
            }
            GradientController.GradientToEdit(FinalDescriptor, Tag: "RawViewerGradient")
            self.present(GradientController, animated: true, completion: nil)
        }
    }
    
    @IBSegueAction func InstantiateGradientEditor(_ coder: NSCoder) -> GradientEditorCode?
    {
        let Editor = GradientEditorCode(coder: coder)
        Editor?.GradientDelegate = self
        var FinalDescriptor = ""
        if let RawDescriptor = CurrentField?.State as? String
        {
            FinalDescriptor = RawDescriptor
        }
        else
        {
            FinalDescriptor = "(White)@(0.0),(Black)@(1.0)"
        }
        Editor?.GradientToEdit(FinalDescriptor, Tag: "RawViewerGradient")
        return Editor
    }
    
    func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        if let RawTag = Tag as? String
        {
            if RawTag == "RawViewerGradient"
            {
                if let FinalGradient = Edited
                {
                    CurrentField?.State = FinalGradient as Any
                    GradientViewer.GradientDescriptor = FinalGradient
                    GradientViewDirty.alpha = 1.0
                    GradientViewDirty.tintColor = UIColor.red
                    ThrobApplyButton(GradientApplyButton)
                }
            }
        }
    }
    
    @IBAction func HandleReverseGradientColorsChanged(_ sender: Any)
    {
        let DoReverse = ReverseGradientSwitch.isOn
        let DoVertical = VerticalGradientSwitch.isOn
        if let Descriptor = CurrentField?.State as? String
        {
            let NewDescriptor = GradientManager.EditMetadata(Descriptor, NewVertical: DoVertical, NewReverse: DoReverse)
            CurrentField?.State = NewDescriptor as Any
            GradientViewer.GradientDescriptor = NewDescriptor
        }
    }
    
    @IBAction func HandleVerticalGradientChanged(_ sender: Any)
    {
        let DoReverse = ReverseGradientSwitch.isOn
        let DoVertical = VerticalGradientSwitch.isOn
        if let Descriptor = CurrentField?.State as? String
        {
            let NewDescriptor = GradientManager.EditMetadata(Descriptor, NewVertical: DoVertical, NewReverse: DoReverse)
            CurrentField?.State = NewDescriptor as Any
            GradientViewer.GradientDescriptor = NewDescriptor
        }
    }
    
    func GradientToEdit(_ Edited: String?, Tag: Any?)
    {
        //Not used here.
    }
    
    func SetStop(StopColorIndex: Int)
    {
        //Not used here.
    }
    
    // MARK: Color picker functions.
    
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        //Not used here.
    }
    
    func EditedColor(_ Edited: UIColor?, Tag: Any?)
    {
        if let RawTag = Tag as? String
        {
            if RawTag == "RawViewerColor"
            {
                if let FinalColor = Edited
                {
                    ColorSwatch.TopColor = FinalColor
                    let ColorNames = PredefinedColors.NamesFrom(FindColor: FinalColor)
                    let ColorName: String? = ColorNames.count > 0 ? ColorNames[0] : nil
                    ColorControlTitle.text = ColorName == nil ? "" : ColorName!
                    ColorViewDirty.alpha = 1.0
                    ColorViewDirty.tintColor = UIColor.red
                    ThrobApplyButton(ColorApplyButton)
                }
            }
        }
    }
    
    @objc func HandleColorTapped(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            let ColorControllerUI = UIStoryboard(name: "Theming", bundle: nil)
            let ColorController = ColorControllerUI.instantiateViewController(identifier: "ColorPicker") as! ColorPickerCode
            ColorController.ColorDelegate = self
            ColorController.ColorToEdit(ColorSwatch.TopColor, Tag: "RawViewerColor")
            self.present(ColorController, animated: true, completion: nil)
        }
    }
    
    // MARK: Theme editing functions.
    
    func EditTheme(Theme: ThemeDescriptor, DefaultTheme: ThemeDescriptor)
    {
        UserTheme = Theme
        self.DefaultTheme = DefaultTheme
    }
    
    func EditTheme(Theme: ThemeDescriptor, PieceID: UUID, DefaultTheme: ThemeDescriptor)
    {
        UserTheme = Theme
        self.DefaultTheme = DefaultTheme
    }
    
    var UserTheme: ThemeDescriptor? = nil
    var DefaultTheme: ThemeDescriptor? = nil
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Not used.
    }
    
    // MARK: Raw theme field editing functions.
    
    func EditedField(_ ID: UUID, NewValue: Any, DefaultValue: Any, FieldType: FieldTypes)
    {
        //Not used.
    }
    
    // MARK: Main UI button handling.
    
    var WasEdited = false
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(WasEdited, ThemeID: UUID.Empty, PieceID: UUID.Empty)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Boolean button handling.
    
    @IBAction func BoolDefaultPressed(_ sender: Any)
    {
        BoolViewDirty.alpha = 0.0
    }
    
    @IBAction func BoolApplyPressed(_ sender: Any)
    {
        BoolViewDirty.alpha = 0.0
        CurrentField?.Handler!(BoolSwitch.isOn as Any)
        ResetApplyButton(BoolApplyButton)
    }
    
    @IBAction func BoolSwitchChanged(_ sender: Any)
    {
        BoolViewDirty.alpha = 1.0
        BoolViewDirty.tintColor = UIColor.red
        ThrobApplyButton(BoolApplyButton)
    }
    
    // MARK: String list button handling.
    
    @IBAction func StringListDefaultPressed(_ sender: Any)
    {
        StringListViewDirty.alpha = 0.0
    }
    
    @IBAction func StringListApplyPressed(_ sender: Any)
    {
        StringListViewDirty.alpha = 0.0
        if let CurrentItem = CurrentPickedString
        {
            print("Selected item: \(CurrentItem)")
            CurrentField?.Handler!(CurrentItem as Any)
        }
        ResetApplyButton(StringListApplyButton)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, forComponent component: Int)
    {
        let CurrentList = CurrentField?.StringList
        if let Warning = CurrentField?.WarningTriggers[CurrentList![row]]
        {
            WarningBox.alpha = 1.0
            WarningLabel.alpha = 1.0
            WarningLabel.text = Warning
        }
        else
        {
            WarningBox.alpha = 0.0
            WarningLabel.alpha = 0.0
        }
    }
    
    var CurrentPickedString: String? = nil
    
    var StringListData: [String] = [String]()
    
    // MARK: Image button handling.
    
    func photoLibraryDidChange(_ changeInstance: PHChange)
    {
        //Not used.
    }
    
    @IBAction func ImageApplyPressed(_ sender: Any)
    {
        ImageViewDirty.alpha = 0.0
        CurrentField?.Handler!("" as Any)
        ResetApplyButton(ImageApplyButton)
    }
    
    @IBAction func ImageDefaultPressed(_ sender: Any)
    {
        ImageViewDirty.alpha = 0.0
    }
    
    @IBAction func ImageProgramImagePressed(_ sender: Any)
    {
        ImageViewDirty.alpha = 1.0
        ImageViewDirty.tintColor = UIColor.red
        ThrobApplyButton(ImageApplyButton)
    }
    
    @IBAction func ImagePhotoRollPressed(_ sender: Any)
    {
        ImagePicker = UIImagePickerController()
        ImagePicker?.delegate = self
        ImagePicker?.allowsEditing = false
        ImagePicker?.sourceType = .photoLibrary
        self.present(ImagePicker!, animated: true, completion: nil)
    }
    
    var ImagePicker: UIImagePickerController? = nil
    var ImageName: String!
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let PickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            ImageViewer.image = PickedImage
            let Assets = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
            let AssetResources = PHAssetResource.assetResources(for: Assets!)
            ImageName = AssetResources.first!.originalFilename
            CurrentField?.State = ImageName as Any
            ImageViewDirty.alpha = 1.0
            ImageViewDirty.tintColor = UIColor.red
            ThrobApplyButton(ImageApplyButton)
        }
    }
    
    // MARK: Action button handling.
    
    @IBAction func HandleActionButtonPressed(_ sender: Any)
    {
        CurrentField?.Handler!("" as Any)
    }
    
    func HandleResetButtonPressed()
    {
        let Alert = UIAlertController(title: "Reset Settings?",
                                      message: "Do you really want to reset all settings to their default values? You will lose your settings.",
                                      preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Reset", style: UIAlertAction.Style.destructive, handler: DoResetAllSettings))
        Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(Alert, animated: true, completion: nil)
    }
    
    @objc func DoResetAllSettings(Action: UIAlertAction)
    {
        ActionResults.alpha = 1.0
        ActionResults.text = "Nothing yet!"
    }
    
    // MARK: Gradient button handling.
    
    @IBAction func GradientApplyPressed(_ sender: Any)
    {
        GradientViewDirty.alpha = 0.0
        CurrentField?.Handler!(GradientViewer.GradientDescriptor as Any)
        ResetApplyButton(GradientApplyButton)
    }
    
    @IBAction func GradientDefaultPressed(_ sender: Any)
    {
        GradientViewDirty.alpha = 0.0
    }
    
    // MARK: Color button handling.
    
    @IBAction func ColorApplyPressed(_ sender: Any)
    {
        ColorViewDirty.alpha = 0.0
        let Color = ColorSwatch.TopColor
        let ColorName = ColorServer.MakeColorName(From: Color)
        CurrentField?.Handler!(ColorName as Any)
        ResetApplyButton(ColorApplyButton)
    }
    
    @IBAction func ColorDefaultPressed(_ sender: Any)
    {
        ColorViewDirty.alpha = 0.0
    }
    
    // MARK: Double button handling.
    
    @IBAction func DoubleApplyPressed(_ sender: Any)
    {
        DoubleViewDirty.alpha = 0.0
        if let DoubleString = DoubleTextBox.text
        {
            if let DoubleValue = Double(DoubleString)
            {
                CurrentField?.Handler!(DoubleValue as Any)
            }
        }
        ResetApplyButton(DoubleApplyButton)
    }
    
    @IBAction func DoubleDefaultPressed(_ sender: Any)
    {
        DoubleViewDirty.alpha = 0.0
    }
    
    @IBAction func DoubleValueChanged(_ sender: Any)
    {
        DoubleViewDirty.alpha = 1.0
        DoubleViewDirty.tintColor = UIColor.red
        ThrobApplyButton(DoubleApplyButton)
    }
    
    // MARK: Int button handling.
    
    @IBAction func IntApplyPressed(_ sender: Any)
    {
        IntViewDirty.alpha = 0.0
        if let IntString = IntTextBox.text
        {
            if let IntValue = Double(IntString)
            {
                CurrentField?.Handler!(IntValue as Any)
            }
        }
        ResetApplyButton(IntApplyButton)
    }
    
    @IBAction func IntDefaultPressed(_ sender: Any)
    {
        IntViewDirty.alpha = 0.0
    }
    
    @IBAction func IntValueChanged(_ sender: Any)
    {
        IntViewDirty.alpha = 1.0
        IntViewDirty.tintColor = UIColor.red
        ThrobApplyButton(IntApplyButton)
    }
    
    // MARK: String button handling.
    
    @IBAction func StringApplyPressed(_ sender: Any)
    {
        StringViewDirty.alpha = 0.0
        CurrentField?.Handler!(StringTextBox as Any)
        ResetApplyButton(StringApplyButton)
    }
    
    @IBAction func StringDefaultPressed(_ sender: Any)
    {
        StringViewDirty.alpha = 0.0
    }
    
    @IBAction func StringValueChanged(_ sender: Any)
    {
        StringViewDirty.alpha = 1.0
        StringViewDirty.tintColor = UIColor.red
        ThrobApplyButton(StringApplyButton)
    }
    
    // MARK: Vector3 button handling.
    
    @IBAction func Vector3ApplyPressed(_ sender: Any)
    {
        if let Vector = GroupData.AssembleVector3(XBox: Vector3XBox, YBox: Vector3YBox, ZBox: Vector3ZBox)
        {
            CurrentField?.Handler!(Vector as Any)
        }
        Vector3ViewDirty.alpha = 0.0
        ResetApplyButton(Vector3ApplyButton)
    }
    
    @IBAction func Vector3DefaultPressed(_ sender: Any)
    {
        Vector3ViewDirty.alpha = 0.0
    }
    
    @IBAction func Vector3ComponentChanged(_ sender: Any)
    {
        Vector3ViewDirty.alpha = 1.0
        Vector3ViewDirty.tintColor = UIColor.red
        ThrobApplyButton(Vector3ApplyButton)
    }
    
    // MARK: Vector4 button handling.
    
    @IBAction func Vector4ApplyPressed(_ sender: Any)
    {
        if let Vector = GroupData.AssembleVector4(XBox: Vector4XBox, YBox: Vector4YBox, ZBox: Vector4ZBox, WBox: Vector4WBox)
        {
            CurrentField?.Handler!(Vector as Any)
        }
        Vector4ViewDirty.alpha = 0.0
        ResetApplyButton(Vector4ApplyButton)
    }
    
    @IBAction func Vector4DefaultPressed(_ sender: Any)
    {
        Vector4ViewDirty.alpha = 0.0
    }
    
    @IBAction func Vector4ComponentChanged(_ sender: Any)
    {
        Vector4ViewDirty.alpha = 1.0
        Vector4ViewDirty.tintColor = UIColor.red
        ThrobApplyButton(Vector4ApplyButton)
    }
    
    // MARK: General purpose UI functions.
    
    func ThrobApplyButton(_ Button: UIButton)
    {
        Button.StartPulsation()
        Button.StartColorCycling()
    }
    
    func ResetApplyButton(_ Button: UIButton)
    {
        Button.StopAnimations()
        Button.tintColor = UIColor.systemBlue
        Button.Scale(Duration: 0.15)
    }
    
    // MARK: UI control outlets.
    @IBOutlet weak var DetailContainer: UIView!
    @IBOutlet weak var ThemeDataTable: UITableView!
    
    // MARK: View containers.
    @IBOutlet weak var ColorView: UIView!
    @IBOutlet weak var GradientView: UIView!
    @IBOutlet weak var ImageView: UIView!
    @IBOutlet weak var StringListView: UIView!
    @IBOutlet weak var Vector4View: UIView!
    @IBOutlet weak var Vector3View: UIView!
    @IBOutlet weak var DoubleView: UIView!
    @IBOutlet weak var IntView: UIView!
    @IBOutlet weak var StringView: UIView!
    @IBOutlet weak var BoolView: UIView!
    @IBOutlet weak var StartingView: UIView!
    @IBOutlet weak var ActionView: UIView!
    
    // MARK: Color view controls.
    @IBOutlet weak var ColorSwatch: ColorSwatchColor!
    @IBOutlet weak var ColorTitle: UILabel!
    @IBOutlet weak var ColorDescription: UILabel!
    @IBOutlet weak var ColorViewDirty: UIImageView!
    @IBOutlet weak var ColorControlTitle: UILabel!
        @IBOutlet weak var ColorApplyButton: UIButton!
    
    // MARK: Gradient view controls.
    @IBOutlet weak var GradientTitle: UILabel!
    @IBOutlet weak var GradientDescription: UILabel!
    @IBOutlet weak var GradientViewer: GradientSwatch!
    @IBOutlet weak var GradientViewDirty: UIImageView!
    @IBOutlet weak var VerticalGradientSwitch: UISwitch!
    @IBOutlet weak var ReverseGradientSwitch: UISwitch!
    @IBOutlet weak var WarningBox: UIView!
    @IBOutlet weak var WarningLabel: UILabel!
        @IBOutlet weak var GradientApplyButton: UIButton!
    
    // MARK: Image view controls.
    @IBOutlet weak var ImageTitle: UILabel!
    @IBOutlet weak var ImageDescription: UILabel!
    @IBOutlet weak var ImageViewer: UIImageView!
    @IBOutlet weak var ImageViewDirty: UIImageView!
    @IBOutlet weak var ImagePhotoRollButton: UIButton!
    @IBOutlet weak var ImageProgramImagesButton: UIButton!
        @IBOutlet weak var ImageApplyButton: UIButton!
    
    // MARK: String list view controls.
    @IBOutlet weak var StringListTitle: UILabel!
    @IBOutlet weak var StringListDescription: UILabel!
    @IBOutlet weak var StringListPicker: UIPickerView!
    @IBOutlet weak var StringListViewDirty: UIImageView!
        @IBOutlet weak var StringListApplyButton: UIButton!
    
    // MARK: Vector3 view controls.
    @IBOutlet weak var Vector3Title: UILabel!
    @IBOutlet weak var Vector3Description: UILabel!
    @IBOutlet weak var Vector3XBox: UITextField!
    @IBOutlet weak var Vector3YBox: UITextField!
    @IBOutlet weak var Vector3ZBox: UITextField!
    @IBOutlet weak var Vector3ViewDirty: UIImageView!
    @IBOutlet weak var Vector3ApplyButton: UIButton!
    
    // MARK: Vector4 view controls.
    @IBOutlet weak var Vector4Title: UILabel!
    @IBOutlet weak var Vector4Description: UILabel!
    @IBOutlet weak var Vector4XBox: UITextField!
    @IBOutlet weak var Vector4YBox: UITextField!
    @IBOutlet weak var Vector4ZBox: UITextField!
    @IBOutlet weak var Vector4WBox: UITextField!
    @IBOutlet weak var Vector4ViewDirty: UIImageView!
        @IBOutlet weak var Vector4ApplyButton: UIButton!
    
    // MARK: Double view controls.
    @IBOutlet weak var DoubleTitle: UILabel!
    @IBOutlet weak var DoubleDescription: UILabel!
    @IBOutlet weak var DoubleControlTitle: UILabel!
    @IBOutlet weak var DoubleTextBox: UITextField!
    @IBOutlet weak var DoubleViewDirty: UIImageView!
        @IBOutlet weak var DoubleApplyButton: UIButton!
    
    // MARK: Int view controls.
    @IBOutlet weak var IntTitle: UILabel!
    @IBOutlet weak var IntDescription: UILabel!
    @IBOutlet weak var IntControlTitle: UILabel!
    @IBOutlet weak var IntTextBox: UITextField!
    @IBOutlet weak var IntViewDirty: UIImageView!
        @IBOutlet weak var IntApplyButton: UIButton!
    
    // MARK: String view controls.
    @IBOutlet weak var StringTitle: UILabel!
    @IBOutlet weak var StringDescription: UILabel!
    @IBOutlet weak var StringTextBox: UITextField!
    @IBOutlet weak var StringViewDirty: UIImageView!
        @IBOutlet weak var StringApplyButton: UIButton!
    
    // MARK: Bool view controls.
    @IBOutlet weak var BoolTitle: UILabel!
    @IBOutlet weak var BoolDescription: UILabel!
    @IBOutlet weak var BoolControlTitle: UILabel!
    @IBOutlet weak var BoolSwitch: UISwitch!
    @IBOutlet weak var BoolViewDirty: UIImageView!
        @IBOutlet weak var BoolApplyButton: UIButton!
    
    // MARK: Action view controls.
    @IBOutlet weak var ActionResults: UILabel!
    @IBOutlet weak var ActionButton: UIButton!
    @IBOutlet weak var ActionDescription: UILabel!
    @IBOutlet weak var ActionTitle: UILabel!
}
