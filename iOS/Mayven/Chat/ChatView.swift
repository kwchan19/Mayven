//
//  ChatView.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-28.
//

import UIKit
import Firebase
import SDWebImage

var chatView = ChatView()

class ChatView: UIViewController, UITextViewDelegate {
    var dict:NSDictionary!
    var tempData = [[String: Any]]()
    var chatId = String()
    var group = String()
    var index = IndexPath()
    var type = String()
    var totalDays = 0
    var count = 0
    var totalPosts = 30
    var ownerId = String()
    var isAdmin = Bool()
    var startup = true
    var refreshControl = UIRefreshControl()
    var members = [String]()
    var fromWhere = String()
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var groupBtn: UIButton!
    
    @IBOutlet weak var ellipsisBtn: UIButton!
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var txtMsg: UITextView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewChat: UIView!
    @IBAction func exitPressed(_ sender: UIButton) {
        if(fromWhere == "ChatMenu") {
            dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    var ref: DatabaseReference!
    var chat: DatabaseQuery!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // addDoneButtonOnKeyboard()
        self.txtMsg.delegate = self
        txtMsg.layer.cornerRadius = 15.0
        configureTableView()
        tblChat.allowsSelection = false
        txtMsg.isScrollEnabled = false
        txtMsg.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let sizeToFitIn = CGSize(width: self.txtMsg.bounds.size.width-20, height: CGFloat(MAXFLOAT))
        let newSize = self.txtMsg.sizeThatFits(sizeToFitIn)
        self.textViewHeight.constant = newSize.height
        NotificationCenter.default.addObserver(self, selector: #selector(ChatView.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatView.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //userData = retrieveUserData()
        ref = Database.database().reference()
        ref.keepSynced(true)
        
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        
        startup = true
        
        listenToChat()
        getChatLogs(id: "", atValue: 0)
        
        chatView = self
        isInChat = true

        groupName.text = group
        
        print("GROUP NAME: ", group)
        
        

        /* let swipeLeftGesture=UISwipeGestureRecognizer(target: self, action: #selector(SwipeBack))
         swipeLeftGesture.direction = UISwipeGestureRecognizer.Direction.left
         view.addGestureRecognizer(swipeLeftGesture)*/
        let swipeRightGesture=UISwipeGestureRecognizer(target: self, action: #selector(SwipeBack))
        swipeRightGesture.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swipeRightGesture)
        
        tblChat.refreshControl = refreshControl
        tblChat.backgroundView = refreshControl
        
        self.refreshControl.addTarget(self, action: #selector(loadMore), for: UIControl.Event.valueChanged)
        
        if(type == "group") {
            ellipsisBtn.isHidden = true
            groupBtn.isHidden = false
        }
        else {
            ellipsisBtn.isHidden = false
            groupBtn.isHidden = true
        }
    }
    @IBAction func ellipsisPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Leave Chat?", message: "Would you like to leave the chat?", preferredStyle: .actionSheet)
       
        
        alert.addAction(UIAlertAction(title: "Leave Chat", style: .default, handler: { action in
            // Leave Chat
            let alert2 = UIAlertController(title: "Leave Chat", message: "Are you sure you want to leave the chat?", preferredStyle: .actionSheet)
                
            alert2.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                removeUserFromGroup(username: userData["username"]!, groupId: self.chatId)
                self.navigationController?.popViewController(animated: true)
                
            }))
            
            alert2.addAction(UIAlertAction(title: "No", style: .destructive, handler: { action in
                
            }))
            
            alert2.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    
            }))
            
            if let popoverPresentationController = alert2.popoverPresentationController {
                
                popoverPresentationController.sourceRect = sender.frame
                popoverPresentationController.sourceView = self.view
                
            }
            
