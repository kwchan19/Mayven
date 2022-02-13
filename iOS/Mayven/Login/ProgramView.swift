//
//  ProgramView.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-03-08.

import UIKit

class ProgramView: UIViewController, UIPickerViewDataSource, ToolbarPickerViewDelegate, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var programCode: UITextField!
    @IBOutlet weak var yearEntered: UITextField!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var user: UITextField!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    var currPicker = 0
    
    fileprivate let pickerView = ToolbarPickerView()
    
    var schoolId = String()
    var name = String()
    var emailExtension = String()
    var programCodes = [[String: String]]()
    var years = [String]()
    var program = String()
    var pressedOnce = true
    var isGood = false
    
    @IBAction func programCodePressed(_ sender: UITextField) {

    }
    
    @IBAction func yearEnteredPressed(_ sender: UITextField) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        programCode.addBottomBorder()
        
        yearEntered.addBottomBorder()

        
        user.addBottomBorder()
        
        userName.addBottomBorder()

        continueBtn.layer.cornerRadius = 7
 
        getProgramCodes()
        schoolName.text = name
        addDoneButtonOnKeyboard()
        addDoneButtonOnKeyboard2()
        
        program = ""
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.toolbarDelegate = self
        self.pickerView.reloadAllComponents()
        
        programCode.inputView = pickerView
        programCode.delegate = self
        programCode.inputAccessoryView = pickerView.toolbar
        
        yearEntered.inputView = pickerView
        yearEntered.delegate = self
        yearEntered.inputAccessoryView = pickerView.toolbar
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProgramView.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProgramView.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        programCode.attributedPlaceholder = NSAttributedString(string: "Enter your program code", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        yearEntered.attributedPlaceholder = NSAttributedString(string: "Enter the year you entered", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        userName.attributedPlaceholder = NSAttributedString(string: "Enter your display name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        user.attributedPlaceholder = NSAttributedString(string: "Enter your desired username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pressedOnce = true
        isGood = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === programCode {
            currPicker = 0
            pickerView.reloadAllComponents()
            // do something to termTextView
        } else if textField === yearEntered {
            // do something to definitionTextView
            currPicker = 1
            pickerView.reloadAllComponents()
        }
    }
    
    func getProgramCodes() {
        retrieveProgramCodes(schoolId: schoolId) { returnData in
            let tempProgram = returnData["programCodes"] as! [[String: String]]
            self.programCodes = tempProgram.sorted(by: { $0["name"]! < $1["name"]! })
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let yearString = dateFormatter.string(from: date)
            
            self.years.append(yearString)
            
            for i in (1...7) {
                let yearInt = Int(yearString)! - i
                self.years.append(String(yearInt))
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(currPicker == 0) {
            return programCodes.count
        }
        else {
            return years.count
        }
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindToInit", sender: self)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if(currPicker == 0) {
            program = programCodes[row]["code"]!
            let school = programCodes[row]["name"]!
            //  return school
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 400))
            label.lineBreakMode = .byWordWrapping;
            label.textAlignment = .center
            label.font = label.font.withSize(14)
            label.numberOfLines = 0
            label.text = school
            label.sizeToFit()
            return label;
        }
        else {
            let label = UILabel();
            label.lineBreakMode = .byWordWrapping;
            label.numberOfLines = 0;
            label.font = label.font.withSize(13)
            label.text = years[row]
            label.sizeToFit()
            return label;
            
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(currPicker == 0) {
            self.programCode.text = programCodes[row]["name"]!
        }
        else {
            self.yearEntered.text = years[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func didTapDone() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        if(currPicker == 0) {
            self.programCode.text = programCodes[row]["name"]!
            self.programCode.resignFirstResponder()
        }
        else {
            self.yearEntered.text = years[row]
            self.yearEntered.resignFirstResponder()
        }
    }
    
    func didTapCancel() {
        if(currPicker == 0) {
            self.programCode.resignFirstResponder()
        }
        else {
            self.yearEntered.resignFirstResponder()
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
        
        userName.inputAccessoryView = doneToolbar
    }
    
    func addDoneButtonOnKeyboard2(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction2))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        user.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        userName.resignFirstResponder()
    }
    
    @objc func doneButtonAction2(){
        user.resignFirstResponder()
    }
    
    @IBAction func nextBtn(_ sender: UIButton) {
        if(pressedOnce == true) {
            isGood = false
            let alert = UIAlertController(title: "Registration Failed", message: "Please enter all the fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            if(self.programCode.text == "" || self.yearEntered.text == "" || self.userName.text == "" || self.user.text == "") {
                self.present(alert, animated: true)
            }
            else {
                let characterSet:CharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
                if (self.user.text!.rangeOfCharacter(from: characterSet.inverted) != nil){
                    let alert2 = UIAlertController(title: "Registration Failed", message: "Your username cannot contain special characters", preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert2, animated: true)
                }
                if(self.userName.text!.trimmingCharacters(in: .whitespaces).count < 4 || self.userName.text!.trimmingCharacters(in: .whitespaces).count > 20) {
                    let alert2 = UIAlertController(title: "Registration Failed", message: "Your display name must be between 4 to 20 characters long", preferredStyle: .alert)
                    alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert2, animated: true)
                }
                if(self.user.text!.trimmingCharacters(in: .whitespaces).count >= 6 && self.user.text!.count <= 20) {
                    pressedOnce = false
                    getUserProfile(userId: self.user.text!.lowercased()) { returnData in
                        if(!returnData.isEmpty) {
                            let alert2 = UIAlertController(title: "Registration Failed", message: "The username is already taken. Please choose another one", preferredStyle: .alert)
                            alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert2, animated: true)
                        }
                        else {
                            
                            self.isGood = true
                            self.performSegue(withIdentifier: "toRegister", sender: self)
                        }
                    }
                    
                }
                else {
                    let alert4 = UIAlertController(title: "Registration Failed", message: "Your username must be between 6 to 20 characters long", preferredStyle: .alert)
                    alert4.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert4, animated: true)
                }
                
            }
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return isGood
    }
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                if(userName.isEditing || user.isEditing) {
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
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? RegisterView {
            vc.name = name
            vc.emailExtension = emailExtension
            vc.schoolId = schoolId
            vc.programCode = program
            vc.programName = programCode.text!
            vc.yearEntered = yearEntered.text!
            vc.userName = userName.text!.trimmingCharacters(in: .whitespaces)
            vc.user = user.text!.trimmingCharacters(in: .whitespaces).lowercased().filter { !$0.isWhitespace }
            
        }
    }
}

extension UITextField {
    func addBottomBorder(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)

        bottomLine.backgroundColor = UIColor(displayP3Red: 96/255, green: 176/255, blue: 244/255, alpha: 1).cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
    
   
}

