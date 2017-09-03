//
//  LoginViewController.swift
//  JiChat
//
//  Created by Ji Hwan Seung on 21/08/2017.
//  Copyright © 2017 Ji Hwan Seung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    var loginChoiceSegmentedControl: UISegmentedControl!
    var textBoxView: UIView!
    var nameTextField: UITextField!
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    let separatorLineOneView = UIView()
    let separatorLineTwoView = UIView()
    let activityIndicator = UIActivityIndicatorView()
    
    var profilePicImageView: UIImageView!
    
    var registerLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutViews()
    }
    
    func layoutViews() {
        view.backgroundColor = .lightGray
        
        let gradient = Gradient()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        
        gradientLayer.colors = gradient.colorSets["green"]
        
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        
        textBoxView = UIView(frame: CGRect(x: 10, y: 170, width: view.frame.width - 20, height: 150))
        textBoxView.backgroundColor = .white
        textBoxView.layer.cornerRadius = 5
        textBoxView.layer.masksToBounds = true
        
        loginChoiceSegmentedControl = UISegmentedControl(items: ["Login", "Register"])
        loginChoiceSegmentedControl.center.x = view.center.x
        loginChoiceSegmentedControl.frame = CGRect(x: 40, y: textBoxView.frame.origin.y - 30, width: view.frame.width - 80, height: 25)
        loginChoiceSegmentedControl.tintColor = .darkGray
        loginChoiceSegmentedControl.selectedSegmentIndex = 1
        loginChoiceSegmentedControl.addTarget(self, action: #selector(loginChoiceChanged), for: .valueChanged)
        
        nameTextField = UITextField(frame: CGRect(x: textBoxView.frame.origin.x, y: textBoxView.frame.origin.y, width: textBoxView.frame.width, height: textBoxView.frame.height/3))
        nameTextField.placeholder = "Name"
        nameTextField.setLeftPaddingPoints(15)
        nameTextField.setRightPaddingPoints(15)
        
        emailTextField = UITextField(frame: CGRect(x: textBoxView.frame.origin.x, y: nameTextField.frame.origin.y + nameTextField.frame.height, width: textBoxView.frame.width, height: textBoxView.frame.height/3))
        emailTextField.placeholder = "Email"
        emailTextField.setLeftPaddingPoints(15)
        emailTextField.setRightPaddingPoints(15)
        
        passwordTextField = UITextField(frame: CGRect(x: textBoxView.frame.origin.x, y: emailTextField.frame.origin.y + emailTextField.frame.height, width: textBoxView.frame.width, height: textBoxView.frame.height/3))
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.setLeftPaddingPoints(15)
        passwordTextField.setRightPaddingPoints(15)
        
        separatorLineOneView.backgroundColor = .lightGray
        separatorLineOneView.frame = CGRect(x: textBoxView.frame.origin.x, y: emailTextField.frame.origin.y, width: textBoxView.frame.width, height: 1)
    
        separatorLineTwoView.backgroundColor = .lightGray
        separatorLineTwoView.frame = CGRect(x: textBoxView.frame.origin.x, y: passwordTextField.frame.origin.y, width: textBoxView.frame.width, height: 1)
        
        registerLoginButton = UIButton(frame: CGRect(x: textBoxView.frame.origin.x, y: textBoxView.frame.origin.y + textBoxView.frame.height + 5, width: textBoxView.frame.width, height: 40))
        registerLoginButton.addTarget(self, action: #selector(registerOrLoginClicked), for: .touchUpInside)
        registerLoginButton.setTitle("Register", for: .normal)
        registerLoginButton.backgroundColor = .darkGray
        registerLoginButton.layer.cornerRadius = 2
        registerLoginButton.layer.masksToBounds = true
        registerLoginButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        
        profilePicImageView = UIImageView(frame: CGRect(x: 0, y: textBoxView.frame.origin.y - 130, width: 80, height: 80))
        profilePicImageView.center.x = view.center.x
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.width/2
        profilePicImageView.clipsToBounds = true
        profilePicImageView.contentMode = .scaleAspectFill
        if loginChoiceSegmentedControl.selectedSegmentIndex == 1 {
            profilePicImageView.image = #imageLiteral(resourceName: "profileicon")
        }
        
        view.layer.addSublayer(gradientLayer)
        view.addSubview(profilePicImageView)
        view.addSubview(loginChoiceSegmentedControl)
        view.addSubview(textBoxView)
        view.addSubview(registerLoginButton)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(separatorLineOneView)
        view.addSubview(separatorLineTwoView)
        view.addSubview(activityIndicator)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self.view) {
            if profilePicImageView.frame.contains(location) {
                openPhotoLibrary()
            }
        }
    }
    
}
