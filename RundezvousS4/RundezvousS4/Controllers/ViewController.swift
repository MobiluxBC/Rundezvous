//
//  ViewController.swift
//  RundezvousS4
//
//  Created by Niko Arellano on 2017-09-29.
//  Copyright © 2017 Mobilux. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    private let LOGIN_SEGUE = "LoginToMain"
    
    @IBOutlet weak var emailAddress: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signInWithGoogle: GIDSignInButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func alertTheUser(title : String, message : String) {
        let alert = UIAlertController(title : title, message : message, preferredStyle : .alert)
        
        let ok = UIAlertAction(title : "Ok", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        present(alert, animated : true, completion: nil)
    }

    @IBAction func signIn(_ sender: Any) {
        AuthProvider.Instance.login(withEmail : emailAddress.text!,
                                    withPassword: password.text!,
                                    loginHandler: {
                                        (_ success : Bool, _ message : String?) in
                                        
                                        if success {
                                            self.emailAddress.text = ""
                                            self.password.text = ""
                                            
                                            self.performSegue(withIdentifier: self.LOGIN_SEGUE, sender: nil)
                                        } else {
                                            self.alertTheUser(title : "Problem with the Authentication",
                                                              message : message!)
                                        }
                                        
        })
    }
    
    @IBAction func register(_ sender: Any) {
        AuthProvider.Instance.signUp(withEmail : emailAddress.text!,
                                     withPassword: password.text!,
                                     signUpHandler : {
                                        (_ success : Bool, _ message : String?) in
                                        
                                        if success {
                                            
                                            self.emailAddress.text = ""
                                            self.password.text = ""
                                            
                                        } else {
                                            self.alertTheUser(title : "Problem with Signing Up",
                                                              message : message!)
                                        }
        })
    }
}

// Google Related Stuff
extension ViewController {
    @IBAction func signInWithGoogle(_ sender: Any) {
        // Initialize sign-in
        
        GIDSignIn.sharedInstance().shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        //This did the trick for iOS 8 and the controller is presented now in iOS 8
        //We have to make allowsSignInWithBrowser false also. If we dont write this line and only write the 2nd line, then iOS 8 will not present a webview and again will take your flow outside the app in safari. So we have to write both the lines, Line 1 and Line 2
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    /**
     *
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let _ = error {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        AuthProvider.Instance.loginWithGoogleCredential(with: credential,
                                                        loginHandler: {
                                                            (_ success : Bool, _ message : String?) in
                                                            
                                                            if success {
                                                                self.emailAddress.text = ""
                                                                self.password.text = ""
                                                                
                                                                self.performSegue(withIdentifier: self.LOGIN_SEGUE, sender: nil)
                                                            } else {
                                                                self.alertTheUser(title : "Problem with the Authentication",
                                                                                  message : message!)
                                                            }
                                                            
        })
    }
    
    /**
     *
     */
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

