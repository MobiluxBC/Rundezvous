//
//  AuthProvider.swift
//  Rundezvous
//
//  Created by Niko Arellano on 2017-09-21.
//  Copyright © 2017 MobiluxBC. All rights reserved.
//
import Foundation
import FirebaseAuth
import GoogleSignIn

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid Email Address, Please Provide a Real Email Address"
    
    static let WRONG_PASSWORD = "Wrong Password, Please Enter The Correct Password"
    
    static let PROBLEM_CONNECTING = "Problem Connecting To Database"
    
    static let USER_NOT_FOUND = "User Not Found, Please Register"
    
    static let EMAIL_ALREADY_IN_USE = "Email Already In Use, Please Use Another Email"
    
    static let WEAK_PASSWORD = "Password Should Be At Least 6 Characters Long"
}

class AuthProvider {
    
    static let _instance = AuthProvider()
    
    static var Instance : AuthProvider {
        return _instance;
    }
    
    func login(withEmail email : String, withPassword password : String,
               loginHandler : @escaping (_ success : Bool, _ msg : String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password,
                           completion: {
                            (user, error) in
                            
                            var errorMsg : String
                            
                            if error != nil {
                                errorMsg = self.getErrorMessage(err : error! as NSError)
                                
                                loginHandler(false, errorMsg)
                                
                            } else {
                                
                                if user?.uid != nil {
                                    loginHandler(true, nil)
                                }
                                
                            }
        })
    }
    
    func loginWithGoogleCredential(with credential: AuthCredential,
                                   loginHandler : @escaping (_ success : Bool, _ msg : String?) -> Void) {
        
        Auth.auth().signIn(with: credential, completion: {
            (user, error) in
            
            var errorMsg : String
            
            if error != nil {
                errorMsg = self.getErrorMessage(err : error! as NSError)
                
                loginHandler(false, errorMsg)
                
            } else {
                
                if user?.uid != nil {
                    loginHandler(true, nil)
                }
                
            }
        })
        
    }
    
    func signUp(withEmail email : String, withPassword password : String,
                signUpHandler : @escaping (_ success : Bool, _ msg : String?) -> Void) {
        
        Auth.auth().createUser(withEmail : email, password : password,
                               completion : {
                                
                                (user, error) in
                                
                                var errorMsg : String
                                
                                if error != nil {
                                    errorMsg = self.getErrorMessage(err : error! as NSError)
                                    
                                    signUpHandler(false, errorMsg)
                                } else {
                                    
                                    if user?.uid != nil {
                                        signUpHandler(true, nil)
                                    }
                                    
                                }
                                
        })
    }
    
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                return true
            } catch {
                return false
            }
        }
        
        return true
    }
    
    func loginWithGoogle() {
    }
    
    private func getErrorMessage(err: NSError) -> String {
        
        if let errCode = AuthErrorCode(rawValue: err.code) {
            
            switch errCode {
            case .wrongPassword :
                return LoginErrorCode.WRONG_PASSWORD
            case .invalidEmail:
                return LoginErrorCode.INVALID_EMAIL
            case .userNotFound:
                return LoginErrorCode.USER_NOT_FOUND
            case .emailAlreadyInUse:
                return LoginErrorCode.EMAIL_ALREADY_IN_USE
            case .weakPassword:
                return LoginErrorCode.WEAK_PASSWORD
            default:
                return "Unexpected Error. Please Try Again"
            }
            
        }
        
        return "Unexpected Error. Please Try Again"
    }
    
    
}
