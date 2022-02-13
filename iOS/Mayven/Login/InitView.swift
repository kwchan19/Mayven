//
//  InitView.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-25.
//

import UIKit
import Firebase

class InitView: UIViewController {

    @IBOutlet weak var selectSchool: UITextField!
    fileprivate let pickerView = ToolbarPickerView()
    @IBOutlet weak var createAcc: UIButton!
    
    var schools: [[String: Any]] = [[String: Any]]()
    var schoolId = ""
    var emailExtension = ""
    var loginOrRegister = ""
    
    @IBAction func nextButton(_ sender: UIButton) {
        if(selectSchool.text == "" || selectSchool.text == nil || schoolId == "") {
            let alert = UIAlertController(title: "Cannot proceed to registration", message: "Select your school to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        if(selectSchool.text == "" || selectSchool.text == nil) {
            let alert = UIAlertController(title: "Cannot proceed to login", message: "Select your school to continue", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schoolId = ""
        
        selectSchool.layer.cornerRadius = 7
        selectSchool.layer.borderWidth = 1.0
        selectSchool.layer.borderColor = UIColor.systemGray3.cgColor
        createAcc.layer.cornerRadius = 7
        selectSchool.inputView = pickerView
        selectSchool.inputAccessoryView = pickerView.toolbar
        
        selectSchool.attributedPlaceholder = NSAttributedString(string: "Select your school", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.toolbarDelegate = self
        self.pickerView.reloadAllComponents()

        let database = Firestore.firestore()
        
        database.collection("Schools").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    var temp = document.data()
                    let id = document.documentID
                    temp["id"] = id
                    self.schools.append(temp)
                }
            }
            self.pickerView.reloadAllComponents()
        }
    }
}


extension InitView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        schoolId = schools[row]["id"] as! String
        emailExtension = schools[row]["emailExtension"] as! String
        let school = schools[row]["name"] //as? [[String: Any]]
        return school as? String
    }
    
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.schoolId = schools[row]["id"] as! String
        self.selectSchool.text = schools[row]["name"] as? String
        self.emailExtension = schools[row]["emailExtension"] as! String
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        self.schoolId = schools[row]["id"] as! String
        self.selectSchool.text = schools[row]["name"] as? String
        self.emailExtension = schools[row]["emailExtension"] as! String
            
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 400))
        label.lineBreakMode = .byWordWrapping;
        label.textAlignment = .center
        label.font = label.font.withSize(14)
        label.numberOfLines = 0
        label.text = schools[row]["name"] as? String
        label.sizeToFit()
        return label;
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ProgramView {
            // The issue with this is it won't be updated
            vc.name = selectSchool.text!
            vc.emailExtension = emailExtension
            vc.schoolId = schoolId
        }
        
        if let vc = segue.destination as? LoginView {
            // The issue with this is it won't be updated
            vc.schoolId = schoolId
            vc.name = selectSchool.text!
            vc.emailExtension = emailExtension
            vc.yearEntered = ""
            vc.userName = ""
            vc.programCode = ""
           
        }
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
    }
}

extension InitView: ToolbarPickerViewDelegate {

    func didTapDone() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        self.selectSchool.text = self.schools[row]["name"] as? String
        self.selectSchool.resignFirstResponder()
    }

    func didTapCancel() {
        self.selectSchool.text = nil
        self.selectSchool.resignFirstResponder()
    }
}
