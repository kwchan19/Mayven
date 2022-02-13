//
//  TabBarView.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-30.
//

import Foundation
import UIKit
import Firebase

var totalNotifications = [Int]()
var notificationPage = Int()
var lastMessages = [String]()
var groups = [[String: Any]]()
var isInChat = false
var isInViewGroup = false
var cloudNotifications = [String]()
var blockedUsers = [String]()

var notificationListener: ListenerRegistration!
var chatGroupAddedListener: DatabaseQuery!
var chatGroupChangedListener: DatabaseQuery!
var chatGroupRemovedListener: DatabaseQuery!
var disabledListener: ListenerRegistration!

class TabBarView: UITabBarController {
    var ref: DatabaseReference!
    var userData = [String: String]()
    var notificationData = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startup = true
      //  firebaseLogout()
        userData = retrieveUserData()
        
        print("Tab bar viewed")
        
        if(notificationListener != nil || chatGroupAddedListener != nil || chatGroupChangedListener != nil || chatGroupRemovedListener != nil) {
            totalNotifications.removeAll()
            lastMessages.removeAll()
            groups.removeAll()
            isInChat = false
            isInViewGroup = false
            notificationPage = 0
            lastTimestamp = 0
            newArr.removeAll()
            
            notificationListener.remove()
            chatGroupAddedListener.removeAllObservers()
            chatGroupChangedListener.removeAllObservers()
            chatGroupRemovedListener.removeAllObservers()
            disabledListener.remove()
        }
        
        if(lastTimestamp <= 0 || blockedUsers.isEmpty) {
            getUserLastTimestamp(userId: userData["username"]!) { returnData in
                lastTimestamp = returnData["lastTimestamp"] as! Int
                blockedUsers = returnData["blockedUsers"] as! [String]
                self.returnFirstDocs()
                setNotificationCount(user: self.userData, count: totalNotifications.count)
            }
        }
        else {
            returnFirstDocs()
        }
        
        Messaging.messaging().subscribe(toTopic: userData["username"]!) { error in
            cloudNotifications.append(self.userData["username"]!)
        }
        
