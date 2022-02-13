//
//  FirebaseAddPost.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-27.
//

import UIKit
import Firebase
import FirebaseFunctions
var functions = Functions.functions()

func firebaseAddPost(program: String, user: [String: String], text: String, type: String, image: UIImage, thumbnailImage: UIImage, link: String, completionHandler:@escaping([String: Any])->Void) {
    let ref = database.collection("Posts").document()
    
    var temp = [String: Any]()
    let time = lround(Date().timeIntervalSince1970)
    
    temp["ownerName"] = user["name"]!
    temp["ownerId"] = user["username"]!
    temp["schoolId"] = user["school"]!
    temp["programCode"] = program
    temp["text"] = text
    temp["replies"] = [user["username"]!]
    temp["reports"] = []
    temp["replyCount"] = 0
    temp["timestamp"] = Double(time)
    temp["likes"] = 0
    temp["usersLiked"] = []
    temp["lastAction"] = "post"
    temp["lastActionTime"] = Double(time)
    temp["postType"] =  "post"
    temp["docId"] = ref.documentID
    temp["type"] = type
    temp["link"] = link
    
    DispatchQueue.main.async {
        if(type == "image") {
            uploadPostImage(thumbnailImage: thumbnailImage, image: image, docId: ref.documentID)
        }
            
        ref.setData([
            "ownerName": user["name"]!,
            "ownerId": user["username"]!,
            "schoolId": user["school"]!,
            "programCode": program,
            "text": text,
            "replies": [user["username"]!],
            "reports": [],
            "replyCount": 0,
            "timestamp": time,
            "likes": 0,
            "usersLiked": [],
            "lastAction": "post",
            "lastActionTime": time,
            "type": type,
            "link": link
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
            else {
                Messaging.messaging().subscribe(toTopic: ref.documentID) { error in
                    print("Subscribed to ", ref.documentID)
                    cloudNotifications.append(ref.documentID)
                }
                completionHandler(temp)
            }
        }
    }
}

func firebaseIncrementReportPost(docId: String, user: [String: String]) {
    database.collection("Posts").document(docId).updateData([
        "reports": FieldValue.arrayUnion([user["username"]!]),
        "lastAction": "report",
        "lastActionTime": Int(Date().timeIntervalSince1970)
    ])
}

func firebaseIncrementReportReply(docId: String, replyId: String, user: [String: String]) {
    database.collection("Posts").document(docId).collection("Replies").document(replyId).updateData([
        "reports": FieldValue.arrayUnion([user["username"]!]),
    ])
}

func firebaseSendReportPost(docId: String, postOwner: String, text: String) {
    database.collection("Reports").addDocument(data: [
        "ownerId": postOwner,
        "text": text,
        "type": "original"
    ]){ err in
        if let err = err {
            print("Error adding document: \(err)")
        }
        else {
            firebaseDeletePost(docId: docId)
        }
    }
}

func firebaseSendReportReply(docId: String, replyId: String, postOwner: String, text: String, user: [String: String], isMore: Bool) {
    database.collection("Reports").addDocument(data: [
        "ownerId": postOwner,
        "text": text,
        "type": "reply"
    ]){ err in
        if let err = err {
            print("Error adding document: \(err)")
        }
        else {
            firebaseDeleteReply(docId: docId, replyId: replyId, user: user, isMore: isMore)
        }
    }
}

func firebaseDeletePost(docId: String) {
    database.collection("Posts").document(docId).delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        } else {
            print("Document successfully removed!")
            
            deletePostImage(docId: docId)
        }
    }
}



func firebaseDeleteReply(docId: String, replyId: String, user: [String: String], isMore: Bool) {
    database.collection("Posts").document(docId).collection("Replies").document(replyId).delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        } else {
            print("Document successfully removed!")
            
            let messageRef = database.collection("Posts").document(docId)
            
            if(isMore == true) {
                messageRef.updateData([
                    "replyCount": FieldValue.increment(Int64(-1))
                ])
            }
            else {
                messageRef.updateData([
                    "replies": FieldValue.arrayRemove([user["username"]!]),
                    "replyCount": FieldValue.increment(Int64(-1))
                ])
                
                Messaging.messaging().unsubscribe(fromTopic: docId) { error in
                    print("Unsubscribed from", docId)
                }
            }
            
            
        }
    }
}