            self.present(alert2, animated: true, completion: nil)
            
            
        }))
        
            
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        
        
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.sourceView = self.view
        }
        
        present(alert, animated: true)
    }
    
    @objc func loadMore() {
        // Load more data from
        // tempData[0]["docId"] as! String
        if(tempData.count > 0) {
            DispatchQueue.global().async {
                sleep(1)
                DispatchQueue.main.async {
                    self.getChatLogs(id: self.tempData[1]["docId"] as! String, atValue: self.tempData[1]["timePosted"] as! Int)
                    self.refreshControl.endRefreshing()
                }
            }
        }
        else {
            self.refreshControl.endRefreshing()
        }
    }
    
    func getChatLogs(id: String, atValue: Int) {
        var tempData3 = [[String: Any]]()
        var chatRef = DatabaseQuery()
        
        
        if(id == "" && atValue == 0) {
            chatRef = ref.child("ChatLogs").child(chatId).queryOrdered(byChild:"timePosted").queryLimited(toLast: UInt(self.totalPosts))
            
            print("Chat Log: ", self.totalPosts)
            
        }
        else {
            chatRef = ref.child("ChatLogs").child(chatId).queryOrdered(byChild:"timePosted").queryLimited(toLast: UInt(self.totalPosts)).queryEnding(atValue: atValue, childKey: id)
            
            print("Chat Log 2: ", self.totalPosts)
        }
        
        chatRef.observeSingleEvent(of: .value) { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            var index = 1
            
            if(snapshot.childrenCount == 0) {
                self.startup = false
            }
            
            for child in postDict {
                let teamValues = child.value as? [String: AnyObject] ?? [:]
                if(!blockedUsers.contains(teamValues["ownerId"] as! String)) {
                    let postDate = teamValues["timePosted"] as! Double
                    let date = Date(timeIntervalSince1970: postDate)
                    let formatter3 = DateFormatter()
                    formatter3.dateFormat = "dd MMMM y"
                    let total = formatter3.string(from: date)
                    let tempArr = [
                        "ownerId": teamValues["ownerId"]!,
                        "message": teamValues["message"]!,
                        "ownerName": teamValues["ownerName"]!,
                        "timePosted": teamValues["timePosted"]!,
                        "timeString": total,
                        "docId": child.key
                    ] as [String : Any]
                    
                    tempData3.append(tempArr)
                }
                
                if(index == snapshot.childrenCount && tempData3.count > 0) {
                    tempData3 = tempData3.sorted(by: { $1["timePosted"] as! Double > $0["timePosted"] as! Double })
                    let tempData2 = tempData3
                    var totalDates = 0
                    
                    for temp in 0...tempData2.count-1 {
                        let tempArr2 = [
                            "ownerId": "",
                            "message": "",
                            "ownerName": "",
                            "timePosted": 1.0,
                            "timeString": tempData2[Int(temp)]["timeString"]!,
                            "docId": ""
                        ] as [String : Any]
                        
                        if(Int(temp) == 0) {
                            tempData3.insert(tempArr2, at: 0)
                            totalDates += 1
                        }
                        else {
                            if(tempData2[Int(temp)]["timeString"] as! String != tempData2[Int(temp-1)]["timeString"] as! String) {
                                totalDates += 1
                                tempData3.insert(tempArr2, at: Int(temp-1) + totalDates)
                            }
                            
                        }
                    }
                    
                    if(id == "" && atValue == 0) {
                        self.tempData.insert(contentsOf: tempData3, at: 0)
                        self.scrollToBottom()
                    }
                    
                    if(tempData3[1]["docId"] as! String == self.tempData[1]["docId"] as! String) {
                        
                    }
                    
                    else {
                        if(id != "" && atValue != 0) {
                            if(self.tempData[0]["timeString"] as! String == tempData3[tempData3.count-1]["timeString"] as! String) {
                                self.tempData.removeFirst()
                            }
                            print(tempData3[1]["docId"] as! String, " == ", self.tempData[1]["docId"] as! String)
                            
                            self.tempData.insert(contentsOf: tempData3, at: 0)
                        }
                    }
                    self.totalPosts += 30
                    self.startup = false
                    self.tblChat.reloadData()
                }
                
                index += 1
            }
        }
    }
    
    func listenToChat() {
        chat = ref.child("ChatLogs").child(chatId).queryLimited(toLast: 5)
        chat.observe(.childAdded) { (snapshot) in
            self.setToZero(groupId: self.chatId)
            
            var count = 0
            for i in groups {
                if(i["docId"] as! String == self.chatId) {
                    totalNotifications[count] = 0
                    break
                }
                count += 1
            }
            
            
            
            if(self.startup == false) {
                
                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                
                
                print("New chat detected")
                
                if(!blockedUsers.contains(postDict["ownerId"] as! String)) {
                    
                    let postDate = postDict["timePosted"] as! Double
                    let date = Date(timeIntervalSince1970: postDate)
                    let formatter3 = DateFormatter()
                    formatter3.dateFormat = "dd MMMM y"
                    let total = formatter3.string(from: date)
                    
                    let tempArr = [
                        "ownerId": postDict["ownerId"]!,
                        "message": postDict["message"]!,
                        "ownerName": postDict["ownerName"]!,
                        "timePosted": postDict["timePosted"]!,
                        "timeString": total,
                        "docId": snapshot.key
                    ] as [String : Any]
                    
                    
                    if(self.tempData.count > 0) {
                        if(total != self.tempData[self.tempData.endIndex-1]["timeString"] as! String) {
                            let tempArr2 = [
                                "ownerId": "",
                                "message": "",
                                "ownerName": "",
                                "timePosted": 1.0,
                                "timeString": total,
                                "docId": ""
                            ] as [String : Any]
                            
                            self.tempData.append(tempArr2)
                        }
                    }
                    else {
                        let tempArr2 = [
                            "ownerId": "",
                            "message": "",
                            "ownerName": "",
                            "timePosted": 1.0,
                            "timeString": total,
                            "docId": ""
                        ] as [String : Any]
                        
                        self.tempData.append(tempArr2)
                    }
                    
                    self.tempData.append(tempArr)
                    self.tblChat.reloadData()
                    self.scrollToBottom()
                    
                    self.tblChat.separatorStyle = .none
                }
            }
        }
    }
    
    func setToZero(groupId: String) {
        ref.child("Notifications")
            .queryOrdered(byChild: "gName")
            .queryEqual(toValue: groupId)
            .observeSingleEvent(of: .value, with: { snapshot in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let unreadCountRef = snap.ref.child("unseenMessage")
                    
                    let dict = snap.value as! [String: Any]
                    
                    if(dict["parentUser"] as! String == userData["username"]!) {
                        unreadCountRef.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
                            var currentCount = currentData.value as? Int ?? 0
                            currentCount = 0
                            currentData.value = currentCount
                            return TransactionResult.success(withValue: currentData)
                        })
                    }
                }
                
            })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(fromWhere == "ChatMenu") {
            if(totalNotifications.count >= index.row+1) {
                totalNotifications[index.row] = 0
            }
        }

        var total = 0
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
        // setToZero(groupId: chatId)
        
        let presenceRef = Database.database().reference(withPath: "disconnectmessage");
        presenceRef.onDisconnectSetValue("I disconnected!")
        presenceRef.onDisconnectRemoveValue { error, reference in
            if let error = error {
                print("Could not establish onDisconnect event: \(error)")
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if(!isInViewGroup) {
            print("disappeared")
            isInChat = false
            ref.removeAllObservers()
            chat.removeAllObservers()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
            viewChat.backgroundColor = .systemGray5
            tblChat.backgroundColor = .systemGray5
            txtMsg.backgroundColor = .systemGray6
        }
        else {
            view.backgroundColor = .white
            tblChat.backgroundColor = .white
            viewChat.backgroundColor = .white
        }
    }
    
    fileprivate func configureTableView() {
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
            viewChat.backgroundColor = .systemGray5
            tblChat.backgroundColor = .systemGray5
            txtMsg.backgroundColor = .systemGray6
        }
        else {
            view.backgroundColor = .white
            viewChat.backgroundColor = .white
        }
    }
    
    @objc func SwipeBack() {
        if(fromWhere == "ChatMenu") {
            unwind()
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnActionMsgSend(_ sender: Any) {
        if (txtMsg.text.trimmingCharacters(in: .whitespaces) != "" && txtMsg.text.trimmingCharacters(in: .whitespaces) != "") {
            let rand = Int.random(in: 0..<100000)
            let rand2 = (Date().timeIntervalSince1970)
            let postTime = String(lround(rand2)) + "-" + String(rand)
            
            ref.child("ChatLogs").child(chatId).child(postTime).updateChildValues(
                [
                    "ownerName": userData["name"]!,
                    "ownerId": userData["username"]!,
                    "message" : txtMsg.text!,
                    "timePosted": (lround(Date().timeIntervalSince1970))
                ])
            
            incrementUnseen(lastMessage: txtMsg.text!)
            self.tblChat.reloadData()
            txtMsg.text = ""
        }
        //    unwind()
    }
    
    
    func incrementUnseen(lastMessage: String) {
        // ref.child("Notifications").child(chatId).observeSingleEvent(of: .value, with: { snapshot in
        
        ref.child("Notifications").queryOrdered(byChild: "gName").queryEqual(toValue: chatId).observeSingleEvent(of: .value, with: { snapshot in
            print("Snapshot:", snapshot.childrenCount)
            var totalCount = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: Any]
                let unreadCountRef = snap.ref//.child("unseenMessage")
                
                unreadCountRef.runTransactionBlock( { (currentData: MutableData) -> TransactionResult in
                    var currentCount = currentData.childData(byAppendingPath: "unseenMessage").value as? Int ?? 0
                    currentCount += 1
                    if(dict["parentUser"] as! String != userData["username"]!) {
                        currentData.childData(byAppendingPath: "unseenMessage").value = currentCount
                    }
                    currentData.childData(byAppendingPath: "lastUser").value = userData["username"]!
                    currentData.childData(byAppendingPath: "lastMessage").value = lastMessage
                    currentData.childData(byAppendingPath: "timestamp").value = Int(Date().timeIntervalSince1970)
                    
                    return TransactionResult.success(withValue: currentData)
                    
                })
                    
                totalCount += 1
                if(snapshot.childrenCount == totalCount) {
                    
                    for i in self.members {
                        functions.httpsCallable("webhookNew").call(["docId": i, "title": self.group, "message": userData["name"]! + ": " + lastMessage]) { (result, error) in
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
                    
                    UIApplication.shared.applicationIconBadgeNumber += 1
                }
            }
        })
    }
    
    @IBAction func imagePressed(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        print("Pressed: ", indexPath.row)
        
        let imageRow = indexPath.row
        
        guard let reactionVC = storyboard?.instantiateViewController(withIdentifier: "ReactionViewController")
            as? OthersAccount else {
              
            assertionFailure("No view controller in storyboard")
            return
          }

          // take a snapshot of current view and set it as backingImage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
            reactionVC.backingImage = self.tabBarController?.view.asImage()
            reactionVC.ownerId = self.tempData[imageRow]["ownerId"] as! String

            reactionVC.modalPresentationStyle = .fullScreen
              // present the view controller modally without animation
            self.present(reactionVC, animated: false, completion: nil)
        })
    }
    
    func getCurrentTimeStamp() -> String {
        return "\(Double(NSDate().timeIntervalSince1970 * 1000))"
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.tempData.count-1, section: 0)
            self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        //  txtMsg.endEditing(true)
        viewBottom.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
            self.doneButtonAction()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            viewBottom.constant = keyboardSize.height
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        viewBottom.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    /*  func addDoneButtonOnKeyboard(){
     let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
     doneToolbar.barStyle = .default
     
     let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
     let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
     
     let items = [flexSpace, done]
     doneToolbar.items = items
     doneToolbar.sizeToFit()
     
     txtMsg.inputAccessoryView = doneToolbar
     }
     */
    
    @objc func doneButtonAction(){
        txtMsg.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtMsg.resignFirstResponder()
        return true
    }
}

