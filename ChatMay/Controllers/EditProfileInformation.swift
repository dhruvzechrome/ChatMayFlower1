//
//  EditProfileInformation.swift
//  ChatMayFlower
//
//  Created by iMac on 05/11/22.
//

import UIKit
import FirebaseStorage
import Kingfisher
import FirebaseDatabase
class EditProfileInformation: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var backgroundSv: UIScrollView!
    var photoUrlPath = ""
    var userImage :UIImage?
    var name = ""
    var number = ""
    @IBOutlet weak var tPhoneNumber: UITextField!
    @IBOutlet weak var tName: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.image = userImage
        tName.text = name
        tPhoneNumber.text = number
        tabBarController?.tabBar.isHidden = true
        print("URL Path ----=====-- \(photoUrlPath)")
        if photoUrlPath != ""{
            let url = URL(string: photoUrlPath)
            profileImage.kf.setImage(with: url)
        }else{
            profileImage.image = UIImage(named: "placeholder")
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImage.addGestureRecognizer(tapGesture)
        
        initializeHideKeyboard()
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
        
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        
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
            profileImage.image = selectedImage
            didselectedImage = selectedImage
//            let localPath = info[.imageURL] as? NSURL
//            _ = info[.imageURL] as? URL
//            print("Local Path  > ",localPath!)
            
//            print("Name of Image --->>> ",filename!)
            picker.dismiss(animated: true, completion: nil)
            
        }
        else{
            print("Image not found...!")
        }
        
    }
    
    @IBAction func submit(_ sender: UIBarButtonItem) {
        
        guard didselectedImage != nil else{
            if tName.text != "" && tPhoneNumber.text != ""{
                
                let ref = Database.database().reference().child("Contact List").child(number)
                ref.updateChildValues(["Phone number": number,"Name":tName.text!,"photo url":"","location" : ""], withCompletionBlock: { error, _ in
                    guard error == nil else {
                        print("Failed to write data")
                        return
                    }
                    print("data written seccess")

                })
                DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.number,name: tName.text!,profileImage : photoUrlPath, location: filename!))
                //                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowProfileDetail") as? ShowProfileDetail
                //                vc?.phones = self.number
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        // Create Firebase Storage Reference
        let storageRef = Storage.storage().reference()
        
        
        let imageData = didselectedImage!.jpegData(compressionQuality: 0.4)
        
        guard imageData != nil else {
            return
        }
        // imagesRef still points to "images"
        if photoUrlPath == "" {
            filename = "images/\(UUID().uuidString).jpg"
        }
        let fileRef = storageRef.child(filename!)
        print("\(fileRef)")
        
        // This is equivalent to creating the full reference
        // Upload data
        let _ = fileRef.putData(imageData!, metadata: nil) { [self] metadata, error in
            var urlpth = ""
            // Check error
            if error == nil && metadata != nil {
                if tName.text != "" && tPhoneNumber.text != ""{
                    
                    
                    fileRef.downloadURL {
                        url, error in
                        if let error = error {
                            // Handle any errors
                            print(error)
                        } else {
                            // Get the download URL for 'Lessons_Lesson1_Class1.mp3'
                            urlpth = "\(url!)"
                            let ref = Database.database().reference().child("Contact List").child(number)
                            ref.updateChildValues(["Phone number": number,"Name":tName.text!,"photo url":"\(urlpth)","location" : filename!], withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    print("Failed to write data")
                                    return
                                }
                                print("data written seccess")

                            })
                            
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                    //                    print("Urllll ---sdsdfsdf-->",urlpth)
                    
                    //                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowProfileDetail") as? ShowProfileDetail
                    //                    vc?.phones = self.number
                    
                }
            }
            print("Error ====== \(String(describing: error))")
        }
        
        
        
    }
}


extension EditProfileInformation {
    
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
extension EditProfileInformation {
    
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
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardOverlap
            
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
}
