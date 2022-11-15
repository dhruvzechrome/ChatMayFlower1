//
//  AddUserInformation.swift
//  ChatMayFlower
//
//  Created by iMac on 03/11/22.
//

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseCoreInternal

class AddUserInformation: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var backgroundSv: UIScrollView!
    var location = ""
    var urlPath = ""
    var phones = ""
    var databaseRef: DatabaseReference!
    @IBOutlet weak var tname: UITextField!
    @IBOutlet weak var tphoneNumber: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tphoneNumber.text = phones
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgProfile.addGestureRecognizer(tapGesture)
        initializeHideKeyboard()
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
              
        
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationItem.hidesBackButton = true
        getData()
    }
    
    func getData(){
        // Create Firebase Storage Reference
        let storageRef = Storage.storage().reference()
        
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.key
            //            print("Key",key)
            guard let value = snapshot.value as? [String:Any] else {return}
            
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots {
                    //                    let cata = snap.key
                    //                    let ques = snap.value!
                    
                    let gif = snapshot.value! as! [String:String]
                    if gif["Phone number"] ==  self?.phones{
                        //                        print("Ppppphhhhh :",gif["Phone number"]!)
                        
                        self!.tphoneNumber.text = gif["Phone number"]!
                        
                        //                        self!.uphoneno = gif["Phone number"]!
                        
                        
                        if gif["Name"] != nil {
                            if gif["Name"] != ""{
                                self!.tname.text = gif["Name"]!
                            }
                            else {
//                                self!.tname.text = "No name available"
                            }
                            //                            self!.uname = gif["Name"]!
                        }
                        let image = UIImage(named: "placeholder")
                        if gif["photo url"] != nil {
                            if gif["photo url"] != "" {
                                self!.location = gif["location"]!
                                self!.urlPath = gif["photo url"]!
                                print("Photo Url -------- \(self!.urlPath)")
                                print("Photo location -------- \(self!.location)")
                                let url = URL(string: self!.urlPath)
                                self!.imgProfile.kf.setImage(with: url)
                            }
                            else {
                                self!.imgProfile.image = image
                            }
                        } else {
                            self!.imgProfile.image = image
                        }
                    }
                }
            }
        }
    }
    
    @objc
    func imageTapped(tapGestureRecognizer : UITapGestureRecognizer)
    {
        print("Image Tapped...!")
        let ac = UIAlertController(title: "Select Image From", message: "", preferredStyle: .actionSheet)
        let cameraBtn = UIAlertAction(title: "Camera", style: .default){(_) in
            print("Camera Press")
            self.showImagePicker(selectSource: .camera)
        }
        let libraryBtn = UIAlertAction(title: "Library", style: .default){(_) in
            print("Library Press")
            self.showImagePicker(selectSource: .photoLibrary)
        }
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel , handler: nil)
        ac.addAction(cameraBtn)
        ac.addAction(libraryBtn)
        ac.addAction(cancelBtn)
        self.present(ac, animated: true, completion: nil)
    }
    func showImagePicker(selectSource:UIImagePickerController.SourceType)
    {
        guard UIImagePickerController.isSourceTypeAvailable(selectSource) else{
            print("Selected Source not available")
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectSource
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    var filename : String?
    var didselectedImage : UIImage?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage =  info[.originalImage] as? UIImage{
            print("Selected image ",selectedImage)
            imgProfile.image = selectedImage
            didselectedImage = selectedImage
            let localPath = info[.imageURL] as? NSURL
            _ = info[.imageURL] as? URL
            print("Local Path  > ",localPath!)
            filename = localPath?.lastPathComponent
            
            print("Name of Image --->>> ",filename!)
            picker.dismiss(animated: true, completion: nil)
            
        }
        else{
            print("Image not found...!")
        }
        
    }
    
    
    @IBAction func submit(_ sender: UIButton) {
        
        guard didselectedImage != nil else{
            if tname.text != "" && tphoneNumber.text != ""{
                DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.phones,name: tname.text!,profileImage : urlPath, location: location))
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsCode") as? UserDetailsCode
                vc?.phones = self.phones
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            return
        }
        
        // Create Firebase Storage Reference
        let storageRef = Storage.storage().reference()
        
        
        let imageData = didselectedImage!.jpegData(compressionQuality: 0.4)
        
        guard imageData != nil else {
            return
        }
        var path = ""
        // imagesRef still points to "images"
        if urlPath == ""{
            location = "images/\(UUID().uuidString).jpg"
        }else{
            path = urlPath
        }
        let fileRef = storageRef.child(location)
        print("\(fileRef)")
        
        // This is equivalent to creating the full reference
        // Upload data
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { [self] metadata, error in
            
            // Check error
            if error == nil && metadata != nil {
                var urlpth = ""
                fileRef.downloadURL {
                    url, error in
                          if let error = error {
                            // Handle any errors
                            print(error)
                          } else {
                            // Get the download URL for 'Lessons_Lesson1_Class1.mp3'
                              print("Urllll ----->",url!)
                              urlpth = "\(url!)"
                              DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.phones,name: tname.text!,profileImage : "\(urlpth)", location: location))
                          }

                }
                if tname.text != "" && tphoneNumber.text != ""{
                   
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsCode") as? UserDetailsCode
                    vc?.phones = self.phones
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
        }
        
        
        
    }
}

extension AddUserInformation {
    
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }
}
extension AddUserInformation {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        // Get required info out of the notification
        if let scrollView = backgroundSv, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            
            // Find out how much the keyboard overlaps our scroll view
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
            
            // Set the scroll view's content inset & scroll indicator to avoid the keyboard
            scrollView.contentInset.bottom = keyboardOverlap
            scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
            
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

}
