//
//  AddUserToGroup.swift
//  Mayven
//
//  Created by Kevin Chan on 2021-05-25.
//

import UIKit
import Firebase

class AddToGroup: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGroups: UILabel!
    
    var adminGroups = [[String: Any]]()
    var userToAdd = String()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        configureTableView()
        
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemGray5

        }
        else {
            view.backgroundColor = .white
        }
        
        if(adminGroups.count == 0) {
            noGroups.isHidden = false
        }
        else {
            noGroups.isHidden = true
        }
    }
    
    fileprivate func configureTableView() {
        tableView.removeExtraCellLines()
        tableView.separatorInset = UIEdgeInsets.zero
        //   tableView.separatorColor = .clear
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemGray5

        }
        else {
            view.backgroundColor = .white
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adminGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addGroup", for: indexPath) as! AddToGroupCell
        
        cell.groupImg.layer.cornerRadius = cell.groupImg.frame.size.height/2
        cell.groupImg?.clipsToBounds = true

       
        let groupDocId = adminGroups[indexPath.row]["docId"] as! String
        let url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/ChatGroups%2FThumbnail%2F" + groupDocId + ".jpeg?alt=media"
        
        cell.groupImg?.sd_setImage(with: URL(string: url)!, placeholderImage: UIImage(named: "placeholderImg"))
        cell.groupImg?.layoutIfNeeded()
        cell.groupImg?.subviews.first?.contentMode = .scaleAspectFill
        cell.addBtn.tag = indexPath.row
        
        let members = adminGroups[indexPath.row]["members"] as! [String]
        
        if(members.contains(userToAdd)) {
            cell.addBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
            cell.addBtn.tintColor = .green
            cell.addBtn.isUserInteractionEnabled = false
        }
        else {
            cell.addBtn.setImage(UIImage(systemName: "plus"), for: .normal)
            cell.addBtn.tintColor = .label
            cell.addBtn.isUserInteractionEnabled = true
        }
        
        cell.groupName.text = adminGroups[indexPath.row]["name"] as? String
        return cell
    }
    
    @IBAction func addToGroupBtn(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        
        let alert = UIAlertController(title: "Add to Group", message: "Add this user to the group?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add to Group", style: .default, handler: { action in
            getUserProfile(userId: self.userToAdd) { returnData in
                if(returnData.isEmpty) {
                    //self.userExist.isHidden = false
                }
                else {
                    let name = returnData["name"] as! String
                    DispatchQueue.main.async {
                        addUserToGroup(username: self.userToAdd, groupId: self.adminGroups[indexPath.row]["docId"] as! String, name: name, groupName: self.adminGroups[indexPath.row]["name"] as! String)
                        
                        sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
                        sender.tintColor = .green
                        sender.isUserInteractionEnabled = false
                        
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.sourceView = self.view
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func exitPressed(_ sender: UIButton) {
      //  self.dismiss(animated: true, completion: {})
        self.navigationController?.popViewController(animated: true)
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
    
   
}


class AddToGroupCell: UITableViewCell {
    @IBOutlet weak var groupImg: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
}
