//
//  FirebaseFunctions.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-26.
//

import Firebase
import UIKit
import CoreData
import LinkPresentation

let database = Firestore.firestore()
let storyboard = UIStoryboard(name: "Main", bundle: nil)
let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
let termsOfService = storyboard.instantiateViewController(identifier: "TermsOfService")
var lastTimestamp = Int()
var email = String()
var userData = [String: String]()
var tempUserData = [String: String]()
var startup = true
var homeStartup = true

func storeToCoreData(login: String, data: [String: String], tos: Bool) {
    if(tos == false) {
        email = login
        tempUserData = data
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(termsOfService)
    }
    else {
        createNewCoreUser(login: login, data: data)
    }
}

func createNewCoreUser(login: String, data: [String: String]) {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        print("CoreData has been created")
        let context = appDelegate.persistentContainer.viewContext
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "User", in: context) else { return }
        let newValue = NSManagedObject(entity: entityDescription, insertInto: context)
        newValue.setValue(login, forKey: "userId")
        newValue.setValue(data["name"], forKey: "name")
        newValue.setValue(data["classOf"], forKey: "classOf")
        newValue.setValue(data["programCode"], forKey: "programCode")
        newValue.setValue(data["school"], forKey: "school")
        newValue.setValue(data["schoolName"], forKey: "schoolName")
        newValue.setValue(data["programName"], forKey: "programName")
        newValue.setValue(data["username"], forKey: "username")
        do {
            try context.save()
            
            var tempData = data
            tempData["userId"] = login
            userData = tempData
            homeStartup = true
            startup = true
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            
        } catch {
            print("Storing data Failed")
        }
    }
}

func setChatGroup(login: String, data: [String: String]) {
    let classOf = Int(data["classOf"]!)! + 4
    
    DispatchQueue.main.async {
        let docId = data["school"]! + "-" + data["programCode"]! + "-" + String(classOf)
        let groupName = data["programCode"]! + " - " + String(classOf)
        
        database.collection("Users").document(data["username"]!).setData([
            "classOf": data["classOf"]!,
            "name": data["name"]!,
            "programCode": data["programCode"]!,
            "programName": data["programName"]!,
            "school": data["school"]!,
            "schoolName": data["schoolName"]!,
            "username": data["username"]!,
            "blockedUsers": [],
            "lastTimestamp": Int(Date().timeIntervalSince1970),
            "email": login,
            "tos": false,
            "lastNotifications": 0
        ])
        
        database.collection("ChatGroups").document(docId).setData([
            "admins": [],
            "name": data["programCode"]! + " - " + String(classOf),
            "members": FieldValue.arrayUnion([data["username"]!]),
            "ownerId": "",
            "type": "group"
        ], merge: true)
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("Notifications").childByAutoId().updateChildValues(
            [
                "gName": docId,
                "parentUser": data["username"]!,
                "unseenMessage": 0,
                "timestamp": Int(Date().timeIntervalSince1970),
                "lastMessage": data["username"]! + " has joined the group",
                "lastUser": data["username"]!
            ])
        
        let resizedImage = resizeImage(image: UIImage(named: "ic_person")!, targetSize: CGSize.init(width: 300, height: 300))
        let resizedThumbnailImage = resizeImage(image: UIImage(named: "ic_person")!, targetSize: CGSize.init(width: 125, height: 125))
        uploadImage(thumbnailImage: resizedThumbnailImage, image: resizedImage, username: data["username"]!)
        
        
        let resizedImage2 = resizeImage(image: UIImage(named: "groupImage")!, targetSize: CGSize.init(width: 300, height: 300))
        let resizedThumbnailImage2 = resizeImage(image: UIImage(named: "groupImage")!, targetSize: CGSize.init(width: 125, height: 125))
        uploadToGroup(thumbnailImage: resizedThumbnailImage2, image: resizedImage2, groupId: docId)
        
        sendInitialGroupNotification(chatId: docId, username: data["username"]!, chatName: groupName, name: data["name"]!)
        
    }
}

