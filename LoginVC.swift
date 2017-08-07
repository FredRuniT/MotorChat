//
//  LoginVC.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/15/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var signInBtn: CustomButton!
    @IBOutlet weak var loginDisplayView: CustomView!
    @IBOutlet weak var imageView: UIImageView!
    
    var inputViewHeightAnchor: NSLayoutConstraint?
    var nameHeightAnchor: NSLayoutConstraint?
    var emailHeightAnchor: NSLayoutConstraint?
    var passwordHeightAnchor: NSLayoutConstraint?
    var picker = UIImagePickerController()
    
    var messageFeedVC: MessageFeedVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputViewHeightAnchor = loginDisplayView.heightAnchor.constraint(equalToConstant: 100)
        inputViewHeightAnchor?.isActive = true
        
        emailHeightAnchor = email.heightAnchor.constraint(equalTo: loginDisplayView.heightAnchor, multiplier: 1/2)
        emailHeightAnchor?.isActive = true
        
        passwordHeightAnchor =  password.heightAnchor.constraint(equalTo: loginDisplayView.heightAnchor, multiplier: 1/2)
        passwordHeightAnchor?.isActive = true
        
        picker.delegate = self
        picker.allowsEditing = true
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func buttonDisplay() {
        if segmentedControl.selectedSegmentIndex == 0 {
            signInBtn.setTitle("Login", for: .normal)
        } else {
            signInBtn.setTitle("Register", for: .normal)
            
        }
        
        inputViewHeightAnchor?.constant = segmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        //change height of email text field
        nameHeightAnchor?.isActive = false
        nameHeightAnchor = name.heightAnchor.constraint(equalTo: loginDisplayView.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 0 ? 0.0 : 1/3)
        nameHeightAnchor?.isActive = true
        
        emailHeightAnchor?.isActive = false
        emailHeightAnchor = email.heightAnchor.constraint(equalTo: loginDisplayView.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailHeightAnchor?.isActive = true
        
        passwordHeightAnchor?.isActive = false
        passwordHeightAnchor = password.heightAnchor.constraint(equalTo: loginDisplayView.heightAnchor, multiplier: segmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordHeightAnchor?.isActive = true
    }
    
    func createUser() {
        if let email = email.text, let password = password.text, let name = name.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print("STEPHAN: Unable to authenticate user")
                    print(error!)
                } else {
                    
                    self.performSegue(withIdentifier: "toMessageFeedVC", sender: nil)
                    
                    //Create constant for user ID
                    guard let uid = user?.uid else {
                        return
                    }
                    
                    //Create unique ID for image
                    let imageName = NSUUID().uuidString
                    
                    //Storage reference to image folder using unique image ID
                    let storageRef = FIRStorage.storage().reference().child("profile_image").child("\(imageName).png")
                    
                    //Represent selected image as PNG and put that data into storage
                    if let uploadData = UIImagePNGRepresentation(self.imageView.image!) {
                        
                        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error!)
                                return
                            }

                            //Get image metadata download URL and set values dictionary for user
                            if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                                let values = ["name": name, "email": email, "profileImageURL": profileImageUrl]
                                self.imageView.loadImagesUsingCacheWith(urlString: profileImageUrl)
                                self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                            }
                        })
                    }
                }
            })
        }
    }
    
    //Register user into Firebase with uid and values dictionary containing user characteristics
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        
        let ref = FIRDatabase.database().reference()
        let userRef = ref.child("users")
        let userID = userRef.child(uid)
        
        userID.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print("STEPHAN: Unable to create user data")
            } else {
                print("STEPHAN: User data sucessfully saved to database!")
            }
        })
    }
    
    func login() {
        if let email = email.text, let password = password.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print("STEPHAN: Unable to sign in")
                } else {
                    self.performSegue(withIdentifier: "toMessageFeedVC", sender: nil)
                }
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.image = image
        } else {
            print("STEPHAN: select valid image")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        
        if signInBtn.currentTitle == "Register" {
            createUser()
        }
        
        if signInBtn.currentTitle == "Login" {
            login()
        }
    }
    
    @IBAction func selectProfileImage(_ sender: Any) {
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        buttonDisplay()
    }
}


