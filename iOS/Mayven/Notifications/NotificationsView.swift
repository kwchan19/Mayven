//
//  NotificationsView.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-30.
//

import UIKit
import Firebase

var notificationView = NotificationsView()

var newArr = [[String: Any]]()

class NotificationsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var isTableEmpty: UILabel!
    
    var refreshControl = UIRefreshControl()
    
    var tbView = TabBarView()
    
    var arr = [[String: Any]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        notificationView = self
       // userData = retrieveUserData()
      //  getNotifications()
        configureTableView()
        tableView.refreshControl = refreshControl
        tableView.backgroundView = refreshControl
        
        setNotificationCount(user: userData, count: newArr.count)
    //
        self.refreshControl.addTarget(self, action: #selector(reloadTable), for: UIControl.Event.valueChanged)
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
    
    @objc func reloadTable() {
        newArr = newArr.sorted(by: { $0["timestamp"] as! Int > $1["timestamp"] as! Int })
        
        arr = newArr
        
        if(arr.count == 0) {
            isTableEmpty.isHidden = false
        }
        else {
            isTableEmpty.isHidden = true
        }

        tableView.reloadData()
        if let tabItems = tabBarController?.tabBar.items {
            // In this case we want to modify the badge number of the third tab:
            let tabItem = tabItems[2]
            tabItem.badgeValue = nil
        }
     //   setNotificationCount(user: self.userData, count: newArr.count)
        refreshControl.endRefreshing()
    }
    
    func appendToArr(appendArr: [String: Any]) {
        arr.append(appendArr)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        notificationPage = 0
        
        var total = 0
        
        if(newArr.count == 0) {
            isTableEmpty.isHidden = false
        }
        else {
            isTableEmpty.isHidden = true
        }
        
        for i in totalNotifications {
            if(i != 0) {
                total += 1
            }
        }
        
        if(total + notificationPage == 0) {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        else {
            UIApplication.shared.applicationIconBadgeNumber = total + notificationPage
        }
        
        reloadTable()
        
       // arr.removeAll()
    }
    
    
    fileprivate func configureTableView() {
        tableView.removeExtraCellLines()
        tableView.separatorInset = UIEdgeInsets.zero
        //   tableView.separatorColor = .clear
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
            tableView.backgroundColor = .systemGray5
           // newPost.backgroundColor = .white
           // newPost.tintColor = .black
           // postContainer.backgroundColor = .white
           // postContainer.tintColor = .black
        }
        else {
            view.backgroundColor = .white
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! NotificationsCell
        let currArr = arr[indexPath.row]
        var type = ""
        
        if(currArr["type"] as! String == "reply") {
            type = " has replied to a post"
        }

        cell.userImage?.layer.cornerRadius = cell.userImage.frame.size.width/2
        cell.userImage?.clipsToBounds = true
        cell.userImage?.contentMode = .scaleAspectFill
        
        
        let today = Date().timeIntervalSince1970
        let postTime = currArr["timestamp"] as? Double
        var elapsedTime = lround(today-postTime!)/60
        var timeSign = ""
        
        if(elapsedTime == 0) {
            timeSign = "s"
            elapsedTime = lround(today-postTime!)
        }
        else if(elapsedTime < 60){
            timeSign = "m"
        }
        else if(elapsedTime > 60 && elapsedTime < 1440) {
            elapsedTime = lround(Double(elapsedTime/60))
            timeSign = "h"
        }
        else if(elapsedTime > 1380 && elapsedTime < 525600) {
            elapsedTime = lround(Double(elapsedTime/1440))
            timeSign = "d"
        }
        else {
            elapsedTime = lround(Double(elapsedTime/525600))
            timeSign = "y"
        }
        
        let userId = currArr["ownerId"] as! String
        let url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + userId + ".jpeg?alt=media&token=" 
        
        
        cell.userImage?.sd_setBackgroundImage(with: URL(string: url)!, for: .normal, placeholderImage: UIImage(named: "ic_person"))
       
        
        cell.userImage?.layoutIfNeeded()
        cell.userImage?.subviews.first?.contentMode = .scaleAspectFill
        
        cell.title?.text = currArr["ownerName"] as! String + type
        cell.desc?.text = String(elapsedTime) + timeSign
        return cell
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindDelete(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailView {
            let str = (arr[tableView.indexPathForSelectedRow!.row]["originalPost"] as! String)
            vc.docId = str.trimmingCharacters(in: .whitespacesAndNewlines)
            vc.fromWhere = "notifications"

            if(newArr.count > 15 || arr.count > 15) {
                newArr.remove(at: tableView.indexPathForSelectedRow!.row)
                arr.remove(at: tableView.indexPathForSelectedRow!.row)
            }
            
            tableView.reloadData()
        }
    
    }
}


class NotificationsCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var userImage: UIButton!
    @IBOutlet weak var desc: UILabel!
    
}
