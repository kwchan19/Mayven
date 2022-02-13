//
//  DetailView.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-24.
//

import UIKit
import Firebase
import Foundation
import SDWebImage

var detailView = DetailView()

class DetailView: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chatView: UIView!
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var emptyTable: UILabel!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    
    var texts = [[String: Any]]()
    var docId: String = String()
    var segmentIndex: Int = Int()
    var lastView = String()
    var fromWhere = String()
    var indexPath = 0
    var isLoading = false
    var imageRow = 0
    var originalPost = [String: Any]()
    var isLiked = Bool()
    var buttonTag = Int()
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        detailView = self
        self.textView.delegate = self
        textView.layer.cornerRadius = 15.0
        
        //replyTextView.isScrollEnabled = false
        textView.isScrollEnabled = false
        textView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        getReplies()
        
        // addDoneButtonOnKeyboard()
        
        configureTableView()
        tableView.refreshControl = refreshControl
        tableView.backgroundView = refreshControl
        
        tableView.register(UINib(nibName: "LoadMore", bundle: nil), forCellReuseIdentifier: "tableviewloadingcellid")
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetailView.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailView.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.refreshControl.addTarget(self, action: #selector(getReplies), for: UIControl.Event.valueChanged)
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self;
        
        let swipeRightGesture=UISwipeGestureRecognizer(target: self, action: #selector(SwipeBack))
        swipeRightGesture.direction = UISwipeGestureRecognizer.Direction.right
        view.addGestureRecognizer(swipeRightGesture)
        
    }
    
    @IBAction func a_originalImagePressed(_ sender: UIButton) {
        
        // let indexPath = IndexPath(row: sender.tag, section: 0)
        self.imageRow = 0 //indexPath.row
        
    }
    
    @IBAction func a_replyImagePressed(_ sender: UIButton) {
        
        //     let indexPath = IndexPath(row: sender.tag, section: 0)
        self.imageRow = sender.tag
        
    }
    
    @IBAction func originalDots(_ sender: UIButton) {
        if(texts[0]["ownerId"] as! String == userData["username"]!) {
            let alert = UIAlertController(title: "Delete Post?", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                firebaseDeletePost(docId: self.docId)
                
                
                
                forumView.refreshData()
                self.unwind()
                //self.performSegue(withIdentifier: "unwindDelete", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            if let popoverPresentationController = alert.popoverPresentationController {
                
                popoverPresentationController.sourceRect = sender.frame
                popoverPresentationController.sourceView = self.view
                
            }
            self.present(alert, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Report Post?", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { action in
                // Function for add post
                self.reportPost(index: 0)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            if let popoverPresentationController = alert.popoverPresentationController {
                
                popoverPresentationController.sourceRect = sender.frame
                popoverPresentationController.sourceView = self.view
                
            }
            self.present(alert, animated: true)
        }
        
    }
    
    
    @IBAction func replyDots(_ sender: UIButton) {
        if(texts[sender.tag]["ownerId"] as! String == userData["username"]!) {
            let alert = UIAlertController(title: "Delete Reply?", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                // Function for add post
                
                checkRepliesLeft(docId: self.docId, userId: self.texts[sender.tag]["ownerId"] as! String) { returnData in
                    firebaseDeleteReply(docId: self.docId, replyId: self.texts[sender.tag]["docId"] as! String, user: userData, isMore: returnData)
                    self.texts.remove(at: sender.tag)
                    
                    let indexPath = IndexPath(row: sender.tag, section: 0)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    
                    self.noRefresh()
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            if let popoverPresentationController = alert.popoverPresentationController {
                
                popoverPresentationController.sourceRect = sender.frame
                popoverPresentationController.sourceView = self.view
                
            }
            self.present(alert, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Report Post?", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { action in
                // Function for add post
                self.reportPost(index: sender.tag)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                
            }))
            if let popoverPresentationController = alert.popoverPresentationController {
                
                popoverPresentationController.sourceRect = sender.frame
                popoverPresentationController.sourceView = self.view
                
            }
            self.present(alert, animated: true)
        }
    }
    
    @objc func SwipeBack() {
        unwind()
    }
    
    func unwind() {
        //  if(originalPost.isEmpty) { // From Notifs
        //   performSegue(withIdentifier: "backUnwind", sender: self)
        performSegue(withIdentifier: "unwind", sender: self)
        //  }
        //  else { // From Homepage
        
        //  }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! InitCell
        
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
            
            tableView.backgroundColor = .systemGray5
            chatView.backgroundColor = .systemGray5
            textView.backgroundColor = .systemGray6
            // cell.backgroundColor =
            cell.backgroundColor = .systemGray6
        }
        else {
            view.backgroundColor = .white
            
            tableView.backgroundColor = .white
            chatView.backgroundColor = .white
            textView.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
            
            
            
            cell.backgroundColor =  UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1)
            
            
        }
        
    }
    
    
    
    @IBAction func addReply(_ sender: UIButton) {
        if(textView.text.trimmingCharacters(in: .whitespaces) != "") {
            firebaseAddReply(user: userData, text: self.textView.text!, originalPost: self.docId, type: "reply")
            
            let replyCount = self.texts[0]["replyCount"] as! Int
            self.texts[0]["replyCount"] = replyCount+1
            
            //  self.getReplies()
            
            if(self.fromWhere == "notifications") {
                forumView.refreshData()
            }
            else { // Add 1 to forumView
                let forumReplyCount = forumView.tempData[self.indexPath]["replyCount"] as! Int
                forumView.tempData[self.indexPath]["replyCount"] = forumReplyCount+1
                forumView.tableView.reloadData()
            }
            
            self.tableView.reloadData()
            
            self.textView.text = ""
            self.dismissKeyboard()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let sizeToFitIn = CGSize(width: self.textView.bounds.size.width-20, height: CGFloat(MAXFLOAT))
        
        let newSize = self.textView.sizeThatFits(sizeToFitIn)
        self.textViewHeight.constant = newSize.height
    }
    
    func noRefresh() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        
        self.isLoading = false
        self.texts.removeAll()
        tableView.reloadData()
        
        firebaseGetPost(docId: docId) { returnData1 in

            
            if(returnData1.isEmpty) {

                //   self.tableView.isHidden = true
                self.emptyTable.isHidden = false
                self.textView.isHidden = true
                self.sendBtn.isHidden = true
                self.tableView.reloadData()
            }
            else {
                self.emptyTable.isHidden = true
                self.textView.isHidden = false
                self.sendBtn.isHidden = false
                self.originalPost = returnData1
                
                self.texts.insert(returnData1, at: 0)
                
                if(returnData1["replyCount"] as! Int == 0) {
                    self.tableView.reloadData()
                }
                else {
                
                    if(self.fromWhere != "notifications") {
                        self.originalPost["docId"] = self.docId
                        self.originalPost["postType"] = "post"
                        forumView.tempData[self.indexPath] = self.originalPost
                        forumView.tableView.reloadData()
                    }
                    
                    if ((returnData1["usersLiked"] as! [String]).contains(userData["username"]!)) {
                        self.isLiked = true
                    }
                    
                    firebaseGetReplies(postId: self.docId){
                        returnData in
                        for i in returnData {
                            self.texts.append(i)
                            
                            
                        }
                        
                        self.tableView.reloadData()
                        
                    }
                }
            }
        }
    }
    
    @objc func getReplies() {

        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        
        self.isLoading = false
        self.texts.removeAll()
        tableView.reloadData()
        
        firebaseGetPost(docId: docId) { returnData1 in

            if(returnData1.isEmpty) {

                //   self.tableView.isHidden = true
                self.emptyTable.isHidden = false
                self.textView.isHidden = true
                self.sendBtn.isHidden = true
                self.tableView.reloadData()
            }
            else {
                self.emptyTable.isHidden = true
                self.textView.isHidden = false
                self.sendBtn.isHidden = false
                self.originalPost = returnData1
                
                print(self.originalPost)
                
                self.texts.insert(returnData1, at: 0)
                
                if(returnData1["replyCount"] as! Int == 0) {
                    self.tableView.reloadData()
                }
                else {
                
                    if(self.fromWhere != "notifications") {
                        self.originalPost["docId"] = self.docId
                        self.originalPost["postType"] = "post"
                        forumView.tempData[self.indexPath] = self.originalPost
                        forumView.tableView.reloadData()
                    }
                    
                    if ((returnData1["usersLiked"] as! [String]).contains(userData["username"]!)) {
                        self.isLiked = true
                    }
                    
                    firebaseGetReplies(postId: self.docId){
                        returnData in
                        for i in returnData {
                            self.texts.append(i)
                            
                        }
                        self.tableView.reloadData()
                        
                        
                        
                    }
                }
            }
        }
        
        
        self.refreshControl.endRefreshing()
    }
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            
            DispatchQueue.global().async {
                sleep(2)
                if(self.isLoading == true) {
                    DispatchQueue.main.async {
                        let tempIndex = self.texts.count-1
                        if(self.texts.count > 6) {
                            firebaseLoadMoreReplies(postId: self.docId, lastPost: self.texts[tempIndex]["lastDocument"]!) { returnData in
                                if(!returnData.isEmpty) {
                                    self.texts.append(contentsOf: returnData)
                                    self.isLoading = false
                                    self.tableView.reloadData()
                                }
                                else {
                                    
                                    self.isLoading = false
                                    self.tableView.reloadData()
                                }
                            }
                        }
                        else {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
    }
    
    fileprivate func configureTableView() {
        tableView.removeExtraCellLines()
        tableView.separatorInset = UIEdgeInsets.zero
        //   tableView.separatorColor = .clear
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .black
            tableView.backgroundColor = .systemGray5
            chatView.backgroundColor = .systemGray5
            textView.backgroundColor = .systemGray6
        }
        else {
            view.backgroundColor = .white
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            //Return the amount of items
            return texts.count
        } else if section == 1 {
            //Return the Loading cell
            return 1
        } else {
            //Return nothing
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            if(indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "initCell", for: indexPath) as! InitCell
                cell.txt?.text = texts[indexPath.row]["text"] as? String
                
                if traitCollection.userInterfaceStyle == .dark {
                    cell.backgroundColor = .systemGray6//UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1)
                }
                else {
                    cell.backgroundColor =  UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1)
                }
                
                if(texts.count-1 == 1) {
                    cell.replies?.text = "1 reply"
                }
                else {
                    let replyCount = texts[0]["replyCount"] as! Int
                    cell.replies?.text = String(replyCount) + " replies"
                }
                //  print((texts[0]))
                
                cell.userImage?.setImage(UIImage(systemName: "person.fill"), for: .normal)
                cell.userImage?.layer.cornerRadius = cell.userImage.frame.size.width/2
                cell.userImage?.clipsToBounds = true
                cell.userName?.text = texts[indexPath.row]["ownerName"] as? String
                cell.userImage.tag = indexPath.row
                
                if(isLiked == true) {
                    cell.heart?.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
                else {
                    cell.heart?.setImage(UIImage(systemName: "heart"), for: .normal)
                }
                
                let userId = texts[indexPath.row]["ownerId"] as! String
                let url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + userId + ".jpeg?alt=media&token="
                
                
                cell.userImage?.sd_setBackgroundImage(with: URL(string: url)!, for: .normal, placeholderImage: UIImage(named: "placeholderImg"))
                
                
                cell.userImage?.layoutIfNeeded()
                cell.userImage?.subviews.first?.contentMode = .scaleAspectFill
                
                
                let today = Date().timeIntervalSince1970
                let postTime = texts[indexPath.row]["timestamp"] as? Double
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
                
                cell.datePosted?.text = String(elapsedTime) + timeSign
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath) as! ReplyCell
                
                cell.txt?.text = texts[indexPath.row]["text"] as? String
                //    cell.datePosted?.text = "32m"
                
                cell.userImage?.setImage(UIImage(systemName: "person.fill"), for: .normal)
                cell.userImage?.layer.cornerRadius = cell.userImage.frame.size.width/2
                cell.userImage?.clipsToBounds = true
                cell.userImage.tag = indexPath.row
                cell.userName?.text = texts[indexPath.row]["ownerName"] as? String
                cell.replyDot?.tag = indexPath.row
                
                let userId = texts[indexPath.row]["ownerId"] as! String
                let url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + userId + ".jpeg?alt=media&token="
                
                
                cell.userImage?.sd_setBackgroundImage(with: URL(string: url)!, for: .normal, placeholderImage: UIImage(named:"placeholderImg"))
                
                cell.userImage?.layoutIfNeeded()
                cell.userImage?.subviews.first?.contentMode = .scaleAspectFill
                
                
                let today = Date().timeIntervalSince1970
                let postTime = texts[indexPath.row]["timestamp"] as? Double
                var elapsedTime = lround(today-postTime!)/60
                var timeSign = ""
                if(elapsedTime == 0) {
                    timeSign = "s"
                    elapsedTime = lround(today-postTime!)
                }
                else if(elapsedTime < 60){
                    timeSign = "m"
                }
                else if(elapsedTime >= 60 && elapsedTime < 1440) {
                    elapsedTime = lround(Double(elapsedTime/60))
                    timeSign = "h"
                }
                else if(elapsedTime >= 1440 && elapsedTime < 525600) {
                    elapsedTime = lround(Double(elapsedTime/1440))
                    timeSign = "d"
                }
                else {
                    elapsedTime = lround(Double(elapsedTime/525600))
                    timeSign = "y"
                }
                
                cell.datePosted?.text = String(elapsedTime) + timeSign
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewloadingcellid", for: indexPath) as! LoadingCell
            
            if(isLoading) {
                cell.startAnimating.startAnimating()
                
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }
        else {
            if(isLoading) {
                return UITableView.automaticDimension
            }
            else {
                return 0
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY > contentHeight - scrollView.frame.height * 4) && !isLoading && texts.count > 5 {
            loadMoreData()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func reportPost(index: Int) {
        if((texts[index]["reports"] as! [String]).count + 1 >= 5) {
            let replyPost = texts[index]
            
            checkRepliesLeft(docId: docId, userId: self.texts[index]["ownerId"] as! String) { returnData in
                firebaseSendReportReply(docId: self.docId, replyId: replyPost["docId"] as! String, postOwner: replyPost["ownerId"] as! String, text: replyPost["text"] as! String, user: userData, isMore: returnData)
            }
        }
        else {
            firebaseIncrementReportReply(docId: docId, replyId: texts[index]["docId"] as! String, user: userData)
            getReplies()
        }
        
    }
    
    @IBAction func exitPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "unwind", sender: self)
    }
    
    @IBAction func liked(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! InitCell
        let indexPath2 = IndexPath(row: buttonTag, section: 0)
        let cell2 = forumView.tableView.cellForRow(at: indexPath2) as! ForumCell
        var numLikes = forumView.tempData[indexPath2.row]["usersLiked"] as? [String]
        
        if(cell.heart.currentImage == UIImage(systemName: "heart.fill")) {
            //FUnction to Unlike
            isLiked = false
            cell.heart.setImage(UIImage(systemName: "heart"), for: .normal)
            
            cell2.heart.setImage(UIImage(systemName: "heart"), for: .normal)
            cell2.likes.text = String(numLikes!.count-1)
            let index = numLikes?.firstIndex(of: userData["username"]!)
            
            numLikes?.remove(at: index!)
            
            forumView.tempData[indexPath2.row]["usersLiked"] = numLikes
            
            firebaseUnlike(user: userData, postId: docId)
        }
        else {
            //Function to Like
            isLiked = true
            cell.heart.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            
            cell2.heart.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            cell2.likes.text = String(numLikes!.count+1)
            cell2.name.adjustsFontSizeToFitWidth = true
            cell2.txt.adjustsFontSizeToFitWidth = true
            numLikes?.append(userData["username"]!)
            
            forumView.tempData[indexPath2.row]["usersLiked"] = numLikes
            firebaseLikes(user: userData, postId: docId)
        }
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConst.constant = keyboardSize.height
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConst.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    /* func addDoneButtonOnKeyboard(){
     let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
     doneToolbar.barStyle = .default
     
     let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
     let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
     
     let items = [flexSpace, done]
     doneToolbar.items = items
     doneToolbar.sizeToFit()
     
     textView.inputAccessoryView = doneToolbar
     }
     */
    @objc func doneButtonAction(){
        textView.resignFirstResponder()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        //  txtMsg.endEditing(true)
        bottomConst.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
            self.doneButtonAction()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? OthersAccount {
            //  let index = tableView.indexPathForSelectedRow!.row
            
            //  print("Index: ", index)
            
            //  let indexPath = IndexPath(row: sender.tag, section: 0)
            
            vc.ownerId = texts[self.imageRow]["ownerId"] as! String
        }
        
    }
}


class InitCell: UITableViewCell {
    @IBOutlet weak var txt: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIButton!
    @IBOutlet weak var datePosted: UILabel!
    @IBOutlet weak var replies: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var heart: UIButton!
    
    @IBOutlet weak var delete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if traitCollection.userInterfaceStyle == .dark {
            delete.tintColor = .white
            // newPost.backgroundColor = .white
            // newPost.tintColor = .black
            // postContainer.backgroundColor = .white
            // postContainer.tintColor = .black
        }
        else {
            delete.tintColor = .black
        }
        
        
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            delete.tintColor = .white
            
        }
        else {
            delete.tintColor = .black
            
        }
    }
    
}

class ReplyCell: UITableViewCell {
    @IBOutlet weak var txt: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIButton!
    @IBOutlet weak var datePosted: UILabel!
    
    @IBOutlet weak var replyDot: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if traitCollection.userInterfaceStyle == .dark {
            replyDot.tintColor = .white
            // newPost.backgroundColor = .white
            // newPost.tintColor = .black
            // postContainer.backgroundColor = .white
            // postContainer.tintColor = .black
        }
        else {
            replyDot.tintColor = .black
        }
        
        
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            replyDot.tintColor = .white
            
        }
        else {
            replyDot.tintColor = .black
            
        }
    }
}


extension DetailView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