func firebaseAddReply(user: [String: String], text: String, originalPost: String, type: String) {
    let ref = database.collection("Posts").document(originalPost).collection("Replies").document()
         ref.setData([
             "originalPost": originalPost,
             "ownerName": user["name"]!,
             "ownerId": user["username"]!,
             "text": text,
             "type": "reply",
             "reports": [],
             "timestamp": lround(Date().timeIntervalSince1970)
         ]) { err in
             if let err = err {
                 print("Error adding document: \(err)")
             } else {
                Messaging.messaging().subscribe(toTopic: ref.documentID) { error in
                    print("Subscribed to ", ref.documentID)
                    cloudNotifications.append(ref.documentID)
                }
                database.collection("Posts")
                    .document(originalPost)
                    .updateData([
                        "replies": FieldValue.arrayUnion([user["username"]!]),
                        "replyCount": FieldValue.increment(Int64(1)),
                        "lastAction": "reply",
                        "lastActionTime": Int(Date().timeIntervalSince1970)
                ])
                
                functions.httpsCallable("webhookNew").call(["docId": originalPost, "title": "Mayven", "message": user["name"]! + " has replied to a post"]) { (result, error) in
                  if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let message = error.localizedDescription
                        print(message)
                    }
                    // ...
                  }
                  else {
                    detailView.noRefresh()
                  }
                }
                 
                UIApplication.shared.applicationIconBadgeNumber = 0
                //forumView.refreshData()
             }
         }
}

func firebaseLikes(user: [String: String], postId: String) {
    let messageRef = database.collection("Posts").document(postId)
    messageRef.updateData([
        "usersLiked": FieldValue.arrayUnion([user["username"]!]),
        "likes": FieldValue.increment(Int64(1)),
        "lastAction": "likes",
        "lastActionTime": Int(Date().timeIntervalSince1970)
    ])
}

func firebaseUnlike(user: [String: String], postId: String) {
    let messageRef = database.collection("Posts").document(postId)
    
    messageRef.updateData([
        "usersLiked": FieldValue.arrayRemove([user["username"]!]),
        "likes": FieldValue.increment(Int64(-1)),
        "lastAction": "likes",
        "lastActionTime": Int(Date().timeIntervalSince1970)
    ])
}

/*func firebaseCreateGroup(ownerId: String, members: [String], name: String, type: String) -> String  {
    let ref = database.collection("ChatGroups")
    ref.addDocument(data: [
        "ownerId": ownerId,
        "admins": [],
        "members": members,
        "name": name,
        "type": type
    ])
}
*/
 
func incrementNotificationCount(user: [String: String]) {
    let messageRef = database.collection("Users").document(user["username"]!)
    messageRef.updateData([
        "lastNotifications": FieldValue.increment(Int64(1)),
        "lastTimestamp": Int(Date().timeIntervalSince1970)
    ])
}

func setNotificationCount(user: [String: String], count: Int) {
    let messageRef = database.collection("Users").document(user["username"]!)
    messageRef.updateData([
        "lastNotifications": count,
        "lastTimestamp": Int(Date().timeIntervalSince1970)
    ])
}

func removeUserFromGroup(username: String, groupId: String) {
    let groupRef = database.collection("ChatGroups").document(groupId)
    Database.database().reference().child("Notifications").queryOrdered(byChild: "parentUser").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { snapshot in
        print("THIS RAN 1")
        for child in snapshot.children {
            let snap = child as! DataSnapshot
            let dict = snap.value as! [String: Any]
            print("THIS RAN 2")
            print(dict["gName"] as! String, " = ", groupId)
            if(dict["gName"] as! String == groupId) {
                
                let unreadCountRef = snap.ref
                unreadCountRef.removeValue()
                groupRef.updateData([
                    "admins": FieldValue.arrayRemove([username]),
                    "members": FieldValue.arrayRemove([username])
                ])
            }
        }
    })
    // Remove from RealtimeDatabase
}

func addUserToGroup(username: String, groupId: String, name: String, groupName: String) {
    let groupRef = database.collection("ChatGroups").document(groupId)
    
    groupRef.updateData(
        [
            "members": FieldValue.arrayUnion([username])
        ])
    
    let ref = Database.database().reference()
    ref.child("Notifications").childByAutoId().setValue(
        [
            "parentUser": username,
            "gName": groupId,
            "unseenMessage": 0,
            "timestamp": Int(Date().timeIntervalSince1970),
            "lastMessage": "You have been added to the group",
            "lastUser": username
        ])
    
    sendNotifications(chatId: groupId, username: username, chatName: groupName, name: name)
}

func addUserToDM(username: String, groupId: String) {
    let groupRef = database.collection("ChatGroups").document(groupId)
    
    groupRef.updateData(
        [
            "members": FieldValue.arrayUnion([username])
        ])
    
    let ref = Database.database().reference()
    ref.child("Notifications").childByAutoId().setValue(
        [
            "parentUser": username,
            "gName": groupId,
            "unseenMessage": 0,
            "timestamp": Int(Date().timeIntervalSince1970),
            "lastMessage": "You have been added to the group",
            "lastUser": username
        ])
}

func promoteToAdmin(username: String, groupId: String) {
    let messageRef = database.collection("ChatGroups").document(groupId)
    messageRef.updateData([
        "admins": FieldValue.arrayUnion([username])
    ])
}

