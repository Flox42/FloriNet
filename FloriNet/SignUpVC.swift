//
//  SignUpVC.swift
//  FloriNet
//
//  Created by Florian Poncelin on 28/08/2016.
//  Copyright © 2016 Florian Poncelin. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {

    @IBOutlet weak var usernameTxtField: MaterialTextField!
    @IBOutlet weak var passwordTxtField: MaterialTextField!
    @IBOutlet weak var verifyPwdTxtField: MaterialTextField!
    
    
    var accountDict: [String : String]!
    var homeViewController: ViewController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if accountDict["provider"] == "facebook" {
            passwordTxtField.hidden = true
            verifyPwdTxtField.hidden = true
        } else if accountDict["provider"] == "password" {
            passwordTxtField.text = accountDict["password"]
        }
    }

    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func signupBtnPressed(sender: AnyObject) {
        DataService.ds.userRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            var isUsernameAvailable = true
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let username = snap.value!["username"] as? String {
                        if username == self.usernameTxtField.text {
                            isUsernameAvailable = false
                        }
                    }
                }
            }
            
            if isUsernameAvailable {
                if self.accountDict["provider"] == "facebook" {
                    let userDict = ["provider": "facebook", "username": "\(self.usernameTxtField.text!)"]
                    DataService.ds.createFirebaseUser(self.accountDict["userId"]!, user: userDict)
                    self.dismissViewControllerAnimated(true, completion: {
                        self.homeViewController.userDidLogIn()
                    })
                } else if self.accountDict["provider"] == "password" {
                    if self.passwordTxtField.text! == self.verifyPwdTxtField.text! {
                         FIRAuth.auth()?.createUserWithEmail(self.accountDict["email"]!, password: "\(self.passwordTxtField.text!)", completion: { (user, error) in

                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem creating account. Try something else")
                            } else {
                                FIRAuth.auth()?.signInWithEmail(self.accountDict["email"]!, password: "\(self.passwordTxtField.text!)", completion: { (user, error) in
                                    let userDict = ["provider": "password", "username": "\(self.usernameTxtField.text!)"]
                                    DataService.ds.createFirebaseUser(user!.uid, user: userDict)
                                    self.dismissViewControllerAnimated(true, completion: { 
                                        self.homeViewController.userDidLogIn()
                                    })
                                })
                            }
                         })
                    } else {
                        self.showErrorAlert("Passwords don't match", msg: "Please check your passwords")
                    }
                }
            } else {
                self.showErrorAlert("Username not available", msg: "This username is already used, please choose something else")
            }
        })
    }
    
    @IBAction func closeBtnPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
