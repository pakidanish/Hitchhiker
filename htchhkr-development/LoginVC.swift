//
//  LoginVC.swift
//  htchhkr-development
//
//  Created by Mustafa GUNES on 27.02.2018.
//  Copyright © 2018 Mustafa GUNES. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UITextFieldDelegate, Alertable {
    

    @IBOutlet weak var emailField: RoundedCornerTextField!
    @IBOutlet weak var passwordField: RoundedCornerTextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var authBtn: RoundedShadowButton!
    
    
    private var hideStatusBar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.bindtoKeyboard()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
        self.view.addGestureRecognizer(tap)
        
        hideStatusBar = true
        
        UIView.animate(withDuration: 0.3) {
            
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func handleScreenTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func authBtnClicked(_ sender: Any) {
        
        if emailField.text != nil && passwordField.text != nil
        {
            authBtn.animateButton(shouldLoad: true, withMessage: nil)
            self.view.endEditing(true)
            
            if let email = emailField.text, let password = passwordField.text
            {
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    
                    if error == nil
                    {
                        if let user = user
                        {
                            if self.segmentedControl.selectedSegmentIndex == 0
                            {
                                let userData = ["provider": user.providerID] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: false)
                            }
                            else
                            {
                                let userData = ["provider": user.providerID, USER_IS_DRIVER : true, ACCOUNT_PICKUP_MODE_ENABLED : false, DRIVER_IS_ON_TRIP : false] as [String: Any]
                                DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: true)
                            }
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                    else
                    {
                        if let errorCode = AuthErrorCode(rawValue: error!._code)
                        {
                            switch errorCode
                            {
                                case .wrongPassword:
                                    self.showAlert(ERROR_MSG_WRONG_PASSWORD)
                                
                                default:
                                    self.showAlert(ERROR_MSG_UNEXPECTED_ERROR)
                            }
                        }
                        
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            
                            if error != nil
                            {
                                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                                    
                                    switch errorCode
                                    {
                                        case .invalidEmail:
                                            self.showAlert(ERROR_MSG_INVALID_EMAIL)
                                        
                                        default:
                                            self.showAlert(ERROR_MSG_UNEXPECTED_ERROR)
                                    }
                                }
                            }
                            else
                            {
                                if let user = user
                                {
                                    //KOD ONCEDEN ASAGIDAKİ GİBİYDİ. DENEME KODUDUR.
                                    //if self.segmentedControl.selectedSegmentIndex == 0
                                    if self.segmentedControl.selectedSegmentIndex == 0
                                    {
                                        let userData = ["provider": user.providerID] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: false)
                                    }
                                    else
                                    {
                                        let userData = ["provider": user.providerID, USER_IS_DRIVER : true, ACCOUNT_PICKUP_MODE_ENABLED : false, DRIVER_IS_ON_TRIP : false] as [String: Any]
                                        DataService.instance.createFirebaseDBUser(uid: user.uid, userData: userData, isDriver: true)
                                    }
                                }
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                    }
                })
            }
        }
    }
}