func sendInitialGroupNotification(chatId: String, username: String, chatName: String, name: String) {
    var ref: DatabaseReference!
    ref = Database.database().reference()
    
    ref.child("Notifications").queryOrdered(byChild: "gName").queryEqual(toValue: chatId).observeSingleEvent(of: .value, with: { snapshot in
        print("Snapshot:", snapshot.childrenCount)
        for child in snapshot.children {
            let snap = child as! DataSnapshot
            let dict = snap.value as! [String: Any]
            let unreadCountRef = snap.ref
            
            unreadCountRef.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
                var currentCount = currentData.childData(byAppendingPath: "unseenMessage").value as? Int ?? 0
                currentCount += 1
                if(dict["parentUser"] as! String != username) {
                    currentData.childData(byAppendingPath: "unseenMessage").value = currentCount
                }
                currentData.childData(byAppendingPath: "lastUser").value = username
                currentData.childData(byAppendingPath: "lastMessage").value = name + " has joined the group"
                currentData.childData(byAppendingPath: "timestamp").value = Int(Date().timeIntervalSince1970)
                
                return TransactionResult.success(withValue: currentData)
                
            })
            
            let childName = dict["parentUser"] as! String
            
            if(childName != username) {
                functions.httpsCallable("webhookNew").call(["docId": childName, "title": chatName, "message": name + " has joined the group"]) { (result, error) in
                    if let error = error as NSError? {
                        if error.domain == FunctionsErrorDomain {
                            let message = error.localizedDescription
                            print(message)
                        }
                    }
                    if let text = result?.data as? String {
                        print("Result: ", text)
                        
                    }
                }
            }
        }
    })
}

func sendNotifications(chatId: String, username: String, chatName: String, name: String) {
    var ref: DatabaseReference!
    ref = Database.database().reference()
    var memberList = [String]()
    
    ref.child("Notifications").queryOrdered(byChild: "gName").queryEqual(toValue: chatId).observeSingleEvent(of: .value, with: { snapshot in
        var count = 1
        for child in snapshot.children {
            let snap = child as! DataSnapshot
            let dict = snap.value as! [String: Any]
            let unreadCountRef = snap.ref
            
            unreadCountRef.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
                var currentCount = currentData.childData(byAppendingPath: "unseenMessage").value as? Int ?? 0
                currentCount += 1
                memberList.append(dict["parentUser"] as! String)
                if(dict["parentUser"] as! String != username) {
                    currentData.childData(byAppendingPath: "unseenMessage").value = currentCount
                    
                }
                currentData.childData(byAppendingPath: "lastUser").value = username
                currentData.childData(byAppendingPath: "lastMessage").value = name + " has been added to the group"
                currentData.childData(byAppendingPath: "timestamp").value = Int(Date().timeIntervalSince1970)
                
                return TransactionResult.success(withValue: currentData)
                
            })
            
            
            
            if(count == snapshot.childrenCount) {
                print("This ran")
                functions.httpsCallable("chatNotifications").call(["title": chatName, "message": name + " has been added to the group", "memberList": memberList]) { (result, error) in
                    if let error = error as NSError? {
                        if error.domain == FunctionsErrorDomain {
                            let message = error.localizedDescription
                            print(message)
                        }
                    }
                    if let text = result?.data as? String {
                        print("Result: ", text)
                        
                    }
                }
            }
            
            count += 1
        }
        
    })
}


func retrieveUserData() -> [String: String]{
    var arr = [String: String]()
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<User>(entityName: "User")
        do {
            let results = try context.fetch(fetch)
            
            for result in results {
                arr["name"] = result.name
                arr["schoolName"] = result.schoolName
                arr["school"] = result.school
                arr["programCode"] = result.programCode
                arr["classOf"] = result.classOf
                arr["username"] = result.userId
                arr["programName"] = result.programName
                arr["username"] = result.username
                arr["userId"] = result.userId
                
                print("Retrieving: ", arr)
            }
        }
        catch {
            print("Cannot retrieve")
        }
    }
    return arr
    
}


