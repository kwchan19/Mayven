//
//  RegisterView.swift
//  Mayven
//
//  Created by Kevin Chan on 2021-04-20.
//

import UIKit
import Firebase
import Foundation

class RegisterView: UIViewController {
    
    
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var secondPassword: UITextField!
    
    @IBOutlet weak var createAcc: UIButton!
    
    var schoolId = String()
    var name = String()
    var userName = String()
    var emailExtension = String()
    var programCode = String()
    var yearEntered = String()
    var programName = String()
    var user = String()
    var isGood = false
    var onlyOnce = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.layer.cornerRadius = 7
        email.layer.borderWidth = 1.0
        email.layer.borderColor = UIColor.systemGray3.cgColor
        
        password.layer.cornerRadius = 7
        password.layer.borderWidth = 1.0
        password.layer.borderColor = UIColor.systemGray3.cgColor
        

        secondPassword.layer.cornerRadius = 7
        secondPassword.layer.borderWidth = 1.0
        secondPassword.layer.borderColor = UIColor.systemGray3.cgColor
        
        if traitCollection.userInterfaceStyle == .dark {
            schoolName.textColor = .white
        }
        else {
            schoolName.textColor = .systemGray
        }
        
        createAcc.layer.cornerRadius = 7
        
        
        email.setLeftPaddingPoints(10)
        password.setLeftPaddingPoints(10)
        secondPassword.setLeftPaddingPoints(10)
        schoolName.text = name.lowercased()
        password.isSecureTextEntry = true
        secondPassword.isSecureTextEntry = true
        
        email.attributedPlaceholder = NSAttributedString(string: "Enter your school email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        password.attributedPlaceholder = NSAttributedString(string: "Enter your password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        secondPassword.attributedPlaceholder = NSAttributedString(string: "Re-enter your password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        
        addDoneButtonOnKeyboard()
        addDoneButtonOnKeyboard2()
        addDoneButtonOnKeyboard3()
        
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
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onlyOnce = true
        isGood = false
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToProgram", sender: self)
    }
    
    @IBAction func registerBtn(_ sender: UIButton) {
        if(onlyOnce == true) {
            let login = email.text!.trimmingCharacters(in: .whitespaces)
            isGood = false
            
            if(password.text! != secondPassword.text!) {
                let alert = UIAlertController(title: "Password Failed", message: "The passwords do not match. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            else {
                if(password.text!.count < 6 || secondPassword.text!.count < 6) {
                    let alert = UIAlertController(title: "Password Failed", message: "Your password must be 6 characters or greater.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                
                let data = [
                    "classOf": yearEntered,
                    "name": userName,
                    "programCode": programCode,
                    "school": schoolId,
                    "schoolName": name,
                    "programName": programName,
                    "username": user
                ]
                
                if let range = login.range(of: "@") {
                    let ext = login[range.upperBound...].trimmingCharacters(in: .whitespaces)
                    if ext == emailExtension {
                        
                        self.onlyOnce = false
                        Auth.auth().createUser(withEmail: login.lowercased(), password: password.text!) { authResult, error in
                            if let error = error as NSError? {
                                let alert = UIAlertController(title: "Registration Failed", message: "The email is already in use. Please enter another", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                                print("AUTH SIGNIN ERROR: ", error)
                                self.present(alert, animated: true)
                            }
                            else {
                                
                                let authUser = authResult?.user
                                authUser?.reload()
                                
                                if authUser != nil {
                                    authUser!.sendEmailVerification { (error) in
                                        if(error != nil) {
                                            print(error as Any)
                                        }
                                        else {
                                            self.isGood = true
                                            setChatGroup(login: self.email.text!, data: data)
                                     
                                            self.performSegue(withIdentifier: "toLogin", sender: sender)
                                        }
                                    }
                                }
                                else {
                                    self.isGood = true
                                    setChatGroup(login: self.email.text!, data: data)
                                    
                                    self.performSegue(withIdentifier: "toLogin", sender: sender)
                                }
                            }
                        }
                        
                        // }
                    }
                    else {
                        let alert2 = UIAlertController(title: "Registration Failed", message: "Please enter your school email", preferredStyle: .alert)
                        alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert2, animated: true)
                    }
                }
                else {
                    let alert2 = UIAlertController(title: "Registration Failed", message: "Please enter a valid email", preferredStyle: .alert)
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
    
    func addDoneButtonOnKeyboard3(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction3))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        secondPassword.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction3(){
        secondPassword.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                if(!email.isEditing) {
                    self.view.frame.origin.y -= keyboardSize.height/4
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return isGood
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? LoginView {
            vc.name = name
            vc.emailExtension = emailExtension
            vc.schoolId = schoolId
            vc.programCode = programCode
            vc.programName = programName
            vc.yearEntered = yearEntered
            vc.userName = userName
            vc.user = user
            
        }
    }
}
