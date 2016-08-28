//
//  ViewController.swift
//  FloriNet
//
//  Created by Florian Poncelin on 18/08/2016.
//  Copyright © 2016 Florian Poncelin. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if user != nil {
                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
            }
        })*/
        userDidLogIn()
    }
    
    func userDidLogIn() {
        if FIRAuth.auth()?.currentUser != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func fbBtnPressed(sender: UIButton!) {
        let fbLogin = FBSDKLoginManager()
        fbLogin.logInWithReadPermissions(["email"], fromViewController: nil) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) in
            
            if facebookError != nil {
                print("Facebook login failed. Error: \(facebookError.debugDescription)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with Facebook. Token: \(accessToken)")
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(accessToken)
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    
                    if error != nil {
                        print("Can't connect to Firebase with Facebook login. Error: \(error)")
                    } else {
                        print("Connected to Firebase with Facebook login. User: \(user?.uid)")
                        
                        DataService.ds.userRef.child("\(user!.uid)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            if snapshot.exists() {
                                print("Facebook Snapshot: \(snapshot)")
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            } else {
                                let accountInfo = ["userId": user!.uid, "provider": "facebook"]
                                self.performSegueWithIdentifier(SEGUE_SIGN_UP, sender: accountInfo)
                            }
                        })
                    }
                })

            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_SIGN_UP {
            if let signUpVC = segue.destinationViewController as? SignUpVC {
                if let accountInfo = sender as? Dictionary<String, String> {
                    signUpVC.accountDict = accountInfo
                    signUpVC.homeViewController = self
                }
            }
        }
    }
    
    @IBAction func loginBtnPressed(sender: UIButton!) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            FIRAuth.auth()?.signInWithEmail(email, password: pwd, completion: { (user, error) in
                
                if error != nil {
                    print(error)
                    
                    if error?.code == STATUS_ACCOUNT_NONEXIST {
                        let accountInfo = ["provider": "password", "email": email, "password": pwd]
                        self.performSegueWithIdentifier(SEGUE_SIGN_UP, sender: accountInfo)
                    } else {
                        self.showErrorAlert("Could not log in", msg: "Please check your username and password")
                    }
                    
                } else {
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            showErrorAlert("Email and password required", msg: "Please enter an email and password")
        }
    }
}

