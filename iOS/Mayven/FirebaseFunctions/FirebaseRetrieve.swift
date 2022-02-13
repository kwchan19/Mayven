//
//  RetrieveUser.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-26.

import UIKit
import Firebase

func firebaseGetReplies(postId: String, completionHandler:@escaping([[String: Any]])->Void) {
    var returnData = [[String: Any]]()
    database.collection("Posts")
        .document(postId)
        .collection("Replies")
        .order(by: "timestamp", descending: true)
        .limit(to: 10)
        .getDocuments() { (document, err) in
            
            if(document!.documents.isEmpty) {
                completionHandler(returnData)
            }
            
            var count = 1
            
            for documentd in document!.documents {
                var temp = documentd.data()
                temp["docId"] = documentd.documentID
                temp["lastDocument"] = documentd
                
                if(!blockedUsers.contains(temp["ownerId"] as! String)) {
                    returnData.append(temp)
                }
                
                if(count == document!.documents.count) {
                    completionHandler(returnData)
                }
                count += 1
            }
        }
}

func firebaseLoadMoreReplies(postId: String, lastPost: Any, completionHandler:@escaping([[String: Any]])->Void) {
    var returnData = [[String: Any]]()
    database.collection("Posts")
        .document(postId)
        .collection("Replies")
        .order(by: "timestamp", descending: true)
        .start(afterDocument: lastPost as! DocumentSnapshot)
        .limit(to: 5)
        .getDocuments() { (document, err) in
            
            if(document!.documents.isEmpty) {
                completionHandler(returnData)
            }
            
            var count = 1
            
            for documentd in document!.documents {
                var temp = documentd.data()
                temp["docId"] = documentd.documentID
                temp["lastDocument"] = documentd
                
                if(!blockedUsers.contains(temp["ownerId"] as! String)) {
                    returnData.append(temp)
                }
                
                if(count == document!.documents.count) {
                    completionHandler(returnData)
                }
                
                count += 1
            }
            
            
        }
    
}

func firebaseGetPost(docId: String, completionHandler:@escaping([String: Any])->Void) {
    database.collection("Posts").document(docId).getDocument { (document, err) in
        if let document = document, document.exists {
            var dataDescription = document.data()
            dataDescription!["lastDocument"] = document
            completionHandler(dataDescription!)
        }
        else {
            print("Document does not exist")
            completionHandler([String: Any]())
        }
    }
}

func getUserThumbnail(userId: String, completionHandler:@escaping(String)->Void) {
    database.collection("Users").document(userId).getDocument { (document, err) in
        if let document = document, document.exists {
            let dataDescription = document.data()
            if((dataDescription?["thumbnailURL"]) != nil) {
                completionHandler(dataDescription!["thumbnailURL"] as! String)
            }
            else {
                completionHandler("empty")
            }
        }
        else {
            completionHandler("empty")
        }
    }
}

func retrievePost(program: String, schoolId: String, orderBy: String, completionHandler:@escaping([[String: Any]])->Void) {
    var returnData = [[ String: Any]]()
    database.collection("Posts")
        .whereField("schoolId", isEqualTo: schoolId)
        .whereField("programCode", isEqualTo: program)
        .order(by: orderBy, descending: true)
        .limit(to: 10)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                if(querySnapshot!.documents.isEmpty) {
                    completionHandler(returnData)
                }
                
                var count = 1
                
                for documentd in querySnapshot!.documents {
                    
                    var temp = documentd.data()
                    temp["docId"] = documentd.documentID
                    temp["postType"] = "post"
                    temp["lastDocument"] = documentd
                    
                    if(!blockedUsers.contains(temp["ownerId"] as! String)) {
                        returnData.append(temp)
                    }
                    if(count == querySnapshot!.documents.count) {
                        
                        if(orderBy == "timestamp") {
                            returnData = returnData.sorted(by: { $0["timestamp"] as! Int > $1["timestamp"] as! Int })
                        }
                        else {
                            returnData = returnData.sorted(by: { $0["likes"] as! Int > $1["likes"] as! Int})
                        }
                        
                      //  (by: { $0["timestamp"] as! Int > $1["timestamp"] as! Int })
                        
                        completionHandler(returnData)
                        
                    }
                    count += 1
                    
                    
                }
            }
        }
}

