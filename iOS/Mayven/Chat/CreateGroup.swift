//
//  CreateGroup.swift
//  Mayven
//
//  Created by Kevin Chan on 2021-03-23.
//

//
//  ChatMenu.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-29.
//

import UIKit
import Photos
import Firebase


class CreateGroup: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet weak var groupImage: UIButton!
    @IBOutlet weak var groupName: UITextField!
    
    @IBOutlet weak var createBtn: UIButton!
    
    var imagePickerController = UIImagePickerController()
    var thumbnail = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData = retrieveUserData()
        
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemGray5
            groupName.textColor = .white
        }
        
        groupName.layer.cornerRadius = 7
        groupName.layer.borderWidth = 1.0
        groupName.layer.borderColor = UIColor.systemGray3.cgColor
        
        
        createBtn.layer.cornerRadius = 7
        groupName.setLeftPaddingPoints(10)
        
        groupImage.setBackgroundImage(UIImage(named: "groupImage"), for: .normal)

        groupImage.layer.cornerRadius = groupImage.frame.width/2
        imagePickerController.delegate = self
        groupImage.clipsToBounds = true
        addDoneButtonOnKeyboard()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemGray5
            groupName.textColor = .white
        }
        else {
            view.backgroundColor = .white
            groupName.textColor = .black
        }
    }
 
    @IBAction func groupImage(_ sender: UIButton) {
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
    
    @IBAction func createGroup(_ sender: UIButton) {
        if(groupName.text!.trimmingCharacters(in: .whitespaces).count < 4) {
            let alert2 = UIAlertController(title: "Group cannot be created", message: "Your group name must be greater than 4 characters", preferredStyle: .alert)
            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert2, animated: true)
        }
        else {
            if(groupImage.currentBackgroundImage != UIImage(named: "groupImage")) {
                print("GROUP 1 CREATED")
                uploadToStorage(thumbnailImage: thumbnail, image: groupImage.currentBackgroundImage!)
            }
            else{
                print("GROUP CREATED")
               // let ref = database.collection("ChatGroups").document()
               // let id = ref.documentID
                
                let thumbnailDefault = resizeImage(image: UIImage(named: "groupImage")!, targetSize: CGSize.init(width: 125, height: 125))
                let originalDefault = resizeImage(image: UIImage(named: "groupImage")!, targetSize: CGSize.init(width: 300, height: 300))
                
                uploadToStorage(thumbnailImage: thumbnailDefault, image: originalDefault)
                
                //setGroups(id: id)
            }
            dismiss(animated: true, completion: nil)
            chatMenu.getChatGroups()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage
        let resizedImage = resizeImage(image: pickedImage!, targetSize: CGSize.init(width: 300, height: 300))
        thumbnail = resizeImage(image: pickedImage!, targetSize: CGSize.init(width: 125, height: 125))

        groupImage.setBackgroundImage(resizedImage, for: .normal)
        groupImage.layoutIfNeeded()
        groupImage.subviews.first?.contentMode = .scaleAspectFill
        imagePickerController.dismiss(animated: true, completion: nil)
    }

    func uploadToStorage(thumbnailImage: UIImage, image: UIImage) {
        let ref = database.collection("ChatGroups").document()
        let id = ref.documentID
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagePath = storageRef.child("ChatGroups/" + id + ".jpeg")
        let thumbnailPath = storageRef.child("ChatGroups/Thumbnail/" + id + ".jpeg")

        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let uploadData = image.jpegData(compressionQuality: 0.9) {
            imagePath.putData(uploadData, metadata: metadata) { (metadata, error) in
                imagePath.downloadURL { url, error in
                    if let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.45) {
                        thumbnailPath.putData(thumbnailData, metadata: metadata) { (metadata, error) in
                            thumbnailPath.downloadURL { url, error in

                                self.setGroups(id: id)
                                chatMenu.getChatGroups()
                            }   
                        }
                    }
                }

            }
        }
    }
    
    
    func setGroups(id: String) {
        database.collection("ChatGroups").document(id).setData([
            "admins": [userData["username"]!],
            "members": [userData["username"]!],
            "ownerId": userData["username"]!,
            "type": "group",
            "name": self.groupName.text!
        ], merge: true)
        
        let groupRef = Database.database().reference()
        groupRef.child("Notifications").childByAutoId().setValue(
            [
                "parentUser": userData["username"]!,
                "gName": id,
                "unseenMessage": 0,
                "timestamp": Int(Date().timeIntervalSince1970),
                "lastMessage": "You have created this group",
                "lastUser": userData["username"]!
            ])
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        groupName.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        groupName.resignFirstResponder()
    }
    
}

/*
 
 let ref = database.collection("ChatGroups").document(docId)
 let id = ref.documentID
 ref.setData([
         "admins": [user["userId"]!],
         "image": image,
         "members": [user["userId"]!],
         "name": name
     ], merge: true)
 
 return id
}
 */
