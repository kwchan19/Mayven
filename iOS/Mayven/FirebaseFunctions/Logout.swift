//
//  Logout.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-26.
//
import UIKit
import Firebase

func firebaseLogout() {
    let firebaseAuth = Auth.auth()
    do {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
        
        
        totalNotifications.removeAll()
        lastMessages.removeAll()
        groups.removeAll()
        isInChat = false
        isInViewGroup = false
        notificationPage = 0
        lastTimestamp = 0
        newArr.removeAll()
        startup = true
        //deleteCoreData()
        
        let userData2 = retrieveUserData()
        
        if(!userData2.isEmpty) {
            deleteCoreData()
            userData.removeAll()
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if(notificationListener != nil || chatGroupAddedListener != nil || chatGroupChangedListener != nil || chatGroupRemovedListener != nil) {
            notificationListener.remove()
            chatGroupAddedListener.removeAllObservers()
            chatGroupChangedListener.removeAllObservers()
            chatGroupRemovedListener.removeAllObservers()
            disabledListener.remove()
            
        }
        
        for i in cloudNotifications {
            Messaging.messaging().unsubscribe(fromTopic: i)
            print("Unsubscribed from: ", i)
            
        }
        
        blockedUsers.removeAll()
        cloudNotifications.removeAll()
        
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
        try firebaseAuth.signOut()
        
        
    }
    catch let signOutError as NSError {
        print ("Error signing out: %@", signOutError)
    }
}