func editName(email: String, name: String) {
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)
    let request = NSFetchRequest<NSFetchRequestResult>()
    request.entity = entity
    let predicate = NSPredicate(format: "userId = %@", email)
    request.predicate = predicate
    do {
        let results = try managedContext.fetch(request)
        
        print("RESULTS: ", results)
        
        let objectUpdate = results[0] as! NSManagedObject
        objectUpdate.setValue(name, forKey: "name")
        do {
            print("Saved user")
            try managedContext.save()
            
        }
        catch{
            print("Error saving user")
        }
    }
    catch {
        print("Error saving user")
    }
}


func deleteCoreData(){
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let context = appDelegate.persistentContainer.viewContext
    
    do
      {
        try context.execute(deleteRequest)
        appDelegate.saveContext()
        
      } catch let error as NSError {
        print(error)
      }
    
}

func uploadImage(thumbnailImage: UIImage, image: UIImage, username: String) {
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let imagePath = storageRef.child(username + ".jpeg")
    let thumbnailPath = storageRef.child("Thumbnail/" + username  + ".jpeg")
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    if let uploadData = image.jpegData(compressionQuality: 0.9) {
        imagePath.putData(uploadData, metadata: metadata) { (metadata, error) in
            if let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.45) {
                thumbnailPath.putData(thumbnailData, metadata: metadata) { (metadata, error) in
                    
                }
            }
        }
    }
}

func uploadPostImage(thumbnailImage: UIImage, image: UIImage, docId: String) {
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let imagePath = storageRef.child("Post/" + docId + ".jpeg")
    let thumbnailPath = storageRef.child("Post/Thumbnail/" + docId  + ".jpeg")
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    if let uploadData = image.jpegData(compressionQuality: 0.9) {
        imagePath.putData(uploadData, metadata: metadata) { (metadata, error) in
            if let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.45) {
                thumbnailPath.putData(thumbnailData, metadata: metadata) { (metadata, error) in
                
                }
            }
        }
    }
}

func uploadToGroup(thumbnailImage: UIImage, image: UIImage, groupId: String) {
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let imagePath = storageRef.child("ChatGroups/" + groupId + ".jpeg")
    let thumbnailPath = storageRef.child("ChatGroups/Thumbnail/" + groupId  + ".jpeg")
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    if let uploadData = image.jpegData(compressionQuality: 0.9) {
        imagePath.putData(uploadData, metadata: metadata) { (metadata, error) in
            if let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.45) {
                thumbnailPath.putData(thumbnailData, metadata: metadata) { (metadata, error) in
                    
                }
            }
        }
    }
}


func cache(metadata: LPLinkMetadata) {

    // Check if the metadata already exists for this URL
    do {
        guard retrieve(urlString: metadata.url!.absoluteString) == nil else {
            return
        }
        
        // Transform the metadata to a Data object and
        // set requiringSecureCoding to true
        let data = try NSKeyedArchiver.archivedData(
            withRootObject: metadata,
            requiringSecureCoding: true)
        
        // Save to user defaults
        UserDefaults.standard.setValue(data, forKey: metadata.url!.absoluteString)
    }
    catch let error {
        print("Error when caching: \(error.localizedDescription)")
    }
}

func retrieve(urlString: String) -> LPLinkMetadata? {

    do {
        // Check if data exists for a particular url string
        guard
            let data = UserDefaults.standard.object(forKey: urlString) as? Data,
            // Ensure that it can be transformed to an LPLinkMetadata object
            let metadata = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: LPLinkMetadata.self,
                from: data)
        else { return nil }
        return metadata
    }
    catch let error {
        print("Error when caching: \(error.localizedDescription)")
        return nil
    }
}

/*
 extension NSManagedObjectContext {
 public func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
 batchDeleteRequest.resultType = .resultTypeObjectIDs
 
 let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
 let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
 // try context.exec
 NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
 
 }
 
 }
 */
