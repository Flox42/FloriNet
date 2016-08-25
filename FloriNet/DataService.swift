//
//  DataService.swift
//  FloriNet
//
//  Created by Florian Poncelin on 22/08/2016.
//  Copyright © 2016 Florian Poncelin. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    static let ds = DataService()
    
    var dbRef = FIRDatabase.database().reference()
    var userID = FIRAuth.auth()?.currentUser?.uid
    var postRef = FIRDatabase.database().referenceWithPath("posts")
    var userRef = FIRDatabase.database().referenceWithPath("users")
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        userRef.child(uid).setValue(user)
    }
}