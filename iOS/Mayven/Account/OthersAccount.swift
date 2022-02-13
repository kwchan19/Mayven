//
//  OthersAccount.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-26.
//

import UIKit
import Firebase

class OthersAccount: UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backingImageView: UIImageView!
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var floatingButton: UIView!
    
    @IBOutlet weak var msgConstraint: NSLayoutConstraint!
    @IBOutlet weak var addGroupConstraint: NSLayoutConstraint!
    
    var backingImage: UIImage?
    
    var ownerId = ""
    var ownerName = ""

    var cardPanStartingTopConstant : CGFloat = 55.0
    var cardPanStartingTopConstraint: CGFloat = 0.0
    
    @IBOutlet weak var photo: UIButton!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var addToGroupBtn: UIButton!
    @IBOutlet weak var blockUserBtn: UIButton!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var addToGroupLabel: UILabel!
    @IBOutlet weak var blockLabel: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var classOf: UILabel!
    
    let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        floatingButton.clipsToBounds = true
        floatingButton.layer.cornerRadius = 3.0
        backingImageView.image = backingImage
        
        let id = ownerId
        let url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/" + id + ".jpeg?alt=media&token=" + String(Int(Date().timeIntervalSince1970))
        
        photo.isUserInteractionEnabled = false
        
        self.photo?.sd_setBackgroundImage(with: URL(string: url)!, for: .normal, placeholderImage: UIImage(named:"placeholderImg"))
        
        self.photo.layer.cornerRadius = self.photo.frame.height/2
        self.photo.clipsToBounds = true
        self.photo?.layoutIfNeeded()
        self.photo?.subviews.first?.contentMode = .scaleAspectFill
        
        getProfile()
        
        if traitCollection.userInterfaceStyle == .dark {
            cardView.backgroundColor = .systemGray5
            
        }
        else {
            cardView.backgroundColor = .white
        }
        
        if(id == userData["username"]!) {
            blockUserBtn.isHidden = true
            messageBtn.isHidden = true
            addToGroupBtn.isHidden = true
            
            blockLabel.isHidden = true
            messageLabel.isHidden = true
            addToGroupLabel.isHidden = true
            
            let _ = msgConstraint.setMultiplier(multiplier: 0.7)
            let _ = addGroupConstraint.setMultiplier(multiplier: 1.3)

        }
        else {
            blockUserBtn.isHidden = false
            messageBtn.isHidden = false
            addToGroupBtn.isHidden = false
            
            blockLabel.isHidden = false
            messageLabel.isHidden = false
            addToGroupLabel.isHidden = false
        }
        
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 10.0
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        if let safeAreaHeight = keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
           let bottomPadding = keyWindow?.safeAreaInsets.bottom {
            cardViewTopConstraint.constant = safeAreaHeight + bottomPadding
        }
        
        // set dimmerview to transparent
        dimmerView.alpha = 0.0
        
        let dimmerTap = UITapGestureRecognizer(target: self, action: #selector(dimmerViewTapped(_:)))
        dimmerView.addGestureRecognizer(dimmerTap)
        dimmerView.isUserInteractionEnabled = true
        
        let viewPan = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
        
        // by default iOS will delay the touch before recording the drag/pan information
        // we want the drag gesture to be recorded down immediately, hence setting no delay
        viewPan.delaysTouchesBegan = false
        viewPan.delaysTouchesEnded = false
        
        self.view.addGestureRecognizer(viewPan)
        
    }
    
    @IBAction func viewPanned(_ panRecognizer: UIPanGestureRecognizer) {
      let velocity = panRecognizer.velocity(in: self.view)
      let translation = panRecognizer.translation(in: self.view)
      
      switch panRecognizer.state {
      case .began:
        cardPanStartingTopConstant = cardViewTopConstraint.constant
        
      case .changed:
        if self.cardPanStartingTopConstraint + translation.y > 55.0 {
          cardViewTopConstraint.constant = self.cardPanStartingTopConstant + translation.y
        }
        
        // change the dimmer view alpha based on how much user has dragged
        dimmerView.alpha = dimAlphaWithCardTopConstraint(value: self.cardViewTopConstraint.constant)

      case .ended:
        if velocity.y > 1500.0 {
          hideCardAndGoBack()
          return
        }
        
        if let safeAreaHeight = keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
          let bottomPadding = keyWindow?.safeAreaInsets.bottom {
          
          if self.cardViewTopConstraint.constant < (safeAreaHeight + bottomPadding) * 0.25 {
            showCard(atState: .expanded)
          } else if self.cardViewTopConstraint.constant < (safeAreaHeight) - 70 {
            showCard(atState: .normal)
          } else {
            hideCardAndGoBack()
          }
        }
      default:
        break
      }
    }

    
    private func dimAlphaWithCardTopConstraint(value: CGFloat) -> CGFloat {
      let fullDimAlpha : CGFloat = 0.7
      
      // ensure safe area height and safe area bottom padding is not nil
      guard let safeAreaHeight = keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
        let bottomPadding = keyWindow?.safeAreaInsets.bottom else {
        return fullDimAlpha
      }
      
      // when card view top constraint value is equal to this,
      // the dimmer view alpha is dimmest (0.7)
      let fullDimPosition = (safeAreaHeight + bottomPadding) / 2.0
      
      // when card view top constraint value is equal to this,
      // the dimmer view alpha is lightest (0.0)
      let noDimPosition = safeAreaHeight + bottomPadding
      
      // if card view top constraint is lesser than fullDimPosition
      // it is dimmest
      if value < fullDimPosition {
        return fullDimAlpha
      }
      
      // if card view top constraint is more than noDimPosition
      // it is dimmest
      if value > noDimPosition {
        return 0.0
      }
      
      // else return an alpha value in between 0.0 and 0.7 based on the top constraint value
      return fullDimAlpha * 1 - ((value - fullDimPosition) / fullDimPosition)
    }
    
    enum CardViewState {
        case expanded
        case normal
    }
    
    var cardViewState : CardViewState = .normal
    
    // to store the card view top constraint value before the dragging start
    // default is 55 pt from safe area top
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showCard()
    }
    
    //MARK: Animations
    private func showCard(atState: CardViewState = .normal) {
       
      // ensure there's no pending layout changes before animation runs
      self.view.layoutIfNeeded()
      
      // set the new top constraint value for card view
      // card view won't move up just yet, we need to call layoutIfNeeded()
      // to tell the app to refresh the frame/position of card view
      if let safeAreaHeight = keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
        let bottomPadding = keyWindow?.safeAreaInsets.bottom {
        
        if atState == .expanded {
          // if state is expanded, top constraint is 55pt away from safe area top
          cardViewTopConstraint.constant = 55.0
        } else {
            cardViewTopConstraint.constant = (safeAreaHeight + bottomPadding) / 2.5
        }
        
        cardPanStartingTopConstraint = cardViewTopConstraint.constant
      }
      
      // move card up from bottom
      // create a new property animator
      let showCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
        self.view.layoutIfNeeded()
      })
      
      // show dimmer view
      // this will animate the dimmerView alpha together with the card move up animation
      showCard.addAnimations {
        self.dimmerView.alpha = 0.7
      }
      
      // run the animation
      showCard.startAnimation()
    }
    
    @IBAction func dimmerViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideCardAndGoBack()
    }
    
    private func hideCardAndGoBack() {
        
        // ensure there's no pending layout changes before animation runs
        self.view.layoutIfNeeded()
        
        // set the new top constraint value for card view
        // card view won't move down just yet, we need to call layoutIfNeeded()
        // to tell the app to refresh the frame/position of card view
        if let safeAreaHeight = keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height,
           let bottomPadding = keyWindow?.safeAreaInsets.bottom {
            
            // move the card view to bottom of screen
            cardViewTopConstraint.constant = safeAreaHeight + bottomPadding
        }
        
        // move card down to bottom
        // create a new property animator
        let hideCard = UIViewPropertyAnimator(duration: 0.25, curve: .easeIn, animations: {
            self.view.layoutIfNeeded()
        })
        
        // hide dimmer view
        // this will animate the dimmerView alpha together with the card move down animation
        hideCard.addAnimations {
            self.dimmerView.alpha = 0.0
        }
        
        // when the animation completes, (position == .end means the animation has ended)
        // dismiss this view controller (if there is a presenting view controller)
        hideCard.addCompletion({ position in
            if position == .end {
                if(self.presentingViewController != nil) {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        })
        
        // run the animation
        hideCard.startAnimation()
    }
    
    @IBAction func dots(_ sender: UIButton) {
        let alert = UIAlertController(title: "Block User", message: "Would you like to block this user?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            blockUser(username: self.ownerId, user: userData)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        
        if let popoverPresentationController = alert.popoverPresentationController {
            
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.sourceView = self.view
            
        }
        
        present(alert, animated: true, completion: nil)
        
    }

    
    func getProfile() {
        getUserProfile(userId: ownerId) { returnData in
            if(returnData.isEmpty) {
                self.name.text = "The user has been deleted"
                
                self.messageBtn.isHidden = true
                self.addToGroupBtn.isHidden = true
                self.blockUserBtn.isHidden = true
                
            }
            else {
                
                self.desc.text = returnData["programName"] as? String
                self.userId.text = self.ownerId
                
                self.classOf.text = returnData["classOf"] as? String
                
                let temp = Int(self.classOf.text!)
                
                self.classOf.text = "Class of " + String(temp! + 4)
                
                self.name.text = returnData["name"] as? String
                self.ownerName = returnData["name"] as! String
            }
            
        }
    }
    
    
    @IBAction func createDM(_ sender: UIButton) {
        let alert = UIAlertController(title: "Message User?", message: "Would you like to start a new chat with this user?", preferredStyle: .actionSheet)
       
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in

            
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewStoryboard")
                as? ChatView else {
                  
                assertionFailure("No view controller in storyboard")
                return
              }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
                
                vc.group = self.ownerName
                print("SELF NAME", self.ownerName)
                vc.ownerId = ""
                vc.index = IndexPath()
                var members = [userData["username"]!, self.ownerId]
                vc.members = members
                vc.isAdmin = false
                vc.type = "dm"
                
                members.sort()
                
                let docName = members[0] + members[1]
                
                vc.chatId = docName

                retrieveChatGroup(groupId: docName) { returnData in
                    if(returnData.isEmpty) {
                        database.collection("ChatGroups").document(docName).setData( [
                            "ownerId": "",
                            "admins": [],
                            "members": members,
                            "name": "",
                            "type": "dm"
                        ], merge: true)
                        
                        let groupRef = Database.database().reference()
                        groupRef.child("Notifications").childByAutoId().setValue(
                            [
                                "parentUser": userData["username"]!,
                                "gName": docName,
                                "unseenMessage": 0,
                                "timestamp": Int(Date().timeIntervalSince1970),
                                "lastMessage": "You have created this group",
                                "lastUser": userData["username"]!
                            ])
                        
                        addUserToDM(username: self.ownerId, groupId: docName)
                        
                        vc.modalPresentationStyle = .fullScreen
                        vc.fromWhere = "OthersAccount"
                        
                        self.present(vc, animated: false, completion: nil)
                    }
                    else {
                        let memberList = returnData["members"] as! [String]
                        
                        if(!memberList.contains(userData["username"]!)) {
                            database.collection("ChatGroups").document(docName).setData( [
                                "ownerId": "",
                                "admins": [],
                                "members": members,
                                "name": "",
                                "type": "dm"
                            ], merge: true)
                            
                            let groupRef = Database.database().reference()
                            groupRef.child("Notifications").childByAutoId().setValue(
                                [
                                    "parentUser": userData["username"]!,
                                    "gName": docName,
                                    "unseenMessage": 0,
                                    "timestamp": Int(Date().timeIntervalSince1970),
                                    "lastMessage": "You have created this group",
                                    "lastUser": userData["username"]!
                                ])
                            
                            addUserToDM(username: self.ownerId, groupId: docName)
                            
                            vc.modalPresentationStyle = .fullScreen
                            vc.fromWhere = "OthersAccount"
                            
                            self.present(vc, animated: false, completion: nil)
                        }
                        else {
                            vc.modalPresentationStyle = .fullScreen
                            vc.fromWhere = "OthersAccount"
                            
                            self.present(vc, animated: false, completion: nil)
                        }
                    }
                }               
            })
        }))
        
            
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.sourceView = self.view
        }
        
        self.present(alert, animated: true)

        
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            cardView.backgroundColor = .systemGray5
            
        }
        else {
            cardView.backgroundColor = .white
            
        }
        
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddToGroup {
            var adminGroups = [[String: Any]]()
            for i in groups {
                if(i["ownerId"] as! String == userData["username"]!) {
                    adminGroups.append(i)
                }
                else {
                    for admins in i["admins"] as! [String] {
                        if(admins == userData["username"]!) {
                            adminGroups.append(i)
                        }
                    }
                }
            }
            
            
            vc.userToAdd = ownerId
            vc.adminGroups = adminGroups
            
        }
    }
    
}

extension UIView  {
    // render the view within the view's bounds, then capture it as image
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image(actions: { rendererContext in
            layer.render(in: rendererContext.cgContext)
        })
    }
}


extension NSLayoutConstraint {
    func setMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        guard let firstItem = firstItem else {
            return self
        }
        NSLayoutConstraint.deactivate([self])
        let newConstraint = NSLayoutConstraint(item: firstItem, attribute: firstAttribute, relatedBy: relation, toItem: secondItem, attribute: secondAttribute, multiplier: multiplier, constant: constant)
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
