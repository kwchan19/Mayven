//
//  ViewGroup.swift
//  Mayven
//
//  Created by Kevin Chan on 2021-03-25.
//


import UIKit
import Photos
import Firebase

var viewGroup = ViewGroup()

class ViewGroup: UIViewController, UIImagePickerControllerDelegate, UITableViewDelegate, UINavigationControllerDelegate, UITableViewDataSource {
    
    var userData = [String: String]()
    var imagePickerController = UIImagePickerController()
    var thumbnail = UIImage()
    var groupId = String()
    var group = String()
    var ownerId = String()
    var isAdmin = Bool()
    var imagePath = 0
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var leaveDots: UIButton!
    var arr = [[String: Any]]()
    
    @IBOutlet weak var groupImage: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var groupName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        

        isInViewGroup = true
        viewGroup = self
        userData = retrieveUserData()
        
        if(isAdmin == true || ownerId == userData["username"]!) {
            groupImage.isUserInteractionEnabled = true
 
            addBtn.isHidden = false
        }
        else {
            groupImage.isUserInteractionEnabled = false
 
            addBtn.isHidden = true
        }
        
        let classOf = Int(userData["classOf"]!)! + 4
        
        if(groupId == (userData["school"]! + "-" + userData["programCode"]! + "-" + String(classOf))) {
            print("True")
            leaveDots.isUserInteractionEnabled = false
            leaveDots.isHidden = true
        }
        else {
            print("False")
            leaveDots.isUserInteractionEnabled = true
            leaveDots.isHidden = false
        }
        
        imagePickerController.delegate = self
        configureTableView()
        retrieve()
        getImage()
        
