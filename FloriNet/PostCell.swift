//
//  PostCell.swift
//  FloriNet
//
//  Created by Florian Poncelin on 24/08/2016.
//  Copyright © 2016 Florian Poncelin. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    var post: Post!
    var request: Request?
    var userImgRequest: Request?
    var likeRef: FIRDatabaseReference!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeImgTapped(_:)))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }

    func configureCell(post: Post, img: UIImage?, userImg: UIImage?) {
        self.post = post
        
        DataService.ds.userRef.child("\(post.postUserKey)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let username = snapshot.value!["username"] as? String {
                self.usernameLbl.text = username
            }
            
            if post.postUserImgUrl != nil {
                if userImg != nil {
                    self.profileImg.image = userImg
                } else {
                    self.userImgRequest = Alamofire.request(.GET, post.postUserImgUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                        
                        if err == nil {
                            let img = UIImage(data: data!)!
                            self.profileImg.image = img
                            FeedVC.imgCache.setObject(img, forKey: self.post.postUserImgUrl!)
                        }
                    })
                }
                
            }
        })
        
        self.likeRef = DataService.ds.userRef.child("\(DataService.ds.userID!)/likes").child(post.postKey)
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.postLikes)"
        
        if post.postImgUrl != nil {
            
            if img != nil {
                self.showcaseImg.image = img
            } else {
                request = Alamofire.request(.GET, post.postImgUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        FeedVC.imgCache.setObject(img, forKey: self.post.postImgUrl!)
                    }
                })
            }
            
        } else {
            self.showcaseImg.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            
            if let doesNotExist = snapshot.value as? NSNull {
                //This means we have not liked this specific post
                self.likeImg.image = UIImage(named: "heart-empty")
            } else {
                self.likeImg.image = UIImage(named: "heart-full")
            }
            
        })
    }
    
    func likeImgTapped(sender: UIGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "heart-full")
                self.post.editLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "heart-empty")
                self.post.editLikes(false)
                self.likeRef.removeValue()
            }
            
        })
    }
}
