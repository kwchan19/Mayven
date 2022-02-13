//
//  AddUserToGroup.swift
//  Mayven
//
//  Created by Kevin Chan on 2021-03-27.
//

import UIKit

class AddUserToGroup: UIViewController {
 
    @IBOutlet weak var addUserBtn: UIButton!
    @IBOutlet weak var userExist: UILabel!
    @IBOutlet weak var username: UITextField!
    var groupId = String()
    var groupName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        username.textColor = .black
        userExist.isHidden = true
        addDoneButtonOnKeyboard()
    }
    
    @IBAction func addUser(_ sender: UIButton) {
        getUserProfile(userId: username.text!) { returnData in
            if(returnData.isEmpty) {
                self.userExist.isHidden = false
            }
            else {
                self.userExist.isHidden = true
                let name = returnData["name"] as! String
                addUserToGroup(username: self.username.text!, groupId: self.groupId, name: name, groupName: self.groupName)
                self.dismiss(animated: true, completion: .none)
                viewGroup.retrieve()
            }
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

        username.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        username.resignFirstResponder()
    }
    
}
