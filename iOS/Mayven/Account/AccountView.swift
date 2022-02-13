//
//  AccountView.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-26.
//

import UIKit
import Firebase
import Photos

var accountView = AccountView()

class AccountView: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var imagePickerController = UIImagePickerController()
    var user = [String: String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        accountView = self
        configureTableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        imagePickerController.delegate = self
    }
    
    fileprivate func configureTableView() {
        tableView.removeExtraCellLines()
      //  tableView.separatorInset = UIEdgeInsets.zero
        
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemGray5
        }
        else {
            view.backgroundColor = .white
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userData = retrieveUserData()
        tableView.reloadData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemGray5
            
        }
        else {
            view.backgroundColor = .white
            
        }
    }
    
    
    
    func promptForName(title: String) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields![0].placeholder = "Enter a name"
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [] _ in
        }
        
        ac.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Add", style: .default) { [] _ in
            let addUser = ac.textFields![0].text!
            
            if(addUser.trimmingCharacters(in: .whitespaces) != "" && addUser.count >= 4) {
                let groupRef = database.collection("Users").document(userData["username"]!)
                
                groupRef.updateData([
                    "name": addUser.trimmingCharacters(in: .whitespaces)
                ])
                
                editName(email: userData["userId"]!, name: addUser.trimmingCharacters(in: .whitespaces))
                
                userData = retrieveUserData()
                self.tableView.reloadData()
                
                self.dismiss(animated: true, completion: .none)
            }
            else {
                self.promptForName(title: "Your name must be 4 characters or longer")
            }
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    func promptForPassword(title: String) {
        if(!userData.isEmpty) {
            Auth.auth().sendPasswordReset(withEmail: userData["userId"]!) { error in
                let alert = UIAlertController(title: "A password reset link has been sent to your email", message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                }))
                
                self.present(alert, animated: true)
            }
        }
        else {
            firebaseLogout()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountView", for: indexPath) as! AccountCell
            
            cell.photo.layer.cornerRadius = cell.photo.frame.width/2
            cell.photo.clipsToBounds = true
            
            cell.name.text = userData["name"]!
            cell.programName.text = userData["programName"]!
            cell.username.text = userData["username"]!
            cell.classOf.text = "Class of " + String(Int(userData["classOf"]!)!+4)
            
            let userId = userData["username"]!
            let url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/" + userId + ".jpeg?alt=media&token="
            
            //cell.photo?.sd_setBackgroundImage(with: URL(string: url)!, for: .normal)
            
            loadImage(urlString: url) { returnStr, returnImg in
                if(returnImg != nil) {
                    cell.photo?.setBackgroundImage(returnImg, for: .normal)
                    cell.photo?.layoutIfNeeded()
                    cell.photo?.subviews.first?.contentMode = .scaleAspectFill
                }
                else {
                    cell.photo?.setBackgroundImage(UIImage(named: "ic_person"), for: .normal)
                    cell.photo?.layoutIfNeeded()
                    cell.photo?.subviews.first?.contentMode = .scaleAspectFill
                }
            }
            
            return cell
        }
        else if(indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutUs", for: indexPath)
            return cell
        }
        
        else if(indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "changeName", for: indexPath)
            return cell
        }
        
        else if(indexPath.row == 3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "resetPassword", for: indexPath)
            return cell
        }
        else if(indexPath.row == 4) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockedUser", for: indexPath)
            return cell
        }
        else if(indexPath.row == 5) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "logout", for: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "deleteAccount", for: indexPath)
            return cell
        }
    }
    
    
    @IBAction func changeName(_ sender: UIButton) {
        
        self.promptForName(title: "Change your name")
    }
    
    
    @IBAction func resetPassword(_ sender: UIButton) {
        self.promptForPassword(title: "Reset your password")
    }
    @IBAction func blockedUser(_ sender: UIButton) {
        guard let reactionVC = self.storyboard?.instantiateViewController(withIdentifier: "BlockedUserController")
                as? BlockedUserView else {
            
            assertionFailure("No view controller in storyboard")
            return
        }
        
        // take a snapshot of current view and set it as backingImage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
            reactionVC.backingImage = self.tabBarController?.view.asImage()
            
            reactionVC.modalPresentationStyle = .fullScreen
            // present the view controller modally without animation
            self.present(reactionVC, animated: false, completion: nil)
        })
        
    }

    @IBAction func deleteAccountBtn(_ sender: UIButton) {
        let alert2 = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        
        alert2.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
        }))
        
        alert2.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            //delete
            deleteAccount(username: userData["username"]!)
        }))
        
        self.present(alert2, animated: true)
    }

    
    @IBAction func logoutButton(_ sender: UIButton) {
        firebaseLogout()
    }
    
    @IBAction func aboutUs(_ sender: UIButton) {
        if let url = URL(string: "https://mayven.app/#about") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func changePhoto(_ sender: Any) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage
        let resizedImage = resizeImage(image: pickedImage!, targetSize: CGSize.init(width: 300, height: 300))
        let resizedThumbnailImage = resizeImage(image: pickedImage!, targetSize: CGSize.init(width: 125, height: 125))
        uploadToStorage(thumbnailImage: resizedThumbnailImage, image: resizedImage)
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! AccountCell
        
        cell.photo.setBackgroundImage(resizedImage, for: .normal)
        cell.photo.layoutIfNeeded()
        cell.photo.subviews.first?.contentMode = .scaleAspectFill
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
    
    func uploadToStorage(thumbnailImage: UIImage, image: UIImage) {
        deleteCache()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagePath = storageRef.child(userData["username"]! + ".jpeg")
        let thumbnailPath = storageRef.child("Thumbnail/" + userData["username"]!  + ".jpeg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        if let uploadData = image.jpegData(compressionQuality: 0.9) {
            imagePath.putData(uploadData, metadata: metadata) { (metadata, error) in
                if let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.45) {
                    thumbnailPath.putData(thumbnailData, metadata: metadata) { (metadata, error) in
                        
                    }
                }
            }
        }
    }
    
    
}

extension UIImage
{
    // convenience function in UIImage extension to resize a given image
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
    
}

func requestAuthorizationHandler(status: PHAuthorizationStatus) {
    if #available(iOS 14, *) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("Access granted")
        }
        else if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.limited{
            print("Access limited")
        }
        else {
            print("Access denied")
        }
    } else {
        // Fallback on earlier versions
        
    }
    
}

func requestAuthorizationHandlerOld(status: PHAuthorizationStatus) {
    if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
        print("Access granted")
    }
    else {
        print("Access denied")
    }
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

class AccountCell: UITableViewCell {
    @IBOutlet weak var photo: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var programName: UILabel!
    @IBOutlet weak var classOf: UILabel!
    
    
    
    
    
}
