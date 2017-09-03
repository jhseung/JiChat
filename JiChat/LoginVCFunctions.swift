//
//  LoginViewControllerFunctions.swift
//  JiChat
//
//  Created by Ji Hwan Seung on 22/08/2017.
//  Copyright © 2017 Ji Hwan Seung. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    func openPhotoLibrary() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let picker = UIImagePickerController()
            
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.allowsEditing = true
            
            present(picker, animated: true, completion: nil)
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePicImageView.image = pickedImage
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func registerOrLoginClicked() {
        
        if loginChoiceSegmentedControl.selectedSegmentIndex == 0 {
            loginButtonClicked()
        } else {
            registerButtonClicked()
        }
    }
    
    func loginChoiceChanged() {
        
        let choice = loginChoiceSegmentedControl.titleForSegment(at: loginChoiceSegmentedControl.selectedSegmentIndex)
        registerLoginButton.setTitle(choice, for: .normal)
        
        let textBoxViewSizeHeight: [CGFloat] = [100.0, 150.0]
        textBoxView.frame.size.height = textBoxViewSizeHeight[loginChoiceSegmentedControl.selectedSegmentIndex]
        
        if loginChoiceSegmentedControl.selectedSegmentIndex == 0 {
            nameTextField.removeFromSuperview()
            separatorLineTwoView.removeFromSuperview()
            profilePicImageView.image = nil
            emailTextField.frame.origin.y = textBoxView.frame.origin.y
            passwordTextField.frame.origin.y = emailTextField.frame.origin.y + emailTextField.frame.height
            registerLoginButton.frame.origin.y = textBoxView.frame.origin.y + textBoxView.frame.height + 5
            view.layoutIfNeeded()
        } else {
            nameTextField = UITextField(frame: CGRect(x: textBoxView.frame.origin.x, y: textBoxView.frame.origin.y, width: textBoxView.frame.width, height: textBoxView.frame.height/3))
            nameTextField.placeholder = "Name"
            nameTextField.setLeftPaddingPoints(15)
            nameTextField.setRightPaddingPoints(15)
            
            profilePicImageView.image = #imageLiteral(resourceName: "profileicon")
            emailTextField.frame.origin.y = nameTextField.frame.origin.y + nameTextField.frame.height
            passwordTextField.frame.origin.y = emailTextField.frame.origin.y + emailTextField.frame.height
            registerLoginButton.frame.origin.y = textBoxView.frame.origin.y + textBoxView.frame.height + 5
            
            view.addSubview(nameTextField)
            view.addSubview(separatorLineTwoView)
            view.layoutIfNeeded()
        }
        
    }
    
    func loginButtonClicked() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text
            else {
                let userAlert = UIAlertController(title: nil, message: "Invalid form. Please try again.", preferredStyle: .alert)
                userAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    userAlert.dismiss(animated: false, completion: nil)
                }))
                self.present(userAlert, animated: false, completion: nil)
                return
        }
        
        self.activityIndicator.startAnimating()
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                self.displayError(error: error!)
                self.activityIndicator.stopAnimating()
            } else {
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: true, completion: nil)
            }
        })
        
    }
    
    func registerButtonClicked() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else {
                return
        }

        self.activityIndicator.startAnimating()
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {(user: FIRUser?, error) in
            if error != nil {
                self.activityIndicator.stopAnimating()
                self.displayError(error: error!)
            }
            
            guard let uid = user?.uid else {
                self.activityIndicator.stopAnimating()
                return
            }
            
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_pictures").child(imageName)
            
            if let picture = self.profilePicImageView.image {
                if let pictureData = UIImageJPEGRepresentation(picture, 0.5) {
                    storageRef.put(pictureData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            self.displayError(error: error!)
                        }
                        if let url = metadata?.downloadURL() {
                            self.handleUserAuthentication(uid: uid, name: name, email: email, imageURL: url.absoluteString)
                        }
                    })
                }
            }
        })
        
    }
    
    private func handleUserAuthentication(uid: String, name: String, email: String, imageURL: String) {
        let ref = FIRDatabase.database().reference(fromURL: "https://jichat-2d973.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        let values = ["name": name, "email": email, "imageURL": imageURL]
        usersReference.updateChildValues(values) { (err, ref) in
            if err != nil {
                let printError = err as! NSError
                let userAlert = UIAlertController(title: nil, message: printError.localizedDescription, preferredStyle: .alert)
                userAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    userAlert.dismiss(animated: false, completion: nil)
                }))
                self.present(userAlert, animated: false, completion: nil)
                return
            }
            let userAlert = UIAlertController(title: nil, message: "Registration complete", preferredStyle: .alert)
            _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
                userAlert.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            })
            self.activityIndicator.stopAnimating()
            self.present(userAlert, animated: false, completion: nil)
            return
        }

    }
    
    private func displayError(error: Error) {
        let printError = error as NSError
        let userAlert = UIAlertController(title: nil, message: printError.localizedDescription, preferredStyle: .alert)
        userAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            userAlert.dismiss(animated: false, completion: nil)
        }))
        self.present(userAlert, animated: false, completion: nil)
        return
    }
    
}
