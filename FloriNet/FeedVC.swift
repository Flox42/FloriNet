//
//  FeedVC.swift
//  FloriNet
//
//  Created by Florian Poncelin on 24/08/2016.
//  Copyright © 2016 Florian Poncelin. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectPreview: UIImageView!
    
    var imgPicker: UIImagePickerController!
    var posts = [Post]()
    var currentUsername: String!
    var isImgSelected = false
    static var imgCache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 360
        
        imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        postField.delegate = self
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if user != nil {
                // User is signed in. Happy times!
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
        
        DataService.ds.userRef.child("\(FIRAuth.auth()?.currentUser?.uid)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let username = snapshot.value!["username"] as? String {
                self.currentUsername = username
            } else {
                self.currentUsername = ""
            }
        })
        
        DataService.ds.postRef.observeEventType(.Value, withBlock:  { (snapshot) in
            print(snapshot.value)
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.posts = self.posts.reverse()
            
            self.tableView.reloadData()
        })
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.postImgUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            cell.request?.cancel()
            cell.userImgRequest?.cancel()
            
            var img: UIImage?
            var userImg: UIImage?
            
            if let url = post.postImgUrl {
                img = FeedVC.imgCache.objectForKey(url) as? UIImage
            }
            
            if let userImgUrl = post.postUserImgUrl {
                userImg = FeedVC.imgCache.objectForKey(userImgUrl) as? UIImage
            }
            
            cell.configureCell(post, img: img, userImg: userImg)
            return cell
        } else {
            return PostCell()
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imgPicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectPreview.image = image
        isImgSelected = true
    }
    
    
    func postToFirebase(imgUrl: String?) {
        
        var post: Dictionary<String, AnyObject> = [
            "description": postField.text!,
            "likes": 0,
            "userKey": DataService.ds.userID!,
            "timestamp": "\(NSDate().timeIntervalSince1970 * 1000)"
        ]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
        }
        
        let firebasePost = DataService.ds.postRef.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        imageSelectPreview.image = UIImage(named: "camera")
        isImgSelected = false
        
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func imageSelectTapped(sender: UITapGestureRecognizer) {
        presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnPressed(sender: AnyObject) {
        if let txt = postField.text where txt != "" {
            if let img = imageSelectPreview.image where isImgSelected {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
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
                                        self.postToFirebase(imgLink)
                                    }
                                }
                            }
                        })
                        
                    case .Failure(let error):
                        print(error)
                    }
                    
                }
            } else {
                self.postToFirebase(nil)
            }
        }
    }

}
