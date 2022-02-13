//
//  addPost.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-24.
//

import UIKit
import Photos
import SwiftLinkPreview

var addPostDel = AddPost()

class AddPost: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var txt: UITextView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var addImgBtn: UIButton!
    
    @IBOutlet weak var selectedPhoto: UIImageView!
    
    @IBOutlet weak var removeImageBtn: UIButton!
    
    var imagePickerController = UIImagePickerController()
    var postType = "text"
    
    var img = UIImage()
    var thumbnailImg = UIImage()
    var postLink = String()
    
    let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache: DisabledCache.instance)
    
    var userData = [String: String]()
    var communityChosen = String()
    var segmentIndex = Int()
    var communities = [[String: String]]()
    
    @IBOutlet weak var addImgBtn2: UIButton!
    
    fileprivate let pickerView = ToolbarPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemGray5
            txt.textColor = .systemGray
            textField.textColor = .white
        }
        else {
            txt.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        }
        
        addDoneButtonOnKeyboard()
        textField.setLeftPaddingPoints(6)
        textField.text = communityChosen
        txt.text = "Enter your text"
        userData = retrieveUserData()
        
        txt.delegate = self
        communities = [
            ["programCode": "All"],
            ["programCode": userData["programCode"]!]
        ]
        
        //        imagePickerController.delegate = self
        
        addPostDel = self
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.toolbarDelegate = self
        self.pickerView.reloadAllComponents()
        
        textField.inputView = pickerView
        textField.inputAccessoryView = pickerView.toolbar
        
        // addImgBtn.layer.cornerRadius = 7
        // addImgBtn.layer.borderWidth = 1.0
        // addImgBtn.layer.borderColor = UIColor.white.cgColor
        
        //  txt.layer.cornerRadius = 7
        // txt.layer.borderWidth = 1.0
        // txt.layer.borderColor = UIColor.white.cgColor
        //  addBottomBorderWithColor(color: .systemGray3, width: txt.frame.width)
        
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 20, y: txt.frame.origin.y+txt.frame.size.height+1 , width: width, height: 1)
        self.view.layer.addSublayer(border)
        self.view.layer.masksToBounds = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemGray5
            textField.textColor = .white
            if(txt.textColor == .black) {
                txt.textColor = .white
            }
            else {
                txt.textColor = .systemGray
            }
            
        }
        else {
            view.backgroundColor = .white
            textField.textColor = .black
            if(txt.textColor == .systemGray) {
                txt.textColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
            }
            else if(txt.textColor == .white){
                txt.textColor = .black
            }
        }
    }
    
    @IBAction func removeImage(_ sender: UIButton) {
        selectedPhoto.image = nil
        removeImageBtn.isHidden = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage
        
        let subtractHeight = pickedImage!.size.height - 250
        let resizedHeight = pickedImage!.size.height - subtractHeight
        
        let subtractWidth = pickedImage!.size.height / resizedHeight
        let resizedWidth = pickedImage!.size.width / subtractWidth
        
        let subtractNormalHeight = pickedImage!.size.height - 1080
        let resizedNormalHeight = pickedImage!.size.height - subtractNormalHeight
        
        let subtractNormalWidth = pickedImage!.size.height / resizedNormalHeight
        let resizedNormalWidth = pickedImage!.size.width / subtractNormalWidth
        
        img = resizeImage(image: pickedImage!, targetSize: CGSize.init(width: resizedNormalWidth, height: resizedNormalHeight))
        thumbnailImg = resizeImage(image: pickedImage!, targetSize: CGSize.init(width: resizedWidth, height: resizedHeight))
        
        selectedPhoto.image = pickedImage
        removeImageBtn.isHidden = false
        selectedPhoto.layoutIfNeeded()
        selectedPhoto.subviews.first?.contentMode = .scaleAspectFill
        
        postType = "image"
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func openImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Allow access to your photos in the settings to change your photo", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
            if let url = NSURL(string: UIApplication.openSettingsURLString) as URL? {
                UIApplication.shared.open(url)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .limited:
                    print("limited")
                    // handle the case
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                case .authorized:
                    // ...
                    print("authorized")
                    DispatchQueue.main.async {
                        self.imagePickerController.sourceType = .photoLibrary
                        self.present(self.imagePickerController, animated: true, completion: nil)
                    }
                case .denied:
                    // ...
                    print("denied")
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                case .restricted:
                    fallthrough
                // ...
                
                default:
                    PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
                }
            }
        } else {
            // Fallback on earlier versions
            if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                DispatchQueue.main.async {
                    self.imagePickerController.sourceType = .photoLibrary
                    self.present(self.imagePickerController, animated: true, completion: nil)
                }
            }
            else {
                PHPhotoLibrary.requestAuthorization(requestAuthorizationHandlerOld)
            }
        }
    }
    
    @IBAction func cameraRoll(_ sender: UIButton) {
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func attachLink(_ sender: UIButton) {
        promptForLink(title: "Attach a link")
    }
    
    func promptForLink(title: String) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields![0].placeholder = "Link"
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [] _ in
        }
        
        ac.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "OK", style: .default) { [] _ in
            var linkName = ac.textFields![0].text!
            self.postType = "link"
            self.postLink = linkName
            
            if(!linkName.trimmingCharacters(in: .whitespaces).contains("https://") || !linkName.trimmingCharacters(in: .whitespaces).contains("http://")) {
                linkName = "https://" + linkName
            }
            
            self.slp.preview(linkName.trimmingCharacters(in: .whitespaces), onSuccess: { result in

                self.selectedPhoto.sd_setImage(with: URL(string: result.image!) )
                
                
                self.removeImageBtn.isHidden = false
                
            },
            onError: { error in

                self.selectedPhoto.image = UIImage(named: "link")
                
                self.selectedPhoto.translatesAutoresizingMaskIntoConstraints = false

                self.selectedPhoto.contentMode = .scaleAspectFit
                
                self.removeImageBtn.isHidden = false
                
                self.thumbnailImg = UIImage(named: "link")!
            })
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    
    
    @IBAction func addPost(_ sender: Any) {
        var textFieldColor = UIColor.black//UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        if traitCollection.userInterfaceStyle == .dark {
            textFieldColor = .white
        }
        if(txt.text.trimmingCharacters(in: .whitespaces) != "" && textField.text!.trimmingCharacters(in: .whitespaces) != "" && txt.textColor == textFieldColor) {
            
            
            firebaseAddPost(program: self.textField.text!, user: self.userData, text: self.txt.text!, type: postType, image: img, thumbnailImage: thumbnailImg, link: postLink) { returnData in
                self.dismiss(animated: true, completion: nil)
                
                forumView.tempData.insert(returnData, at: 0)
                forumView.ifTableEmpty.isHidden = true
                forumView.loadingActivity.isHidden = true
                forumView.loadingActivity.stopAnimating()
                
                
                forumView.tableView.reloadData()
            }
            
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        var textFieldColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        var colorRes = UIColor.black
        if traitCollection.userInterfaceStyle == .dark {
            textFieldColor = .systemGray
            colorRes = .white
        }
        
        if txt.textColor == textFieldColor {
            
            txt.text = ""
            txt.textColor = colorRes
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        var textFieldColor = UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        if traitCollection.userInterfaceStyle == .dark {
            textFieldColor = .systemGray
        }
        if txt.text.isEmpty || txt.text == "" {
            txt.text = "Enter your text"
            txt.textColor = textFieldColor
        }
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        txt.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        txt.resignFirstResponder()
    }
    
    @IBAction func exitButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

class Txt: UITextView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension AddPost: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let school = communities[row]["programCode"]!//schools[row]["name"]
        return school
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.communityChosen = communities[row]["programCode"]!//schoolIds[row]
        self.textField.text = communities[row]["programCode"]! //schools[row]["name"] as? String
        
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
    }
}

extension AddPost: ToolbarPickerViewDelegate {
    
    func didTapDone() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        self.textField.text = communities[row]["programCode"]!//self.schools[row]["name"] as? String
        self.textField.resignFirstResponder()
    }
    
    func didTapCancel() {
        
        self.textField.resignFirstResponder()
    }
}

