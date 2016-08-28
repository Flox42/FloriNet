//
//  AccountVC.swift
//  FloriNet
//
//  Created by Florian Poncelin on 27/08/2016.
//  Copyright © 2016 Florian Poncelin. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class AccountVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var addImgBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    
    var request: Request?
    var imgPicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self

        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clearColor()
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            self.view.insertSubview(blurEffectView, atIndex: 0)
        }
        
        profileImg.layer.cornerRadius = profileImg.layer.bounds.width / 2
        profileImg.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        DataService.ds.userRef.child("\(DataService.ds.userID!)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            print(snapshot.value)
            if let username = snapshot.value!["username"] as? String {
                self.usernameLbl.text = username
            }
            
            if let imgUrl = snapshot.value!["imageUrl"] as? String {
                self.request = Alamofire.request(.GET, imgUrl).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.profileImg.image = img
                        self.addImgBtn.setTitle("", forState: .Normal)
                        //FeedVC.imgCache.setObject(img, forKey: self.post.postImgUrl!)
                    }
                })
            }
            
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imgPicker.dismissViewControllerAnimated(true, completion: nil)
        profileImg.image = image
        self.addImgBtn.setTitle("", forState: .Normal)
        
        let urlStr = "https://post.imageshack.us/upload_api.php"
        let url = NSURL(string: urlStr)!
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
        let keyData = "1BEFIKRTe379b2c4e5281ba83de6325d06fd5a08".dataUsingEncoding(NSUTF8StringEncoding)!
        let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
        
        Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
            
            multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
            multipartFormData.appendBodyPart(data: keyData, name: "key")
            multipartFormData.appendBodyPart(data: keyJSON, name: "format")
            
        }) { encodingResult in
            
            switch encodingResult {
            case .Success(let upload, _, _):
                upload.responseJSON(completionHandler: { response in
                    if let info = response.result.value as? Dictionary<String, AnyObject> {
                        if let links = info["links"] as? Dictionary<String, AnyObject> {
                            if let imgLink = links["image_link"] as? String {
                                print("LINK: \(imgLink)")
                                
                                let firebaseUser = DataService.ds.userRef.child(DataService.ds.userID!)
                                firebaseUser.child("imageUrl").setValue(imgLink)
                            }
                        }
                    }
                })
                
            case .Failure(let error):
                print(error)
            }
            
        }
    }

    @IBAction func closeBtnPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addPictureBtnPressed(sender: AnyObject) {
        presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func signoutBtnPressed(sender: AnyObject) {
        do {
            dismissViewControllerAnimated(true, completion: nil)
            try FIRAuth.auth()?.signOut()
        } catch {
            print("Couldn't sign out")
        }
    }
    
}
