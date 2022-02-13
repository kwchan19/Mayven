//
//  TermsOfService.swift
//  Mayven
//
//  Created by Kevin Chan on 2021-04-21.
//

import Firebase

class TermsOfService: UIViewController {
    
    @IBOutlet weak var agreeBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        agreeBtn.layer.cornerRadius = 7
    }
    
    @IBAction func agreeBtn(_ sender: UIButton) {
        
        database.collection("Users").document(tempUserData["username"]!).updateData([
            "tos": true
        ])
        
        storeToCoreData(login: email, data: tempUserData, tos: true)
    }
    
}