        getInitialNotifications()
        getNotifications()
        chatGroupAdded()
        chatGroupRemoved()
        listenToChat()
        userDisabled()
    }
    
    func userDisabled() {
        let listen = database.collection("Disabled")
            .whereField("user", isEqualTo: userData["username"]!)
            .whereField("flag", isEqualTo: "true")
        
        disabledListener = listen.addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("error: ", err)
            }
            else {
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(err!)")
                    return
                }
                snapshot.documentChanges.forEach { document in
                    if (document.type == .added || document.type == .modified) {
                        let tempData = document.document.data()
                        print(tempData)
                        
                        if(tempData["flag"] as! String == "true") {
                            print("User disabled")
                            firebaseLogout()
                        }
                    }
                }
            }
        }
    }
    
    func getNotifications() {
        let listen = database.collection("Posts")
            .whereField("replies", arrayContains: userData["username"]!)
            .whereField("lastAction", isEqualTo: "reply")
            .whereField("lastActionTime", isGreaterThanOrEqualTo: Int(Date().timeIntervalSince1970))
        
        notificationListener = listen.addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(err!)")
                    return
                }
                snapshot.documentChanges.forEach { documentd in
                    if (documentd.type == .added || documentd.type == .modified) {
                        print("Modified")
                        database.collection("Posts")
                            .document(documentd.document.documentID)
                            .collection("Replies")
                            .order(by: "timestamp", descending: true)
                            .limit(to: 1)
                            .getDocuments() { (querySnapshot2, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                }
                                else {
                                    for documentde in querySnapshot2!.documents {
                                        let temp = documentde.data()
                                        if(temp["ownerId"] as! String != self.userData["username"]!) {
                                            if(!blockedUsers.contains(temp["ownerId"] as! String)) {
                                                print("Appended")
                                                newArr.append(temp)

                                                notificationPage += 1
                                                
                                                self.tabBar.items![2].badgeValue = "●"
                                                self.tabBar.items![2].badgeColor = .clear
                                                self.tabBar.items![2].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for:.normal)
                                            // notificationView.reloadTable()
                                            }
                                        }
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
    
    func removeBadgeFromTabBarItem(atTabBarItemIndex tabBarItemIndex: Int) {
        if let tabBarItems = tabBarController?.tabBar.items {
            let tabBarItem = tabBarItems[tabBarItemIndex]
            tabBarItem.badgeValue = nil
        }
    }
    
    func returnFirstDocs() {
        newArr.removeAll()
        print("returnFirstDocs: ",  lastTimestamp)
        database.collection("Posts")
            .whereField("replies", arrayContains: userData["username"]!)
            //  .whereField("lastActionTime", isGreaterThan: lastTimestamp)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    guard let documentd = querySnapshot else {
                        print("Error fetching snapshots: \(err!)")
                        return
                    }
                    
                
                    
                    for i in documentd.documents {
                        let postOwner = i["ownerId"] as! String
                        Messaging.messaging().subscribe(toTopic: i.documentID) { error in
                           // print("Subscribed to ", i.documentID)
                            cloudNotifications.append(i.documentID)
                        }
                        
                        database.collection("Posts")
                            .document(i.documentID)
                            .collection("Replies")
                            .order(by: "timestamp", descending: false)
                            .whereField("timestamp", isGreaterThan: lastTimestamp)
                            .getDocuments() { (querySnapshot2, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                }
                                else {
                                    var flag = false
                                    var timestamp = 0
                                    for documentde in querySnapshot2!.documents {
                                        let temp = documentde.data()
                                        
                                        if(postOwner == self.userData["username"]!) {
                                            if((temp["ownerId"] as! String) != self.userData["username"]! && !blockedUsers.contains(temp["ownerId"] as! String)) {
                                                newArr.append(temp)
                                            }
                                        }
                                        else {
                                            if(((temp["ownerId"] as! String) == self.userData["username"]!) && flag == false) {
                                                timestamp = temp["timestamp"] as! Int
                                                flag = true
                                            }
                                            
                                            if(((temp["ownerId"] as! String) != self.userData["username"]!) && temp["timestamp"] as! Int > timestamp && flag == true && !blockedUsers.contains(temp["ownerId"] as! String)) {
                                                print(lastTimestamp, " < ",  timestamp)
                                                newArr.append(temp)
                                            }
                                        }
                                    }
                                    
                                    //getNotificationCount(user: self.userData) { returnData in
                                    if(newArr.count > 0) {
                                        self.tabBar.items![2].badgeValue = "●"
                                        self.tabBar.items![2].badgeColor = .clear
                                        self.tabBar.items![2].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for:.normal)
                                    }
                                    // }
                                }
                            }
                    }
                }
            }
    }
    
    func getInitialNotifications() {
        var flag = false
        var i = 0
        self.tabBar.items![1].badgeValue = nil
        self.tabBar.items![1].badgeColor = .clear
        self.tabBar.items![1].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for:.normal)
        
        groups.removeAll()
        totalNotifications.removeAll()
        lastMessages.removeAll()
        
        ref.child("Notifications")
            .queryOrdered(byChild: "parentUser")
            .queryEqual(toValue: userData["username"]!)
            .observeSingleEvent(of: .value, with: { snapshot in
                var temp = [[String: Any]]()
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    temp.append(snap.value as! [String: Any])
                }
                
                print(temp)
                temp = temp.sorted(by: { ($0["timestamp"] as! Int) < ($1["timestamp"] as! Int) })
                
                if(snapshot.childrenCount == 0) {
                    startup = false
                }
                
                DispatchQueue.main.async {
                    for dict in temp {
                        
                        
                        retrieveChatGroup(groupId: dict["gName"] as! String) { returnData in
                            groups.insert(returnData, at: i)
                            totalNotifications.insert(dict["unseenMessage"] as! Int, at: i)
                            if(dict["unseenMessage"] as! Int != 0) {
                                flag = true
                            }
                            
                            lastMessages.insert(dict["lastMessage"] as! String, at: i)
                            

                            
                            i += 1
                            if(snapshot.childrenCount == groups.count) {
                                startup = false
                                if(flag == true) {
                                    self.tabBar.items![1].badgeValue = "●"
                                    self.tabBar.items![1].badgeColor = .clear
                                    self.tabBar.items![1].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for:.normal)
                                }
                                if(self.selectedIndex == 1) {
                                    chatMenu.tableView.reloadData()
                                    chatMenu.refreshControl.endRefreshing()
                                }
                            }
                        }
                    }
                }
            })
    }
    
    func listenToChat() {
        chatGroupChangedListener = ref.child("Notifications").queryOrdered(byChild: "parentUser").queryEqual(toValue: userData["username"]!)
        chatGroupChangedListener.observe(.childChanged) { (snapshot) in
            print("ADDED TO GROUP")
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            if(!blockedUsers.contains(postDict["lastUser"] as! String)) {
                var i = 0
                for item in groups {
                    if item["docId"] as! String == postDict["gName"] as! String {
                        if(postDict["unseenMessage"] as! Int != 0 || postDict["lastUser"] as! String == self.userData["username"]!) {
                            print("THIS HAPPENED")
                            let element = groups.remove(at: i)
                            groups.insert(element, at: 0)
                            
                            totalNotifications.remove(at: i)
                            totalNotifications.insert(postDict["unseenMessage"] as! Int, at: 0)
                            
                            
                            if(isInChat == true) {
                                totalNotifications[0] = 0
                            }
                            else {
                                //UIApplication.shared.applicationIconBadgeNumber += 1
                            }
                            
                            lastMessages.remove(at: i)
                            lastMessages.insert(postDict["lastMessage"] as! String, at: 0)
                        }
                    }
                    i += 1
                }
                
                if(postDict["unseenMessage"] as! Int != 0) {
                    self.tabBar.items![1].badgeValue = "●"
                    self.tabBar.items![1].badgeColor = .clear
                    self.tabBar.items![1].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for:.normal)
                }
                
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                let tabBarIndex = self.selectedIndex
                if(tabBarIndex == 1) {
                    chatMenu.tableView.reloadData()
                }
            }
        }
    }
    
    func chatGroupAdded() {
        chatGroupAddedListener = ref.child("Notifications").queryOrdered(byChild: "parentUser").queryEqual(toValue: userData["username"]!)
        chatGroupAddedListener.observe(.childAdded) { (snapshot) in
            if(startup == false) {
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                
                print("Group was added")
                
                
                
                totalNotifications.insert(0, at: 0)
                lastMessages.insert(postDict["lastMessage"] as! String, at: 0)
                
                print(lastMessages, totalNotifications)
                
                retrieveChatGroup(groupId: postDict["gName"] as! String) { returnData in
                    groups.insert(returnData, at: 0)
                    
                    if(self.selectedIndex == 1) {
                        chatMenu.tableView.reloadData()
                        chatMenu.refreshControl.endRefreshing()
                    }
                }
            }
        }
        
    }
    
    func chatGroupRemoved() {
        chatGroupRemovedListener = ref.child("Notifications").queryOrdered(byChild: "parentUser").queryEqual(toValue: userData["username"]!)
        chatGroupRemovedListener.observe(.childRemoved) { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            var i = 0
            for item in groups {
                
                if item["docId"] as! String == postDict["gName"] as! String {
                  //  if(postDict["unseenMessage"] as! Int != 0 || postDict["lastUser"] as! String == self.userData["username"]!) {
                        print("group removed HAPPENED")
                        
                        groups.remove(at: i)
                        
                        totalNotifications.remove(at: i)
                        
                        lastMessages.remove(at: i)
                        
                        print(lastMessages, totalNotifications)
                        
                        if(isInChat == true) {
                            
                            chatView.unwind()
                        }
                        
                        if(isInViewGroup == true) {
                            viewGroup.unwind()
                            chatView.unwind()
                        }
                    }
              //  }
                
                i += 1
            }
            let tabBarIndex = self.selectedIndex
            
            if(tabBarIndex == 1) {
                chatMenu.tableView.reloadData()
            }
            
        }
        
    }
}
/*
 listenForAdded() {#imageLiteral(resourceName: "simulator_screenshot_69A33998-5D45-42CB-B16F-85B4A7629B3E.png")
 
 
 /* for item in groups {
 if item["docId"] as! String == postDict["gName"] as! String {
 totalNotifications[i] = postDict["unseenMessage"] as! Int
 }
 i += 1
 }
 
 //  print("NOTIFS: ", totalNotifications)
 
 if(postDict["unseenMessage"] as! Int != 0) {
 self.tabBar.items![1].badgeValue = "●"
 self.tabBar.items![1].badgeColor = .clear
 self.tabBar.items![1].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for:.normal)
 }
 
 let generator = UIImpactFeedbackGenerator(style: .heavy)
 generator.impactOccurred()
 
 let tabBarIndex = self.selectedIndex
 
 if(tabBarIndex == 1) {
 chatMenu.tableView.reloadData()
 }*/
 
 }
 */