        groupName.text = group
        groupImage.layer.cornerRadius = groupImage.frame.width/2
        groupImage.clipsToBounds = true

    }
    
    func getImage() {
        let url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/ChatGroups%2F" + groupId + ".jpeg?alt=media&token="
    
        
        self.groupImage?.sd_setBackgroundImage(with: URL(string: url)!, for: .normal, placeholderImage: UIImage(named: "placeholderImg"))
        
        self.groupImage?.layoutIfNeeded()
        self.groupImage?.subviews.first?.contentMode = .scaleAspectFill
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isInViewGroup = false
      }
    
    func retrieve() {
        getGroup(groupId: groupId) { returnData in
            self.arr = returnData
            self.tableView.reloadData()
        }
    }
    @IBAction func addMember(_ sender: UIButton) {
        promptForAnswer(title: "Add Member")
    }
    
    fileprivate func configureTableView() {
        tableView.removeExtraCellLines()
        tableView.separatorInset = UIEdgeInsets.zero
        
        //   tableView.separatorColor = .clear
        if traitCollection.userInterfaceStyle == .dark {
            tableView.backgroundColor = .systemGray5
            view.backgroundColor = .systemGray5
            
            //chatView.backgroundColor = .systemGray5
            //textView.backgroundColor = .systemGray6
            
           // newPost.backgroundColor = .white
           // newPost.tintColor = .black
           // postContainer.backgroundColor = .white
           // postContainer.tintColor = .black
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
          
            view.backgroundColor = .systemGray5
            //groupName.backgroundColor = .systemGray
            //groupName.textColor = .white
        }
        else {
  
            view.backgroundColor = .white
           // groupName.backgroundColor = .opaqueSeparator
           // groupName.textColor = .black
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "viewGroupCell", for: indexPath) as! ViewGroupCell
        cell.name.text = arr[indexPath.row]["name"] as? String
        cell.userId.text = arr[indexPath.row]["username"] as? String
        cell.img.layer.cornerRadius = cell.img.frame.size.width/2
        cell.img.clipsToBounds = true
        cell.isAdmin.isHidden = true
        cell.dots.tag = indexPath.row
        cell.img.tag = indexPath.row
        
        if(indexPath.row == 0) {
            cell.dots.isHidden = true
        }
        
        if(ownerId == userData["username"]! && indexPath.row != 0) {
            cell.dots.isHidden = false
        }
        else if(isAdmin && ownerId != userData["username"]!) {
            if(arr[indexPath.row]["admin"] as! Bool == true) {
                cell.dots.isHidden = true
            }
            else {
                cell.dots.isHidden = false
            }
        }
        else {
            cell.dots.isHidden = true
        }
        
        if(indexPath.row == 0 && arr[0]["admin"] as! Bool == true) {
            cell.isAdmin.text = "Owner"
            cell.isAdmin.isHidden = false
        }
        
        if(indexPath.row > 0 && arr[indexPath.row]["admin"] as? Bool == true) {
            cell.isAdmin.text = "Admin"
            cell.isAdmin.isHidden = false
        }
        
        let userId = arr[indexPath.row]["username"] as! String
        let url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + userId + ".jpeg?alt=media&token="
        
        
        cell.img?.sd_setBackgroundImage(with: URL(string: url)!, for: .normal, placeholderImage: UIImage(named: "placeholderImg"))
        cell.img?.layoutIfNeeded()
        cell.img?.subviews.first?.contentMode = .scaleAspectFill
        
      /*  loadImage(urlString: url) { returnStr, returnImg in
            if(returnImg != nil) {
                cell.img?.setBackgroundImage(returnImg, for: .normal)
                cell.img?.layoutIfNeeded()
                cell.img?.subviews.first?.contentMode = .scaleAspectFill
            }
            else {
                cell.img?.setBackgroundImage(UIImage(named: "groupImage"), for: .normal)
                cell.img?.layoutIfNeeded()
                cell.img?.subviews.first?.contentMode = .scaleAspectFill
            }
        }
 */
        
        return cell
    }
  
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
 
    @IBAction func leaveGroup(_ sender: UIButton) {
        
        if(ownerId == userData["username"]!) {
            let alert = UIAlertController(title: "Delete Group?", message: "", preferredStyle: .actionSheet)
                
            alert.addAction(UIAlertAction(title: "Delete Group", style: .destructive, handler: { action in
                let alert2 = UIAlertController(title: "Are you sure you want to delete this group?", message: "", preferredStyle: .actionSheet)
                    
                alert2.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    
                    deleteChatGroup(groupId: self.groupId)
                    
                    let storage = Storage.storage()
                    let storageRef = storage.reference()
                    let original = storageRef.child("ChatGroups/" + self.groupId + ".jpeg")
                    let thumbnail =  storageRef.child("ChatGroups/Thumbnail/" + self.groupId + ".jpeg")

                    // Delete the file
                    original.delete { error in
                      if let error = error {
                        print("Failed to delete, ", error)
                        // Uh-oh, an error occurred!
                      } else {
                        // File deleted successfully
                        thumbnail.delete { error in
                          if let error = error {
                            print("Failed to delete, ", error)
                            // Uh-oh, an error occurred!
                          } else {
                            // File deleted successfully
                          }
                        }
                      }
                    }
                }))
                
                alert2.addAction(UIAlertAction(title: "No", style: .destructive, handler: { action in
                }))
                
                alert2.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                }))
                
                if let popoverPresentationController = alert2.popoverPresentationController {
                    popoverPresentationController.sourceRect = sender.frame
                    popoverPresentationController.sourceView = self.view
                }
                
                self.present(alert2, animated: true, completion: nil)
                
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    
            }))
            
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceRect = sender.frame
                popoverPresentationController.sourceView = self.view
                
            }
            
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Leave Group?", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Leave Group", style: .destructive, handler: { action in
                let alert2 = UIAlertController(title: "Leave Group", message: "Are you sure you want to leave this group?", preferredStyle: .actionSheet)
                    
                alert2.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    removeUserFromGroup(username: self.userData["username"]!, groupId: self.groupId)
                }))
                
                alert2.addAction(UIAlertAction(title: "No", style: .destructive, handler: { action in
                    
                }))
                
                alert2.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                        
                }))
                
                if let popoverPresentationController = alert2.popoverPresentationController {
                    
                    popoverPresentationController.sourceRect = sender.frame
                    popoverPresentationController.sourceView = self.view
                    
                }
                
                self.present(alert2, animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    
            }))
            
            if let popoverPresentationController = alert.popoverPresentationController {
                
                popoverPresentationController.sourceRect = sender.frame
                popoverPresentationController.sourceView = self.view
                
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func groupImage(_ sender: Any) {
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
        thumbnail = resizeImage(image: pickedImage!, targetSize: CGSize.init(width: 125, height: 125))
        uploadToStorage(thumbnailImage: thumbnail, image: resizedImage)
        groupImage.setBackgroundImage(resizedImage, for: .normal)
        groupImage.setImage(nil, for: .normal)
        groupImage.layoutIfNeeded()
        groupImage.subviews.first?.contentMode = .scaleAspectFill
        imagePickerController.dismiss(animated: true, completion: nil)
    }

    func uploadToStorage(thumbnailImage: UIImage, image: UIImage) {
        let ref = database.collection("ChatGroups").document(groupId)
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagePath = storageRef.child("ChatGroups/" + groupId + ".jpeg")
        let thumbnailPath = storageRef.child("ChatGroups/Thumbnail/" + groupId + ".jpeg")
        var imageUrl = ""
        var thumbnailUrl = ""
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let uploadData = image.jpegData(compressionQuality: 0.9) {
            imagePath.putData(uploadData, metadata: metadata) { (metadata, error) in

                imagePath.downloadURL { url, error in
                    imageUrl = url!.absoluteString
                    
                    if let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.45) {
                        thumbnailPath.putData(thumbnailData, metadata: metadata) { (metadata, error) in
                            thumbnailPath.downloadURL { url, error in
                                thumbnailUrl = url!.absoluteString
                                ref.updateData([
                                    "thumbnailURL": thumbnailUrl,
                                    "imageURL": imageUrl,

                                ])
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func promptForAnswer(title: String) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields![0].placeholder = "Enter username"
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [] _ in
        }
        
        ac.addAction(cancelAction)

        let submitAction = UIAlertAction(title: "Add", style: .default) { [] _ in
            let addUser = ac.textFields![0].text!
            
            if(addUser.trimmingCharacters(in: .whitespaces) != "") {
                if(addUser != self.userData["username"] ) {
                    getUserProfile(userId: addUser) { returnData in
                        if(returnData.isEmpty) {
                            // User doesnt exist
                            self.promptForAnswer(title: "User does not exist")
                        }
                        else {
                            if(returnData["school"] as! String == self.userData["school"]!) {
                                let name = returnData["name"] as! String
                                addUserToGroup(username: addUser.trimmingCharacters(in: .whitespaces), groupId: self.groupId, name: name, groupName: self.group)
                                self.dismiss(animated: true, completion: .none)
                                viewGroup.retrieve()
                            }
                            else {
                                self.promptForAnswer(title: "User does not exist")
                            }
                        }
                    }
                }
                else {
                    self.promptForAnswer(title: "Please enter a valid username")
                }
            }
            else {
                self.promptForAnswer(title: "Please enter a valid username")
            }
        }
        
        ac.addAction(submitAction)

        present(ac, animated: true)
    }
    
    @IBAction func dotsPressed(_ sender: UIButton) {
        
        if(isAdmin == true && ownerId != userData["username"]!) {
            if(arr[sender.tag]["admin"] as! Bool == false) {
                let ac = UIAlertController(title: "User actions", message: nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [] _ in
                
                }
                
                let removeUser = UIAlertAction(title: "Remove user from group", style: .destructive) { [self] _ in
                    removeUserFromGroup(username: arr[sender.tag]["username"] as! String, groupId: groupId)
                    retrieve()
                }
                
                ac.addAction(cancelAction)
                ac.addAction(removeUser)
                
                if let popoverPresentationController = ac.popoverPresentationController {
                    
                    popoverPresentationController.sourceRect = sender.frame
                    popoverPresentationController.sourceView = self.view
                    
                }
                
                present(ac, animated: true)
            }
        }
        else if(ownerId == userData["username"]!){
            if(arr[sender.tag]["admin"] as! Bool == true) {
                let ac = UIAlertController(title: "User actions", message: nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [] _ in
                }
                
                let removeUser = UIAlertAction(title: "Remove user from group", style: .destructive) { [self] _ in
                    removeUserFromGroup(username: arr[sender.tag]["username"] as! String, groupId: groupId)
                    retrieve()
                }
                
                let demoteUser = UIAlertAction(title: "Demote user", style: .default) { [self] _ in
                    demoteFromAdmin(username: arr[sender.tag]["username"] as! String, groupId: groupId)
                    retrieve()
                }
                
                ac.addAction(cancelAction)
                ac.addAction(demoteUser)
                ac.addAction(removeUser)
                
                if let popoverPresentationController = ac.popoverPresentationController {
                    
                    popoverPresentationController.sourceRect = sender.frame
                    popoverPresentationController.sourceView = self.view
                    
                }
                
                present(ac, animated: true)
            }
            else {
            
                let ac = UIAlertController(title: "User actions", message: nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [] _ in
                }
                
                let removeUser = UIAlertAction(title: "Remove user from group?", style: .destructive) { [self] _ in
                    removeUserFromGroup(username: arr[sender.tag]["username"] as! String, groupId: groupId)
                    retrieve()
                }
                
                let promoteUser = UIAlertAction(title: "Promote user to admin?", style: .default) { [self] _ in
                    promoteToAdmin(username: arr[sender.tag]["username"] as! String, groupId: groupId)
                    retrieve()
                }
                
                
                ac.addAction(cancelAction)
                ac.addAction(promoteUser)
                ac.addAction(removeUser)
                
                if let popoverPresentationController = ac.popoverPresentationController {
                    
                    popoverPresentationController.sourceRect = sender.frame
                    popoverPresentationController.sourceView = self.view
                    
                }

                present(ac, animated: true)
            }
        }
        
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
    }
    
    func unwind() {
        performSegue(withIdentifier: "backViewGroup", sender: self)
    }
    
    
    @IBAction func imagePressed(_ sender: UIButton) {
        imagePath = sender.tag
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddUserToGroup {
            vc.groupId = groupId
            vc.groupName = group
        }
        
        if let vc = segue.destination as? OthersAccount {
            vc.ownerId = arr[imagePath]["username"] as! String
        }
    }
    
}

class ViewGroupCell: UITableViewCell {
    @IBOutlet weak var img: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var isAdmin: UILabel!
    @IBOutlet weak var dots: UIButton!
    
    
}
