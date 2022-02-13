//
//  enlargedImage.swift
//  Mayven
//
//  Created by Kevin Chan on 2021-05-27.
//
import UIKit
import Photos

class enlargedImage: UIViewController {
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var toolbarView: UIView!
    
    var postLink = String()
    
    var flag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postImage.sd_setImage(with: URL(string: postLink)!, placeholderImage: UIImage() )

        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        scrollView.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        scrollView.addGestureRecognizer(tap)
    }
    
    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    @IBAction func exitPressed(_ sender: UIButton) {
        unwind()
    }

    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func downloadImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Save Image", message: "Would you like to save this image?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Save Image", style: .default, handler: { [self] action in
            
            
            let alert = UIAlertController(title: "Allow access to your photos in the settings to save your photo", message: "", preferredStyle: .alert)
                
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                if let url = NSURL(string: UIApplication.openSettingsURLString) as URL? {
                    UIApplication.shared.open(url)
                }
            }))
                
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
            }))
            
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    switch status {
                    case .limited:
                        print("limited")
                        // handle the case
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                    case .authorized:
                        // ...
                        print("authorized")
                        DispatchQueue.main.async {
                            UIImageWriteToSavedPhotosAlbum(postImage.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                        }
                    case .denied:
                        // ...
                        print("denied")
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                    case .restricted:
                        fallthrough
                    // ...
                    case .notDetermined:
                        // ...
                        print("not deterimined")
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                    default:
                        PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
                    }
                }
            } else {
                // Fallback on earlier versions
                if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async {
                        UIImageWriteToSavedPhotosAlbum(postImage.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
                else {
                    PHPhotoLibrary.requestAuthorization(requestAuthorizationHandlerOld)
                }
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if flag == false {
            toolbarView.isHidden = false
            
            flag = true
        }
        else {
            toolbarView.isHidden = true
            
            flag = false
        }
    }
    
    func unwind() {
        
        performSegue(withIdentifier: "unwind", sender: self)
        
    }
}

extension enlargedImage: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = postImage.image {
                let ratioW = postImage.frame.width / image.size.width
                let ratioH = postImage.frame.height / image.size.height
                
                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let conditionLeft = newWidth*scrollView.zoomScale > postImage.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - postImage.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                let conditioTop = newHeight*scrollView.zoomScale > postImage.frame.height
                
                let top = 0.5 * (conditioTop ? newHeight - postImage.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return postImage
    }
}