func unsubscribe() {
    Messaging.messaging().unsubscribe(fromTopic: "rnFlXHdJngmv0puldo10") { error in
        print("Unsubbed")
    }
    
    Messaging.messaging().unsubscribe(fromTopic: "FLqRFrbNG5iwqx9rCv8d") { error in
        print("Unsubbed")
    }
    
    Messaging.messaging().unsubscribe(fromTopic: "hK8YuiVGjY9ST2JYq4G2") { error in
        print("Unsubbed")
    }
    
    Messaging.messaging().unsubscribe(fromTopic: "Cc3xrlEfKK4HIQk7Gqus") { error in
        print("Unsubbed")
    }
    
    Messaging.messaging().unsubscribe(fromTopic: "kKeZfnKDgKoU6Oy7jpSU") { error in
        print("Unsubbed")
    }
    
    Messaging.messaging().unsubscribe(fromTopic: "X8I9x0w6o5P5VegCbY01") { error in
        print("Unsubbed")
    }
    
    Messaging.messaging().unsubscribe(fromTopic: "Fa4gyxd0j0vLhqgeQ9Y7") { error in
        print("Unsubbed")
    }
    
    Messaging.messaging().unsubscribe(fromTopic: "Fa4gyxd0j0vLhqgeQ9Y7") { error in
        print("Unsubbed")
    }
}