func retrievePostFrom(program: String, schoolId: String, orderBy: String, start: Any, completionHandler:@escaping([[String: Any]])->Void) {
    var returnData = [[ String: Any]]()
    database.collection("Posts")
        .whereField("schoolId", isEqualTo: schoolId)
        .whereField("programCode", isEqualTo: program)
        .order(by: orderBy, descending: true)
        .start(afterDocument: start as! DocumentSnapshot)
        .limit(to: 10)
        .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            }
            else {
                if(querySnapshot!.documents.isEmpty) {
                    completionHandler(returnData)
                }
                
                var count = 1
                
                for documentd in querySnapshot!.documents {
                    
                    var temp = documentd.data()
                    temp["docId"] = documentd.documentID
                    temp["postType"] = "post"
                    temp["lastDocument"] = documentd
                    if(!blockedUsers.contains(temp["ownerId"] as! String)) {
                        returnData.append(temp)
                    }
                    if(count == querySnapshot!.documents.count) {
                        completionHandler(returnData)
                    }
                    
                    count += 1
                    
                }
            }
        }
}

func retrieveProgramCodes(schoolId: String, completionHandler:@escaping([String: Any])->Void) {
    database.collection("Schools")
        .document(schoolId)
        .collection("Programs")
        .document("ProgramCodes")
        .getDocument { (document, err) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                completionHandler(dataDescription!)
            }
            else {
                completionHandler([String: Any]())
                print("Document does not exist")
            }
        }
}

func retrieveChatGroup(groupId: String, completionHandler:@escaping([String: Any])->Void) {
    database.collection("ChatGroups").document(groupId)
        .getDocument { (document, err) in
            if let document = document, document.exists {
                var dataDescription = document.data()
                dataDescription!["docId"] = document.documentID
               // print(dataDescription)
                completionHandler(dataDescription!)
            }
            else {
                completionHandler([String: Any]())
                print("Document does not exist")
            }
        }
    
}

func deleteCache() {
    if let _ = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String] {
        print("CACHE REMOVED")
        UserDefaults.standard.removeObject(forKey: "ImageCache")
    }
}

func loadImage(urlString: String, completionHandler: @escaping(String, UIImage?)->Void) {
    if let dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String] {
        if let path = dict[urlString] {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                // print("Image is the same in cache")
                let img = UIImage(data: data)
                completionHandler(urlString, img)
                return
            }
            else {
                //  print("Image is different in cache")
            }
        }
    }
    
    guard let url = URL(string: urlString) else { return }
    let task = URLSession.shared.dataTask(with: url) { (data, response, error)
        in
        guard error == nil else {
            return
            
        }
        guard let d = data else {
            return
            
        }
        
        DispatchQueue.main.async {
            if let image = UIImage(data: d) {
                //  print("Image was not cached")
                cacheImage(urlString: urlString, img: image)
                completionHandler(urlString, image)
            }
            else {
                completionHandler(urlString, nil)
            }
        }
    }
    task.resume()
}

func cacheImage(urlString: String, img: UIImage) {
    let path = NSTemporaryDirectory().appending(UUID().uuidString)
    let url = URL(fileURLWithPath: path)
    let data = img.jpegData(compressionQuality: 0.5)
    try? data?.write(to: url)
    var dict = UserDefaults.standard.object(forKey: "ImageCache") as? [String:String]
    if dict == nil {
        dict = [String: String]()
    }
    dict![urlString] = path
    UserDefaults.standard.set(dict, forKey: "ImageCache")
}