func demoteFromAdmin(username: String, groupId: String) {
    let messageRef = database.collection("ChatGroups").document(groupId)
    messageRef.updateData([
        "admins": FieldValue.arrayRemove([username])
    ])
}

func deleteChatGroup(groupId: String) {
    let groupRef = database.collection("ChatGroups").document(groupId)
    groupRef.delete()
    Database.database().reference().child("Notifications").queryOrdered(byChild: "gName").queryEqual(toValue: groupId).observeSingleEvent(of: .value, with: { snapshot in
        for child in snapshot.children {
            let snap = child as! DataSnapshot
            let unreadCountRef = snap.ref
            unreadCountRef.removeValue()
        }
    })
}

func deleteRestChatGroups(username: String) {
    print("Worked until here")
    
    Database.database().reference().child("Notifications").queryOrdered(byChild: "parentUser").queryEqual(toValue: username).observeSingleEvent(of: .value, with: { snapshot in
        var count = 1
        
        if snapshot.childrenCount == 0 {
            database.collection("Users").document(username).delete() { err in
                if let err = err {
                    print("error: ", err)
                }
                else {
                    deleteUserThumbnail(username: username)
                    let user = Auth.auth().currentUser
                    firebaseLogout()
                    user?.delete { error in
                        if let error = error {
                            print("error: ", error)
                        }
                        else {
                            print("success")
                        }
                    }
                }
                
            }
        }
        else {
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let unreadCountRef = snap.ref
                unreadCountRef.removeValue()
                
                if(count == snapshot.childrenCount) {
                    database.collection("Users").document(username).delete() { err in
                        if let err = err {
                            print("error: ", err)
                        }
                        else {
                            deleteUserThumbnail(username: username)
                            let user = Auth.auth().currentUser
                            firebaseLogout()
                            user?.delete { error in
                                if let error = error {
                                    print("error: ", error)
                                }
                                else {
                                    print("success")
                                }
                            }
                        }
                        
                    }
                      
                }
                
                count += 1
            }
        }
    })
    
    
}

func blockUser(username: String, user: [String: String]) {
    let messageRef = database.collection("Users").document(user["username"]!)
    messageRef.updateData([
        "blockedUsers": FieldValue.arrayUnion([username])
    ])
    blockedUsers.append(username)
}

func unblockUser(username: String, user: [String: String]) {
    let messageRef = database.collection("Users").document(user["username"]!)
    messageRef.updateData([
        "blockedUsers": FieldValue.arrayRemove([username])
    ])
    
    let index = blockedUsers.firstIndex(of: username)
    blockedUsers.remove(at: index!)
}

func deleteAccount(username: String) {
    database.collection("ChatGroups")
        .whereField("members", arrayContains: username)
        .getDocuments() { (querySnapshot, err) in
            
        if let err = err {
            print("Error getting documents: \(err)")
        }
        else {
            if(!querySnapshot!.documents.isEmpty) {
                var count = 1
                for documentd in querySnapshot!.documents {
                    var temp = documentd.data()
                    temp["docId"] = documentd.documentID
                    
                    if(temp["ownerId"] as! String == username) {
                        deleteChatGroup(groupId: temp["docId"] as! String)
                    }
                    else {
                        database.collection("ChatGroups").document(temp["docId"] as! String).updateData([
                            "members": FieldValue.arrayRemove([username]),
                            "admins": FieldValue.arrayRemove([username])
                        ])
                        
                    }
                    
                    if(count == querySnapshot?.documents.count) {
                        deleteRestChatGroups(username: username)
                    }
                    
                    count += 1
                }
            }
        }
    }
    
}

func deleteUserThumbnail(username: String) {
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let original = storageRef.child(username + ".jpeg")
    let thumbnail =  storageRef.child("Thumbnail/" + username + ".jpeg")

    // Delete the file
    original.delete { error in
      if let error = error {
        print("Failed to delete, ", error)
        // Uh-oh, an error occurred!
      } else {
        // File deleted successfully
        thumbnail.delete { error in
          if let error = error {
            print("Failed to delete, ", error)
            // Uh-oh, an error occurred!
          } else {
            // File deleted successfully
          }
        }
      }
    }
}

func deletePostImage(docId: String) {
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let original = storageRef.child("Post/" + docId + ".jpeg")
    let thumbnail =  storageRef.child("Post/Thumbnail/" + docId + ".jpeg")

    // Delete the file
    original.delete { error in
      if let error = error {
        print("Failed to delete, ", error)
        // Uh-oh, an error occurred!
      } else {
        // File deleted successfully
        thumbnail.delete { error in
          if let error = error {
            print("Failed to delete, ", error)
            // Uh-oh, an error occurred!
          } else {
            // File deleted successfully
          }
        }
      }
    }
}
