//
//  PostCell.swift
//  FloriNet
//
//  Created by Florian Poncelin on 24/08/2016.
//  Copyright © 2016 Florian Poncelin. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    var post: Post!
    var request: Request?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }

    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        
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
    }
}
