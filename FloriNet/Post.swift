//
//  Post.swift
//  FloriNet
//
//  Created by Florian Poncelin on 25/08/2016.
//  Copyright © 2016 Florian Poncelin. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postDescription: String!
    private var _postImgUrl: String?
    private var _postUserImgUrl: String?
    private var _postLikes: Int!
    private var _postUserKey: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var postDescription: String {
        return _postDescription
    }
    
    var postImgUrl: String? {
        return _postImgUrl
    }
    
    var postUserImgUrl: String? {
        return _postUserImgUrl
    }
    
    var postLikes: Int {
        return _postLikes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var postUserKey: String {
        return _postUserKey
    }
    
    init(description: String, imgUrl: String?, userImgUrl: String?) {
        self._postDescription = description
        self._postImgUrl = imgUrl
        self._postUserImgUrl = userImgUrl
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
        
        if let userKey = dictionary["userKey"] as? String {
            self._postUserKey = userKey
        }
        
        DataService.ds.userRef.child("\(self._postUserKey)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let userImgUrl = snapshot.value!["imageUrl"] as? String {
                self._postUserImgUrl = userImgUrl
            }
        })
        
        self._postRef = DataService.ds.postRef.child(self._postKey)
    }
    
    func editLikes(addedLike: Bool) {
        if addedLike {
            _postLikes = _postLikes + 1
        } else {
            _postLikes = _postLikes - 1
        }
        
        _postRef.child("likes").setValue(_postLikes)
    }
}