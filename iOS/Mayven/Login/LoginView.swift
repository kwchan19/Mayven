//
//  LoginView.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-25.
//

import UIKit
import Firebase
import CoreData

class LoginView: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var schoolId = String()
    var name = String()
    var userName = String()
    var emailExtension = String()
    var programCode = String()
    var yearEntered = String()
    
    var programName = String()
    var user = String()
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.layer.cornerRadius = 7
        email.layer.borderWidth = 1.0
        email.layer.borderColor = UIColor.systemGray3.cgColor
        
        password.layer.cornerRadius = 7
        password.layer.borderWidth = 1.0
        password.layer.borderColor = UIColor.systemGray3.cgColor
        
        if traitCollection.userInterfaceStyle == .dark {
            schoolName.textColor = .white
        }
        else {
            schoolName.textColor = .systemGray
        }
        
        loginButton.layer.cornerRadius = 7
        
        email.setLeftPaddingPoints(10)
        password.setLeftPaddingPoints(10)
        schoolName.text = name.lowercased()
        password.isSecureTextEntry = true
        
        addDoneButtonOnKeyboard()
        addDoneButtonOnKeyboard2()
        
        email.attributedPlaceholder = NSAttributedString(string: "Enter your school email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginView.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginView.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            schoolName.textColor = .white
        }
        else {
            schoolName.textColor = .systemGray
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        performSegue(withIdentifier: "unwind", sender: self)
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        promptForAnswer(title: "Reset Password")
    }
    
    func promptForAnswer(title: String) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.textFields![0].placeholder = "Enter your email"
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [] _ in
        }
        
        ac.addAction(cancelAction)
        
        let submitAction = UIAlertAction(title: "Reset", style: .default) { [] _ in
            let addUser = ac.textFields![0].text!
            
            if(addUser.trimmingCharacters(in: .whitespaces) != "") {
                Auth.auth().sendPasswordReset(withEmail: addUser) { error in
                    if(error != nil) {
                        self.promptForAnswer(title: "The email does not exist")
                    }
                    else {
                        
                    }
                }
            }
            else {
                self.promptForAnswer(title: "Please enter a valid email")
            }
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    @IBAction func login(_ sender: UIButton) {
        let alert = UIAlertController(title: "Login Failed", message: "Your email or password is incorrect. Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let alert3 = UIAlertController(title: "Verify Email", message: "You have received a verification link in your email. Verify in order to login", preferredStyle: .alert)
        alert3.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        let login = email.text!
        
        if(login.trimmingCharacters(in: .whitespaces).count <= 1 || !login.contains("@")) {
            let alert4 = UIAlertController(title: "Login Failed", message: "Please enter a valid email", preferredStyle: .alert)
            alert4.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        else {
            if let range = login.range(of: "@") {
                var data = [
                    "classOf": yearEntered,
                    "name": userName,
                    "programCode": programCode,
                    "school": schoolId,
                    "schoolName": name,
                    "programName": programName,
                    "username": user
                ]
                let ext = login[range.upperBound...].trimmingCharacters(in: .whitespaces)
                print(ext, "=", emailExtension)
                if ext == emailExtension {
                    Auth.auth().signIn(withEmail: login, password: password.text!) { [self] authResult, error in
                        if(error != nil) {
                            self.present(alert, animated: true)
                        }
                        else {
                            if(authResult!.user.isEmailVerified == false) {
                                self.present(alert3, animated: true)
                            }
                            else {
                                database.collection("Users").whereField("email", isEqualTo: login).getDocuments() { (querySnapshot, err) in
                                    if let err = err {
                                        print("Error getting documents: \(err)")
                                    }
                                    else {
                                        
                                        for documentd in querySnapshot!.documents {
                                            let dataDescription = documentd.data()
                                            
                                            data["classOf"] = dataDescription["classOf"] as? String
                                            data["name"] = dataDescription["name"] as? String
                                            data["programCode"] = dataDescription["programCode"] as? String
                                            data["programName"] = dataDescription["programName"] as? String
                                            data["username"] = dataDescription["username"] as? String
                                            
                                            lastTimestamp = dataDescription["lastTimestamp"] as! Int
                                            
                                            let tos = dataDescription["tos"] as! Bool
                                            storeToCoreData(login: login, data: data, tos: tos)
                                            
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    let alert2 = UIAlertController(title: "Login Failed", message: "Please enter your school email", preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert2, animated: true)
                }
                
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
        
        email.inputAccessoryView = doneToolbar
    }
    @objc func doneButtonAction(){
        email.resignFirstResponder()
    }
    
    
    func addDoneButtonOnKeyboard2(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction2))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        password.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction2(){
        password.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/4
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

