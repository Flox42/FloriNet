//
//  Post.swift
//  FloriNet
//
//  Created by Florian Poncelin on 25/08/2016.
//  Copyright © 2016 Florian Poncelin. All rights reserved.
//

import Foundation

class Post {
    private var _postDescription: String!
    private var _postImgUrl: String?
    private var _postLikes: Int!
    private var _postUsername: String!
    private var _postKey: String!
    
    var postDescription: String {
        return _postDescription
    }
    
    var postImgUrl: String? {
        return _postImgUrl
    }
    
    var postLikes: Int {
        return _postLikes
    }
    
    var postUsername: String {
        return _postUsername
    }
    
    init(description: String, imgUrl: String?, username: String) {
        self._postDescription = description
        self._postImgUrl = imgUrl
        self._postUsername = username
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        if let likes = dictionary["likes"] as? Int {
            self._postLikes = likes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._postImgUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
    }
}