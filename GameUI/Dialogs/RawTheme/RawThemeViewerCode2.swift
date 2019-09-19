//
//  RawThemeViewerCode2.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import Photos

class RawThemeViewerCode2: UIViewController, UITableViewDelegate, UITableViewDataSource,
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
    
    var CurrentField: GroupField2? = nil
    
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
    
    public var FieldTables: [GroupData2] = [GroupData2]()
    
    func GetFieldFrom(ID: UUID) -> GroupField2?
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
        }
        
        return nil
    }
    
    func PopulateFieldView(With: GroupField2)
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
                
                default:
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
        StringListViewDirty.alpha = 1.0
        StringListViewDirty.tintColor = UIColor.red
    }
    
    var LastSelectedPickerViewItem: String? = nil
    
    // MARK: Table view functions.
    
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
            GradientController.GradientToEdit(CurrentField?.State as! String, Tag: "RawViewerGradient")
            self.present(GradientController, animated: true, completion: nil)
        }
    }
    
    func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        if let RawTag = Tag as? String
        {
            if RawTag == "RawViewerGradient"
            {
                if let FinalGradient = Edited
                {
                    
                }
            }
        }
    }
    @IBAction func HandleReverseGradientColorsChanged(_ sender: Any)
    {
    }
    
    @IBAction func HandleVerticalGradientChanged(_ sender: Any)
    {
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
    
    func EditTheme(ID: UUID)
    {
        //Not used.
    }
    
    func EditTheme(ID: UUID, PieceID: UUID)
    {
        //Not used.
    }
    
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
    }
    
    @IBAction func BoolSwitchChanged(_ sender: Any)
    {
        BoolViewDirty.alpha = 1.0
        BoolViewDirty.tintColor = UIColor.red
    }
    
    // MARK: String list button handling.
    
    @IBAction func StringListDefaultPressed(_ sender: Any)
    {
        StringListViewDirty.alpha = 0.0
    }
    
    @IBAction func StringListApplyPressed(_ sender: Any)
    {
        StringListViewDirty.alpha = 0.0
    }
    
    var StringListData: [String] = [String]()
    
    // MARK: Image button handling.
    
    func photoLibraryDidChange(_ changeInstance: PHChange)
    {
        //Not used.
    }
    
    @IBAction func ImageApplyPressed(_ sender: Any)
    {
        ImageViewDirty.alpha = 0.0
    }
    
    @IBAction func ImageDefaultPressed(_ sender: Any)
    {
        ImageViewDirty.alpha = 0.0
    }
    
    @IBAction func ImageProgramImagePressed(_ sender: Any)
    {
        ImageViewDirty.alpha = 1.0
        ImageViewDirty.tintColor = UIColor.red
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
        }
    }
    
    // MARK: Gradient button handling.
    
    @IBAction func GradientApplyPressed(_ sender: Any)
    {
        GradientViewDirty.alpha = 0.0
    }
    
    @IBAction func GradientDefaultPressed(_ sender: Any)
    {
        GradientViewDirty.alpha = 0.0
    }
    
    // MARK: Color button handling.
    
    @IBAction func ColorApplyPressed(_ sender: Any)
    {
        ColorViewDirty.alpha = 0.0
    }
    
    @IBAction func ColorDefaultPressed(_ sender: Any)
    {
        ColorViewDirty.alpha = 0.0
    }
    
    // MARK: Double button handling.
    
    @IBAction func DoubleApplyPressed(_ sender: Any)
    {
        DoubleViewDirty.alpha = 0.0
    }
    
    @IBAction func DoubleDefaultPressed(_ sender: Any)
    {
        DoubleViewDirty.alpha = 0.0
    }
    
    // MARK: Int button handling.
    
    @IBAction func IntApplyPressed(_ sender: Any)
    {
        IntViewDirty.alpha = 0.0
    }
    
    @IBAction func IntDefaultPressed(_ sender: Any)
    {
        IntViewDirty.alpha = 0.0
    }
    
    // MARK: String button handling.
    
    @IBAction func StringApplyPressed(_ sender: Any)
    {
        StringViewDirty.alpha = 0.0
    }
    
    @IBAction func StringDefaultPressed(_ sender: Any)
    {
        StringViewDirty.alpha = 0.0
    }
    
    // MARK: Vector3 button handling.
    
    @IBAction func Vector3ApplyPressed(_ sender: Any)
    {
        Vector3ViewDirty.alpha = 0.0
    }
    
    @IBAction func Vector3DefaultPressed(_ sender: Any)
    {
        Vector3ViewDirty.alpha = 0.0
    }
    
    // MARK: Vector4 button handling.
    
    @IBAction func Vector4ApplyPressed(_ sender: Any)
    {
        Vector4ViewDirty.alpha = 0.0
    }
    
    @IBAction func Vector4DefaultPressed(_ sender: Any)
    {
        Vector4ViewDirty.alpha = 0.0
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
    
    // MARK: Color view controls.
    @IBOutlet weak var ColorSwatch: ColorSwatchColor!
    @IBOutlet weak var ColorTitle: UILabel!
    @IBOutlet weak var ColorDescription: UILabel!
    @IBOutlet weak var ColorViewDirty: UIImageView!
    @IBOutlet weak var ColorControlTitle: UILabel!
    
    // MARK: Gradient view controls.
    @IBOutlet weak var GradientTitle: UILabel!
    @IBOutlet weak var GradientDescription: UILabel!
    @IBOutlet weak var GradientViewer: GradientSwatch!
    @IBOutlet weak var GradientViewDirty: UIImageView!
    @IBOutlet weak var VerticalGradientSwitch: UISwitch!
    @IBOutlet weak var ReverseGradientSwitch: UISwitch!
    
    // MARK: Image view controls.
    @IBOutlet weak var ImageTitle: UILabel!
    @IBOutlet weak var ImageDescription: UILabel!
    @IBOutlet weak var ImageViewer: UIImageView!
    @IBOutlet weak var ImageViewDirty: UIImageView!
    
    // MARK: String list view controls.
    @IBOutlet weak var StringListTitle: UILabel!
    @IBOutlet weak var StringListDescription: UILabel!
    @IBOutlet weak var StringListPicker: UIPickerView!
    @IBOutlet weak var StringListViewDirty: UIImageView!
    
    // MARK: Vector3 view controls.
    @IBOutlet weak var Vector3Title: UILabel!
    @IBOutlet weak var Vector3Description: UILabel!
    @IBOutlet weak var Vector3XBox: UITextField!
    @IBOutlet weak var Vector3YBox: UITextField!
    @IBOutlet weak var Vector3ZBox: UITextField!
    @IBOutlet weak var Vector3ViewDirty: UIImageView!
    
    // MARK: Vector4 view controls.
    @IBOutlet weak var Vector4Title: UILabel!
    @IBOutlet weak var Vector4Description: UILabel!
    @IBOutlet weak var Vector4XBox: UITextField!
    @IBOutlet weak var Vector4YBox: UITextField!
    @IBOutlet weak var Vector4ZBox: UITextField!
    @IBOutlet weak var Vector4WBox: UITextField!
    @IBOutlet weak var Vector4ViewDirty: UIImageView!
    
    // MARK: Double view controls.
    @IBOutlet weak var DoubleTitle: UILabel!
    @IBOutlet weak var DoubleDescription: UILabel!
    @IBOutlet weak var DoubleControlTitle: UILabel!
    @IBOutlet weak var DoubleTextBox: UITextField!
    @IBOutlet weak var DoubleViewDirty: UIImageView!
    
    // MARK: Int view controls.
    @IBOutlet weak var IntTitle: UILabel!
    @IBOutlet weak var IntDescription: UILabel!
    @IBOutlet weak var IntControlTitle: UILabel!
    @IBOutlet weak var IntTextBox: UITextField!
    @IBOutlet weak var IntViewDirty: UIImageView!
    
    // MARK: String view controls.
    @IBOutlet weak var StringTitle: UILabel!
    @IBOutlet weak var StringDescription: UILabel!
    @IBOutlet weak var StringTextBox: UITextField!
    @IBOutlet weak var StringViewDirty: UIImageView!
    
    // MARK: Bool view controls.
    @IBOutlet weak var BoolTitle: UILabel!
    @IBOutlet weak var BoolDescription: UILabel!
    @IBOutlet weak var BoolControlTitle: UILabel!
    @IBOutlet weak var BoolSwitch: UISwitch!
    @IBOutlet weak var BoolViewDirty: UIImageView!
}