extension ChatView: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let path = indexPath.row
        
        
        /*   if(path == 0) {
         let cell3 = tableView.dequeueReusableCell(withIdentifier: "chatDate") as! ChatDateCell
         cell3.newDate.text = (tempData[path]["timeString"] as! String)
         totalDays += 1
         return cell3
         }
         */
        
        if(tempData[path]["ownerId"] as! String == "") {
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "chatDate") as! ChatDateCell
            cell3.newDate.text = (tempData[path]["timeString"] as! String)
            return cell3
        }
        
        let date = Date(timeIntervalSince1970: tempData[path]["timePosted"] as! Double)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        
        if(path-1 >= 0 && indexPath.row != 1){
            let previousMsg = tempData[path-1]
            
            let formatter3 = DateFormatter()
            formatter3.dateFormat = "dd MMMM y"
            
            if(previousMsg["ownerId"] as! String == tempData[path]["ownerId"] as! String)  {
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! Chat2TableViewCell
                
                cell2.lblSender.text = (tempData[path]["message"] as! String)
                cell2.lblSender?.layer.masksToBounds = true
                cell2.lblSender.layer.cornerRadius = 7
                
                if((previousMsg["timePosted"] as! Int + 60) <= tempData[path]["timePosted"] as! Int ) {
                    cell2.timePosted.text = (localDate)
                }
                else {
                    cell2.timePosted.text = ""
                }
                return cell2
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ChatTableViewCell
        cell.lblReceiver.text = (tempData[path]["message"] as! String)
        cell.userImg.layer.cornerRadius = cell.userImg.frame.height/2
        cell.userImg.clipsToBounds = true
        cell.userName.text = (tempData[path]["ownerName"] as! String)
        cell.timePosted.text = "24:24"//(dict1.object(forKey: "OwnerName") as! String)
        cell.lblReceiver?.layer.masksToBounds = true
        cell.lblReceiver.layer.cornerRadius = 7
        cell.userImg.tag = indexPath.row
      //  cell.isUserInteractionEnabled = false
        
        let userId = (tempData[path]["ownerId"] as! String)
        let url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/" + userId + ".jpeg?alt=media&token="
        
        cell.userImg?.sd_setBackgroundImage(with: URL(string: url)!, for: .normal, placeholderImage: UIImage(named: "placeholderImg"))
        
        loadImage(urlString: url) { url, returnData in
            cell.userImg.setBackgroundImage(returnData, for: .normal)
        }
        
        cell.userImg?.layoutIfNeeded()
        cell.userImg?.subviews.first?.contentMode = .scaleAspectFill
        
        cell.timePosted.text = localDate
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let sizeToFitIn = CGSize(width: self.txtMsg.bounds.size.width-20, height: CGFloat(MAXFLOAT))
        
        let newSize = self.txtMsg.sizeThatFits(sizeToFitIn)
        self.textViewHeight.constant = newSize.height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ViewGroup {
            vc.groupId = chatId
            vc.group = group
            vc.ownerId = ownerId
            vc.isAdmin = isAdmin
        }
        
    }
    
    @IBAction func unwindToChat(_ seg: UIStoryboardSegue) {
        
    }
    
    func unwind() {
        if(fromWhere == "ChatMenu") {
            performSegue(withIdentifier: "backUnwind", sender: self)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

class ChatDateCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var newDate: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class ChatTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var userImg: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet var lblReceiver: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


class Chat2TableViewCell: UITableViewCell {
    
    @IBOutlet var lblSender: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
