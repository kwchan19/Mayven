//
//  BlockedUsersView.swift
//  Mayven
//
//  Created by Kevin Chan on 2021-05-03.
//

import UIKit
import Firebase

class BlockedUserView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(blockedUsers.count == 0) {
            isHidden.isHidden = false
        }
        else {
            isHidden.isHidden = true
        }
       return blockedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedCell", for: indexPath) as! BlockedUserCell
        
        cell.username.text = blockedUsers[indexPath.row]
        cell.dots.tag = indexPath.row
        
        return cell
    }
    
    
    @IBOutlet weak var isHidden: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backingImageView: UIImageView!
    
    @IBOutlet weak var floatingButton: UIView!
    
    @IBOutlet weak var dimmerView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    
    var backingImage: UIImage?
    var cardPanStartingTopConstant : CGFloat = 55.0
    var cardPanStartingTopConstraint: CGFloat = 0.0
    
    let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        blockedUsers.sort()
        configureTableView()
        
        floatingButton.clipsToBounds = true
        floatingButton.layer.cornerRadius = 3.0
        backingImageView.image = backingImage
        
        
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
    
    @IBAction func tripleDots(_ sender: UIButton) {
        let alert = UIAlertController(title: "Unblock User?", message: "", preferredStyle: .actionSheet)
            
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            unblockUser(username: blockedUsers[sender.tag], user: userData)
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.sourceView = self.view
        }
        
        present(alert, animated: true)
    }
    
    fileprivate func configureTableView() {
        tableView.removeExtraCellLines()
        tableView.separatorInset = UIEdgeInsets.zero

        if traitCollection.userInterfaceStyle == .dark {
            cardView.backgroundColor = .systemGray5
        }
        else {
            cardView.backgroundColor = .white
        }
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

}

class BlockedUserCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var dots: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if traitCollection.userInterfaceStyle == .dark {
            dots.tintColor = .white
            // newPost.backgroundColor = .white
            // newPost.tintColor = .black
            // postContainer.backgroundColor = .white
            // postContainer.tintColor = .black
        }
        else {
            dots.tintColor = .black
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            dots.tintColor = .white
            
        }
        else {
            dots.tintColor = .black
            
        }
    }
}


