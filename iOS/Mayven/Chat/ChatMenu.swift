//
//  ChatMenu.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-29.
//

import UIKit
import Firebase
import SDWebImage

var chatMenu = ChatMenu()

class ChatMenu: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var refreshControl = UIRefreshControl()
    let ref = Database.database().reference()
    
    var ownerName = String()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        configureTableView()
       // getChatGroups()
        chatMenu = self
        tableView.refreshControl = refreshControl
        tableView.backgroundView = refreshControl
        self.refreshControl.addTarget(self, action: #selector(getChatGroups), for: UIControl.Event.valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isInChat = false
        var notifFlag = false
        for i in totalNotifications {
            if i != 0 {
                notifFlag = true
                break
            }
        }
        
        if notifFlag == false {
            if let tabItems = tabBarController?.tabBar.items {
                let tabItem = tabItems[1]
                tabItem.badgeValue = nil
                tabBarController?.reloadInputViews()
            }
        }
        tableView.reloadData()
    }

    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
            tableView.backgroundColor = .systemGray5
        }
        else {
            view.backgroundColor = .white
            tableView.backgroundColor = .white
        }
            
    }
    
    @objc func getChatGroups() {
        deleteCache()
        
        tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCells", for: indexPath) as! ChatGroupCells
        
        cell.groupImage.layer.cornerRadius = cell.groupImage.frame.size.height/2
        cell.groupImage?.clipsToBounds = true
        
        let lastMsg = lastMessages[indexPath.row] // FIX THIS PART

        cell.lastMessage.text = lastMsg

        if(totalNotifications[indexPath.row] != 0) {
            var msgCount = ""
            let returnMsg = totalNotifications[indexPath.row]
            
            if(returnMsg > 99) {
                msgCount = "99+"
            }
            else {
                msgCount = String(returnMsg)
            }
            
            cell.badge.isHidden = false
            cell.badge.setTitle(String(msgCount), for: .normal)
        }
        else {
            cell.badge.isHidden = true
        }
        
        var groupDocId = String()
        var url = ""
        
        print("Groups: ", groups[indexPath.row])
        
        if(groups[indexPath.row]["type"] as! String == "group") {
            groupDocId = groups[indexPath.row]["docId"] as! String
            url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/ChatGroups%2FThumbnail%2F" + groupDocId + ".jpeg?alt=media"
            cell.groupName.text = groups[indexPath.row]["name"] as? String

        }
        else {
            let members = groups[indexPath.row]["members"] as! [String]
            
            for i in members {
                if(i != userData["username"]!) {
                    groupDocId = i
                    url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/" + groupDocId + ".jpeg?alt=media&token=" + String(Int(Date().timeIntervalSince1970))
                    
                    cell.groupName.text = i
                    ownerName = i
                  
                }
            }
            
            if(url == "") {
                url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/"
                cell.groupName.text = "The user has left the chat"
            }
        }
        
        cell.groupImage?.sd_setBackgroundImage(with: URL(string: url)!, for: .normal, placeholderImage: UIImage(named: "placeholderImg"))
        cell.groupImage?.layoutIfNeeded()
        cell.groupImage?.subviews.first?.contentMode = .scaleAspectFill

    
        
        return cell
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
    }
    
    fileprivate func configureTableView() {
        tableView.removeExtraCellLines()
        tableView.separatorInset = UIEdgeInsets.zero
        //   tableView.separatorColor = .clear
        if traitCollection.userInterfaceStyle == .dark {
            tableView.backgroundColor = .systemGray5
            view.backgroundColor = .black
           // newPost.backgroundColor = .white
           // newPost.tintColor = .black
           // postContainer.backgroundColor = .white
           // postContainer.tintColor = .black
        }
        else {
            view.backgroundColor = .white
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatView {
            vc.chatId = groups[tableView.indexPathForSelectedRow!.row]["docId"] as! String//tempData[tableView.indexPathForSelectedRow!.row]["docId"] as!
            
            if(groups[tableView.indexPathForSelectedRow!.row]["type"] as! String == "group") {
                vc.group = groups[tableView.indexPathForSelectedRow!.row]["name"] as! String
            }
            else {
                vc.group = ownerName
            }
            
            vc.ownerId = groups[tableView.indexPathForSelectedRow!.row]["ownerId"] as! String
            vc.index = tableView.indexPathForSelectedRow!
            let admins = groups[tableView.indexPathForSelectedRow!.row]["admins"] as! [String]
            let members = groups[tableView.indexPathForSelectedRow!.row]["members"] as! [String]
            vc.members = members
            if(admins.contains(userData["username"]!)){
                vc.isAdmin = true
            }
            else {
                vc.isAdmin = false
            }
            vc.fromWhere = "ChatMenu"
            vc.type = groups[tableView.indexPathForSelectedRow!.row]["type"] as! String
            
            
        }
    }
}

class ChatGroupCells: UITableViewCell {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var badge: UIButton!
    @IBOutlet weak var groupImage: UIButton!
    @IBOutlet weak var lastMessage: UILabel!

}