func setData() {
    
    var ref: DatabaseReference!
    ref = Database.database().reference()
    
    ref.child("Notifications").child("-MY1QakTgt8w_DfmE8Aw").setValue(
        [
            "parentUser": "mhassan43",
            "timestamp": 1618169719,
            "gName": "mYkM0ONNm1CRbPWjuEg1-BSD-2021",
            "unseenMessage": 0,
            "lastMessage": "",
            "lastUser": "mhassan43"
        ])
    
    ref.child("Notifications").child("-MY1T4Jx5Loe_PZazYwJ").setValue(
        [
            
            "parentUser": "mhassan43",
            "gName": "groupId",
            "unseenMessage": 0,
            "lastMessage": "",
            "lastUser": "mhassan43",
            "timestamp": 1618170369
        ])
    
    ref.child("Notifications").child("-MY1hR6i2iJ1zo-sa3Jv").setValue(
        [
            "parentUser": "mhassan43",
            "gName": "HlD3zyOs8MBEjROOfdsh",
            "unseenMessage": 0,
            "lastMessage": "",
            "lastUser": "mhassan43",
            "timestamp": 1618170367
        ])
}


extension UIApplication {
    func getPresentedViewController() -> UIViewController? {
        var presentViewController = UIApplication.shared.currentWindow?.rootViewController
        while let pVC = presentViewController?.presentedViewController
        {
            presentViewController = pVC
        }
        
        return presentViewController
    }
}