func loadImageWithoutCache(urlString: String, completionHandler: @escaping(String, UIImage?)->Void) {
    guard let url = URL(string: urlString) else { return }
    let task = URLSession.shared.dataTask(with: url) { (data, response, error)
        in
        guard error == nil else {
            return
            
        }
        guard let d = data else {
            return
        }
        
        DispatchQueue.main.async {
            if let image = UIImage(data: d) {
                //  print("Image was not cached")
                //  cacheImage(urlString: urlString, img: image)
                completionHandler(urlString, image)
            }
            else {
                completionHandler(urlString, nil)
            }
        }
    }
    task.resume()
}

func getNotificationCount(user: [String: String], completionHandler:@escaping(Int)->Void) {
    database.collection("Users")
        .document(user["username"]!)
        .getDocument { (document, err) in
            if let document = document, document.exists {
                let dataDescription = document.data()!
                completionHandler(dataDescription["lastNotifications"] as! Int)
            }
        }
}


func getGroup(groupId: String, completionHandler:@escaping([[String: Any]])->Void) {
    database.collection("ChatGroups")
        .document(groupId)
        .getDocument { (document, err) in
            if let document = document, document.exists {
                let dataDescription = document.data()!
                var admins = dataDescription["admins"] as! [String]
                var members = dataDescription["members"] as! [String]
                
                var retArr = [[String: Any]]()
                var totalMembers = [[String: Any]]()
                
                admins = admins.sorted(by: { $0.lowercased() < $1.lowercased() })

                members = members.sorted(by: { $0.lowercased() < $1.lowercased() })

                for i in admins {
                    if(i != dataDescription["ownerId"] as! String) {
                        totalMembers.append([
                            "username": i,
                            "admin": true
                        ])
                    }
                }
                  
                for x in members {
                    if(!admins.contains(x)) {
                        totalMembers.append([
                            "username": x,
                            "admin": false
                        ])
                        
                    }
                }
                
                if(dataDescription["ownerId"] as! String != "") {
                
                    totalMembers.insert([
                        "username": dataDescription["ownerId"] as! String,
                        "admin": true
                    ], at: 0)
                    
                }
                
                var temp2 = [[String: Any]]()
                
                for y in totalMembers {
                    var temp = y
                    
                    DispatchQueue.main.async {
                        getUserProfile(userId: y["username"] as! String) { returnData2 in
                            temp["name"] = returnData2["name"] as! String
                            temp2.append(temp)
                            
                            if(temp2.count == totalMembers.count) {
                                
                                for totalData in totalMembers {
                                    var totalCount = 0
                                    for _ in 0...temp2.count {
                                        if(totalData["username"] as! String == temp2[totalCount]["username"] as! String) {
                                            retArr.append(temp2[totalCount])
                                            break
                                        }
                                        totalCount += 1
                                    }
                                    
                                }
                                
                                
                                
                                completionHandler(retArr)
                            }
                            
                          
                            
                        }
                    }
                    
                    
                    
                }
            }
        }
}

func getUserProfile(userId: String, completionHandler:@escaping([String: Any])->Void) {
    database.collection("Users")
        .document(userId)
        .getDocument { (document, err) in
            if let document = document, document.exists {
                let dataDescription = document.data()!
                completionHandler(dataDescription)
            }
            else {
                completionHandler([String: Any]())
            }
        }
    
}

func getUserLastTimestamp(userId: String, completionHandler:@escaping([String: Any])->Void) {
    var tempArr = [String: Any]()
    database.collection("Users")
        .document(userId)
        .getDocument { (document, err) in
            if let document = document, document.exists {
                let dataDescription = document.data()!
                tempArr["lastTimestamp"] = dataDescription["lastTimestamp"] as! Int
                tempArr["blockedUsers"] = dataDescription["blockedUsers"] as! [String]
                completionHandler(tempArr)
            }
            else {
                completionHandler(tempArr)
            }
        }
}

func checkRepliesLeft(docId: String, userId: String, completionHandler:@escaping(Bool)->Void) {
    database.collection("Posts").document(docId).collection("Replies").whereField("ownerId", isEqualTo: userId).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        }
        else {
            if(querySnapshot!.documents.count == 1) { // Remove from array
                completionHandler(false)
            }
            else { //
                completionHandler(true)
            }
        }
    }
}
