//
//  ViewController.swift
//  ChatApp
//
//  Created by Kevin Chan on 2021-01-24.
//

import UIKit
import Foundation
import Firebase
import BetterSegmentedControl
import GoogleMobileAds
import AdSupport
import AppTrackingTransparency
import SDWebImage
import LinkPresentation

var forumView = ForumView()

class ForumView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, GADUnifiedNativeAdLoaderDelegate {
    var nativeAds = [GADUnifiedNativeAd]()
    var adLoader: GADAdLoader!
    var numAdsToLoad = 0
    //let adUnitID = "ca-app-pub-3940256099942544/2247696110"
    let adUnitID = "ca-app-pub-3819604632178532/6708124752"
    //let adUnitID = "ca-app-pub-3940256099942544/1044960115"
    //let adUnitID = "ca-app-pub-3006656642202623/9497396089"
    var ads = [AnyObject]()
    var imgs = [UIImage?]()
    var impressionCount = 0
    var index = 5
    var secondIndex = 0
    var flag = false
    var imageRow = 0
    var itemCount = 0
    var adFlag = false
    var totalAds = 0
    
    var color = UIColor.white
    
    private var provider = LPMetadataProvider()
    private var linkView = LPLinkView()
    
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        tableView.reloadData()
        adFlag = true
        loadingActivity.isHidden = true
        loadingActivity.stopAnimating()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        nativeAd.delegate = self
        if(adFlag == false) {
            if(nativeAds.count != numAdsToLoad) {
                print("Native Ad appended")
                nativeAds.append(nativeAd)
            }
            
            
            
            if(nativeAds.count == numAdsToLoad && numAdsToLoad > 0) {
                addNativeAds()
            }
        }
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        
        //print("Finished loading")
        //addNativeAds()
    }
    
    var tempData = [[String: Any]]()
    var currIndex = 0
    var refreshControl = UIRefreshControl()
    var communityChosen = String()
    var isLoading = false
    var originalCount = 0
    
    @IBOutlet weak var ifTableEmpty: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newPost: UIButton!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var flameIcon: UIButton!
    @IBOutlet var myView: UIView!
    @IBOutlet weak var segmentHeight: NSLayoutConstraint!
    var adIndex = 0;
    
    @IBAction func betterSegmentAction(_ sender: BetterSegmentedControl) {
        if(sender.index == 0) {
            currIndex = 0
            communityChosen = "All"
            
            loadingActivity.isHidden = false
            loadingActivity.startAnimating()
            
            refreshData()
        }
        else {
            currIndex = 1
            communityChosen = userData["programCode"]!
            
            loadingActivity.isHidden = false
            loadingActivity.startAnimating()
            
            refreshData()
        }
    }
    
    @IBOutlet weak var betterSegment: BetterSegmentedControl!
    let user = Auth.auth().currentUser;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        forumView = self
        communityChosen = "All"
        // userData = retrieveUserData()
        
        //   firebaseLogout()
        loadingActivity.isHidden = false
        loadingActivity.startAnimating()
        
        currIndex = 0

        //flameIcon.imageView!.tintColor = .white
        let img = UIImage(named: "flame")?.withTintColor(.white)
        flameIcon.setBackgroundImage(img, for: .normal)
        
        let screenSize = UIScreen.main.bounds
        print("SCREEN: ", screenSize.height)
        
        if(screenSize.height < 800) {
            // betterSegment.he
            betterSegment.frame.size.height = 10//betterSegment.frame.size.height - 20
            // betterSegment.frame.height = 10
            //updateConstraints()
            
            
        }
        
        //  userData = retrieveUserData()
        
        betterSegment.segments = LabelSegment.segments(withTitles: ["ALL", userData["programCode"]!])
        configureTableView()
        tableView.refreshControl = refreshControl
        tableView.backgroundView = refreshControl
        tableView.register(UINib(nibName: "UnifiedNativeAdCell", bundle: nil),
                           forCellReuseIdentifier: "UnifiedNativeAdCell")
        tableView.register(UINib(nibName: "LoadMore", bundle: nil), forCellReuseIdentifier: "tableviewloadingcellid")
        // refreshData()
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        
        
    }
    
    
    func updateConstraints() {
        // You should handle UI updates on the main queue, whenever possible
        DispatchQueue.main.async {
            self.segmentHeight.constant -= 20
            self.myView.layoutIfNeeded()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(homeStartup == true) {
            print("STARTUP = TRUE")
            userData = retrieveUserData()
            
            configureTableView()
            
            betterSegment.reloadInputViews()
            
            refreshData()
            
            homeStartup = false
            
            // tableView.reloadData()
        }
        //print(userData)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            color = .systemGray5
            tableView.backgroundColor = .systemGray5
            flameIcon.tintColor = .white
            newPost.tintColor = .white
            view.backgroundColor = .black
            betterSegment.segments = LabelSegment.segments(withTitles: ["ALL", userData["programCode"]!],normalTextColor: .white, selectedTextColor: UIColor(displayP3Red: 96/255, green: 176/255, blue: 244/255, alpha: 1))
            
        }
        else {
            color = .white
            view.backgroundColor = .white
            flameIcon.tintColor = .black
            newPost.tintColor = .black
            tableView.backgroundColor = .white
            betterSegment.segments = LabelSegment.segments(withTitles: ["ALL", userData["programCode"]!],normalTextColor: .black, selectedTextColor: UIColor(displayP3Red: 96/255, green: 176/255, blue: 244/255, alpha: 1))
            
        }
    }
    
    func addNativeAds(){
        if nativeAds.count <= 0 {
            print("No ads")
            return
        }
        
        for nativeAd in nativeAds {
            var temp = [String: Any]()
            temp["postType"] = "ad"
            temp["adData"] = nativeAd
            
            // 0 1 2 3 4  AD  6 7 8 9 10  AD  12 13 14 15 16  AD  17 18 19 20 21  AD
            
            //      print(tempData.count, " Original Count: ", originalCount, " totalAds: ", totalAds)
            
            tempData.insert(temp, at: index + secondIndex)
            index += 5
            secondIndex += 1
            
        }
        
        tableView.reloadData()
        loadingActivity.isHidden = true
        loadingActivity.stopAnimating()
        adFlag = true
    }
    
    @objc func refreshData() {
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        
        adFlag = false
        tempData.removeAll()
        ads.removeAll()
        numAdsToLoad = 0
        nativeAds.removeAll()
        index = 5
        secondIndex = 0
        
        isLoading = false
        
        totalAds = 0
        tableView.reloadData()
        
        sortData()
    }
    
    func sortData() {
        var currProgram = ""
        if(currIndex == 0) {
            currProgram = "All"
            communityChosen = currProgram
        }
        else {
            currProgram = userData["programCode"]!
            communityChosen = currProgram
        }
        
        var theOrder = ""
        if(flameIcon.tintColor == .white || flameIcon.tintColor == .black) {
            theOrder = "timestamp"
        }
        else {
            theOrder = "likes"
        }
        
        retrievePost(program: currProgram, schoolId: userData["school"]!, orderBy: theOrder) { returnData in
            if(!returnData.isEmpty){
                self.tempData = returnData
                self.originalCount = self.tempData.count
                self.ifTableEmpty.isHidden = true
                if #available(iOS 14, *) {
                    ATTrackingManager.requestTrackingAuthorization(completionHandler: { [self] status in
                        var idfa: UUID {
                            return ASIdentifierManager.shared().advertisingIdentifier
                        }
                        
                        DispatchQueue.main.async {
                            
                            self.addAds(count: Int(floor(Double(self.tempData.count/5))))
                            
                            if(tempData.count < 5) {
                                self.loadingActivity.isHidden = true
                                self.loadingActivity.stopAnimating()
                                self.tableView.reloadData()
                            }
                            
                            // self.tableView.reloadData()
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        self.addAds(count: Int(floor(Double(self.tempData.count/5))))
                        
                        if(self.tempData.count < 5) {
                            self.loadingActivity.isHidden = true
                            self.loadingActivity.stopAnimating()
                            self.tableView.reloadData()
                        }
                        // self.tableView.reloadData()
                    }
                }
            }
            else {
                self.tempData.removeAll()
                self.ads.removeAll()
                self.nativeAds.removeAll()
                self.tableView.reloadData()
                self.numAdsToLoad = 0
                self.ifTableEmpty.isHidden = false
                self.loadingActivity.isHidden = true
                self.loadingActivity.stopAnimating()
                
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    func loadMoreData() {
        if !self.isLoading {
            self.isLoading = true
            adFlag = false
            
            nativeAds.removeAll()
            
            var currProgram = ""
            if(currIndex == 0) {
                currProgram = "All"
            }
            else {
                currProgram = userData["programCode"]!
            }
            
            var theOrder = ""
            if(flameIcon.tintColor == .white || flameIcon.tintColor == .black) {
                theOrder = "timestamp"
            }
            else {
                theOrder = "likes"
            }
            
            
            DispatchQueue.global().async {
                sleep(2)
                DispatchQueue.main.async {
                    var tempIndex = 0
                    if(self.tempData.count < 5) {
                        tempIndex = self.tempData.count-1
                    }
                    else if(self.tempData[self.tempData.count-1]["postType"] as! String == "ad") {
                        tempIndex = self.tempData.count-2
                        //  print("ad: ", tempIndex)
                        
                    }
                    else {
                        tempIndex = self.tempData.count-1
                        //    print("Not ad: ", tempIndex)
                    }
                    
                    
                    if(self.tempData.count > 5) {
                        
                        retrievePostFrom(program: currProgram, schoolId: userData["school"]!, orderBy: theOrder, start: self.tempData[tempIndex]["lastDocument"]!) { returnData in
                            
                            self.tempData.append(contentsOf: returnData)
                            self.originalCount += returnData.count
                            
                            if #available(iOS 14, *) {
                                ATTrackingManager.requestTrackingAuthorization(completionHandler: { [self] status in
                                    var idfa: UUID {
                                        return ASIdentifierManager.shared().advertisingIdentifier
                                    }
                                    
                                    DispatchQueue.global().async {
                                        DispatchQueue.main.async {
                                            //print("NEW AD ADD: ", Int(floor(Double(returnData.count/5))))
                                            
                                            
                                            self.addAds(count: Int(floor(Double(returnData.count/5))) )
                                            
                                            if(returnData.count < 5) {
                                                self.loadingActivity.isHidden = true
                                                self.loadingActivity.stopAnimating()
                                                self.tableView.reloadData()
                                            }
                                            
                                            self.isLoading = false
                                            self.tableView.reloadData()
                                        }
                                    }
                                })
                            } else {
                                DispatchQueue.global().async {
                                    DispatchQueue.main.async {
                                        //  print("NEW AD ADD: ", Int(floor(Double(returnData.count/5))))
                                        self.addAds(count: Int(floor(Double(returnData.count/5))) )
                                        
                                        if(returnData.count < 5) {
                                            self.loadingActivity.isHidden = true
                                            self.loadingActivity.stopAnimating()
                                            self.tableView.reloadData()
                                        }
                                        
                                        
                                        self.isLoading = false
                                        self.tableView.reloadData()
                                    }
                                }
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
    
    func addAds(count: Int) {
        
        //   self.ads.removeAll()
        //   self.nativeAds.removeAll()
        self.totalAds += count
        self.numAdsToLoad = count
        //  print("Ads to load: ", count)
        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = self.numAdsToLoad
        self.adLoader = GADAdLoader(adUnitID: self.adUnitID,
                                    rootViewController: self,
                                    adTypes: [.unifiedNative],
                                    options: [options])
        self.adLoader.delegate = self
        self.adLoader.load(GADRequest())
        //    addNativeAds()
    }
    
    @IBAction func newPostButton(_ sender: UIButton) {
        //  handleMore()
    }
    
    fileprivate func configureTableView() {
        tableView.removeExtraCellLines()
        tableView.separatorInset = UIEdgeInsets.zero
        
        if traitCollection.userInterfaceStyle == .dark {
            tableView.backgroundColor = .systemGray5
            color = .systemGray5
            flameIcon.tintColor = .white
            newPost.tintColor = .white
            view.backgroundColor = .black
            betterSegment.segments = LabelSegment.segments(withTitles: ["ALL", userData["programCode"]!],normalTextColor: .white, selectedTextColor: UIColor(displayP3Red: 96/255, green: 176/255, blue: 244/255, alpha: 1))
            
        }
        else {
            view.backgroundColor = .white
            color = .white
            flameIcon.tintColor = .black
            newPost.tintColor = .black
            tableView.backgroundColor = .white
            betterSegment.segments = LabelSegment.segments(withTitles: ["ALL", userData["programCode"]!],normalTextColor: .black, selectedTextColor: UIColor(displayP3Red: 96/255, green: 176/255, blue: 244/255, alpha: 1))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            //Return the amount of items
            //print("COUNT: ", tempData.count)
            return tempData.count
        } else if section == 1 {
            //Return the Loading cell
            return 1
        } else {
            //Return nothing
            return 0
        }
    }
    
    
    /*   func scrollViewDidScroll(_ scrollView: UIScrollView) {
     let offsetY = scrollView.contentOffset.y
     let contentHeight = scrollView.contentSize.height
     
     if (offsetY > contentHeight - scrollView.frame.height * 4) && !isLoading {
     // if(tempData.count > 10) {
     print("WORKED")
     
     loadMoreData()
     
     }
     }
     
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height && !isLoading && tempData.count > 9 && loadingActivity.isHidden {
            print(" you reached end of the table")
            
            loadMoreData()
            
        }
    }
    
    
    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     if indexPath.row + 1 == tempData.count {
     print("do something")
     }
     }
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0 && tempData.count > 0){
            if(tempData[indexPath.row]["postType"] as! String == "ad") {
                let nativeAdCell = tableView.dequeueReusableCell(
                    withIdentifier: "UnifiedNativeAdCell", for: indexPath)
                let adView : GADUnifiedNativeAdView = nativeAdCell.contentView.subviews
                    .first as! GADUnifiedNativeAdView
                adIndex = Int(floor(Double(indexPath.row/5)))-1
                let nativeAd = tempData[indexPath.row]["adData"] as! GADUnifiedNativeAd
                nativeAd.rootViewController = self
                nativeAd.delegate = self
                adView.nativeAd = nativeAd
                (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
                
                if(nativeAd.icon?.image == nil) {
                    (adView.iconView as? UIImageView)?.image = UIImage(named: "ic_person")
                }
                
                (adView.headlineView as! UILabel).text = nativeAd.headline
                adView.iconView!.layer.cornerRadius = adView.iconView!.frame.size.width/2
                adView.iconView!.layer.masksToBounds = true
                (adView.bodyView as! UILabel).text = nativeAd.body
                adView.mediaView?.mediaContent = nativeAd.mediaContent
                adView.mediaView?.isUserInteractionEnabled = true
                adView.iconView?.isUserInteractionEnabled = true
                adView.bodyView?.isUserInteractionEnabled = true
                (adView.advertiserView as! UILabel).text = nativeAd.advertiser
                return nativeAdCell
            }
            else {
                let index = indexPath.row
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ForumCell
                cell.photo?.layer.cornerRadius = cell.photo.frame.size.width/2
                cell.photo?.clipsToBounds = true
                cell.txt?.text = tempData[index]["text"] as? String
                cell.txt?.layer.masksToBounds = true
                let numLikes = tempData[index]["usersLiked"] as? [String]
                
                cell.likes?.text = String(numLikes!.count)
                
                let replies = tempData[index]["replyCount"] as! Int
                
                if(replies == 1) {
                    cell.replies?.text = "1 reply"
                    
                }
                else {
                    cell.replies?.text = String(replies) + " replies"
                }
                
                
                
                //      cell.replies?.text = String(replies)
                
                
                cell.name?.text = tempData[index]["ownerName"] as? String
                cell.heart.tag = indexPath.row
                cell.photo.tag = indexPath.row
                cell.dots.tag = indexPath.row
                cell.postImg.tag = indexPath.row
                
                //------User Image
                
                let userId = tempData[index]["ownerId"] as! String
                let url = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Thumbnail%2F" + userId + ".jpeg?alt=media&token="
                
                //   DispatchQueue.main.async {
                
                cell.photo?.sd_setBackgroundImage(with: URL(string: url)!, for: .normal, placeholderImage: UIImage(named:"placeholderImg") )
                
                cell.photo?.layoutIfNeeded()
                cell.photo?.subviews.first?.contentMode = .scaleAspectFill
                //    }
                
                /* if(cell.photo.currentBackgroundImage == UIImage(named: "placeholderImg")) {
                 cell.photo.setBackgroundImage(UIImage(named:"ic_person"), for: .normal)
                 }*/
                
                //------User Image
                
                let today = Date().timeIntervalSince1970
                let postTime = tempData[index]["timestamp"] as? Double
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
                cell.timePosted?.text = String(elapsedTime) + timeSign
                if traitCollection.userInterfaceStyle == .dark {
                    //cell.separatorBar?.backgroundColor = .black
                }
                var bool = false
                if(numLikes!.contains(userData["username"]!)) {
                    bool = true
                }
                if(bool == true) {
                    cell.heart?.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                }
                else {
                    cell.heart?.setImage(UIImage(systemName: "heart"), for: .normal)
                }
                
                if(tempData[index]["type"] as! String == "image") {
                    cell.postImgHeight.constant = 250
                    cell.imageTopConst.constant = 20
                    cell.stackView.isHidden = true
                    cell.postImg.isHidden = false
                    
                    let docId = tempData[index]["docId"] as! String
                    let imageThumbnail = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Post%2FThumbnail%2F" + docId + ".jpeg?alt=media&token="
                    
                    cell.postImg.sd_setBackgroundImage(with: URL(string: imageThumbnail)!, for: .normal, placeholderImage: UIImage(named: "placeholderImg") )
                    
                    cell.postImg?.layoutIfNeeded()
                    cell.stackView.isHidden = true
                    
                    cell.postImg?.subviews.first?.contentMode = .scaleAspectFit
                }
                else if(tempData[index]["type"] as! String == "link") {
                    
                    var link = tempData[index]["link"] as! String
                    link = "https://" + link
                    cell.stackView.isHidden = false
                    cell.postImg.isHidden = true
                    cell.stackViewTopConst.constant = 20
                    
                    cell.imageTopConst.constant = 10
                    
                    cell.postImgHeight.constant = 295
                    cell.postImg.frame.size.height = 295
                    
                
                    var tempLink = LPLinkView()
                    let url = URL(string: link)!
          
                    if let existingMetadata = retrieve(urlString: url.absoluteString) {
                      tempLink = LPLinkView(metadata: existingMetadata)

                    } else {
                      // 2. If it doesn't start the fetch
                      provider = LPMetadataProvider()
                      provider.startFetchingMetadata(for: url) { [weak self] metadata, error in
                        guard let self = self else { return }

                        guard
                          let metadata = metadata,
                          error == nil
                          else {
                            if (error as? LPError) != nil {
                              DispatchQueue.main.async { [weak self] in
                                guard self != nil else { return }

                              }
                            }
                            return
                        }

                        // 3. And cache the new metadata once you have it
                        cache(metadata: metadata)

                        // 4. Use the metadata
                        DispatchQueue.main.async { [weak self] in
                          guard let self = self else { return }

                          tempLink.metadata = metadata
                            
                            if(cell.stackView.arrangedSubviews.count == 0) {
                                cell.stackView.insertArrangedSubview(tempLink, at: 0)
                            }

                        }
                      }
                    }

                    
                    cell.stackView.distribution = .fillProportionally
                    cell.stackView.sizeToFit()
                    cell.stackView.layoutIfNeeded()
  
                }
                else {
                    cell.imageTopConst.constant = 0
                    cell.postImgHeight.constant = 0
                    cell.stackView.isHidden = true
                    cell.postImg.isHidden = true
                }
                
                
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
    
    private func fetchMetadata(for url: URL) {
      // 1. Check if the metadata exists
      
    }
    
    
    @IBAction func postImagePressed(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let docType = tempData[indexPath.row]["type"] as! String
        if(docType == "image") {
            self.imageRow = indexPath.row
            
            guard let reactionVC = storyboard?.instantiateViewController(withIdentifier: "EnlargedImageController")
                    as? enlargedImage else {
                
                assertionFailure("No view controller in storyboard")
                return
            }
            
            // take a snapshot of current view and set it as backingImage
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
                let docId = self.tempData[indexPath.row]["docId"] as! String
                let imageThumbnail = "https://firebasestorage.googleapis.com/v0/b/chatapp-6d978.appspot.com/o/Post%2F" + docId + ".jpeg?alt=media&token="
                
                reactionVC.postLink = imageThumbnail
                
                reactionVC.modalPresentationStyle = .fullScreen
                // present the view controller modally without animation
                self.present(reactionVC, animated: false, completion: nil)
            })
        }
        else if(docType == "link") {
            var link = tempData[indexPath.row]["link"] as! String
            
            if(!link.trimmingCharacters(in: .whitespaces).contains("https://") || !link.trimmingCharacters(in: .whitespaces).contains("http://")) {
                link = "https://" + link
            }
            
            
            
            if let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @IBAction func dotsPressed(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let docId = tempData[indexPath.row]["docId"] as? String
        let ownerId = tempData[indexPath.row]["ownerId"] as? String
        
        var title = ""
        var actionTxt = ""
        var msgTxt = ""
        
        if(ownerId == userData["username"]!) {
            title = "Delete this post?"
            actionTxt = "Delete"
            msgTxt = "Would you like to delete this post?"
        }
        else {
            title = "Report this post?"
            actionTxt = "Report"
            msgTxt = "Would you like to report this post?"
        }
        
        
        let alert = UIAlertController(title: title, message: msgTxt, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: actionTxt, style: .destructive, handler: { action in
            if(actionTxt == "Delete") {
                firebaseDeletePost(docId: docId!)
                self.tempData.remove(at: indexPath.row)
                
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
                if(self.tempData.count == 0) {
                    self.ifTableEmpty.isHidden = false
                    self.tableView.reloadData()
                }
                
            }
            else {
                self.reportPost(index: indexPath.row, indexPath: indexPath)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        }))
        
        if let popoverPresentationController = alert.popoverPresentationController {
            
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.sourceView = self.view
            
        }
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    
    func reportPost(index: Int, indexPath: IndexPath) {
        if((tempData[index]["reports"] as! [String]).count + 1 >= 5) {
            firebaseSendReportPost(docId: tempData[index]["docId"] as! String, postOwner: tempData[index]["ownerId"] as! String, text: tempData[index]["text"] as! String)
            tempData.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if(self.tempData.count == 0) {
                self.ifTableEmpty.isHidden = false
                self.tableView.reloadData()
            }
        }
        else {
            firebaseIncrementReportPost(docId: tempData[index]["docId"] as! String, user: userData)
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
    
    @IBAction func liked(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! ForumCell
        var numLikes = tempData[indexPath.row]["usersLiked"] as? [String]
        
        if(cell.heart.currentImage == UIImage(systemName: "heart.fill")) { // Unlike
            cell.heart.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.likes.text = String(numLikes!.count-1)
            firebaseUnlike(user: userData, postId: tempData[indexPath.row]["docId"] as! String)
            let index = numLikes?.firstIndex(of: userData["username"]!)
            numLikes?.remove(at: index!)
            tempData[indexPath.row]["usersLiked"] = numLikes
        }
        else if(cell.heart.currentImage == UIImage(systemName: "heart")) { // Like
            cell.heart.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            cell.likes.text = String(numLikes!.count+1)
            cell.name.adjustsFontSizeToFitWidth = true
            cell.txt.adjustsFontSizeToFitWidth = true
            firebaseLikes(user: userData, postId: tempData[indexPath.row]["docId"] as! String)
            numLikes?.append(userData["username"]!)
            tempData[indexPath.row]["usersLiked"] = numLikes
        }
    }
    
    @IBAction func imagePressed(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        
        self.imageRow = indexPath.row
        
        guard let reactionVC = storyboard?.instantiateViewController(withIdentifier: "ReactionViewController")
                as? OthersAccount else {
            
            assertionFailure("No view controller in storyboard")
            return
        }
        
        // take a snapshot of current view and set it as backingImage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
            reactionVC.backingImage = self.tabBarController?.view.asImage()
            reactionVC.ownerId = self.tempData[self.imageRow]["ownerId"] as! String
            
            reactionVC.modalPresentationStyle = .fullScreen
            // present the view controller modally without animation
            self.present(reactionVC, animated: false, completion: nil)
        })
    }
    
    @IBAction func flameButton(_ sender: UIButton) {
        if(flameIcon.tintColor == .white || flameIcon.tintColor == .black) {
            flameIcon.setBackgroundImage(UIImage(named: "flame"), for: .normal)
            flameIcon.tintColor = .orange
            if(!tempData.isEmpty){
                loadingActivity.isHidden = false
                loadingActivity.startAnimating()
                refreshData()
            }
        }
        else {
            flameIcon.setBackgroundImage(UIImage(named: "flame"), for: .normal)
            if traitCollection.userInterfaceStyle == .dark {
                flameIcon.tintColor = .white
            }
            else {
                flameIcon.tintColor = .black
            }
            
            if(!tempData.isEmpty){
                loadingActivity.isHidden = false
                loadingActivity.startAnimating()
                refreshData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailView {
            let index = tableView.indexPathForSelectedRow!.row
            let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as! ForumCell
            let btnIndex = cell.heart.tag
            
            vc.docId = tempData[index]["docId"] as! String
            vc.segmentIndex = currIndex
            vc.buttonTag = btnIndex
            
            vc.indexPath = index
            vc.originalPost = tempData[index]
            self.isLoading = false
            
            
            
            if(cell.heart.currentImage == UIImage(systemName: "heart.fill")) {
                vc.isLiked = true
            }
            else {
                vc.isLiked = false
            }
        }
        if let vc = segue.destination as? AddPost {
            vc.communityChosen = communityChosen
            vc.segmentIndex = currIndex
        }
        
        
    }
    
    @IBAction func unwind(_ seg: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindDelete(segue:UIStoryboardSegue) {
        //   return
    }
}

extension UITableView {
    func removeExtraCellLines() {
        tableFooterView = UIView(frame: .zero)
    }
}

extension ForumView : GADUnifiedNativeAdDelegate {
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
        print("Impression")
    }
}

class ForumCell: UITableViewCell {
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var heart: UIButton!
    @IBOutlet weak var txt: UILabel!
    @IBOutlet weak var replies: UILabel!
    @IBOutlet weak var photo: UIButton!
    @IBOutlet weak var separatorBar: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var dots: UIButton!
    @IBOutlet weak var postImg: UIButton!
    @IBOutlet weak var postImgHeight: NSLayoutConstraint!
    @IBOutlet weak var imageTopConst: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
 //   @IBOutlet weak var stackViewConst: NSLayoutConstraint!
    @IBOutlet weak var stackViewTopConst: NSLayoutConstraint!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        txt.adjustsFontSizeToFitWidth = false
        txt.lineBreakMode = .byTruncatingTail
        
        if traitCollection.userInterfaceStyle == .dark {
            dots.tintColor = .white
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

class AdCell: UITableViewCell {
    @IBOutlet weak var advertiserView: UIView!
    @IBOutlet weak var advertiserName: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var visitSite: UIButton!
    @IBOutlet weak var sponsored: UILabel!
}

class LoadingCell: UITableViewCell {
    
    @IBOutlet weak var startAnimating: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        self.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
    }
}


enum UIUserInterfaceIdiom : Int {
    case unspecified
    
    case phone // iPhone and iPod touch style UI
    case pad   // iPad style UI (also includes macOS Catalyst)
}

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
