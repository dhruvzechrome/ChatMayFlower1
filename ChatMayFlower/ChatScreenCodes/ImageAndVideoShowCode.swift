//
//  ImageAndVideoShowCode.swift
//  ChatMayFlower
//
//  Created by iMac on 14/11/22.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import MBProgressHUD

class ImageAndVideoShowCode: UIViewController {
    
    @IBOutlet weak var backgroundSV: UIScrollView!
    @IBOutlet weak var myVIew: UIView!
    @IBOutlet var stackComet: UIStackView!
    var keyBoardStatus = false
    var navselectedImage : UIImage?
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    private let database = Database.database().reference()
    var mesId = ""
    var uid :Int?
    var num = ""
    var videoUrl : String?
    var keyboardheight = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        if navselectedImage != nil {
            selectedImage.image = navselectedImage
        }
        else {
        }
        
        commentField.delegate = self
        commentField.tag = 1
        initializeHideKeyboard()
        num = FirebaseAuth.Auth.auth().currentUser!.phoneNumber!
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    @IBAction func sent(_ sender: UIButton) {
        guard selectedImage != nil else{
            self.navigationController?.popViewController(animated: true)
            return
        }
        mbProgressHUD(text: "Loading..")
        let storageRef = Storage.storage().reference()
        let imageData = navselectedImage?.jpegData(compressionQuality: 0.4)
        guard imageData != nil else {
            return
        }
        //        var path = ""
        let filename = "chatImages/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(filename)
        print("\(fileRef)")
        let _ = fileRef.putData(imageData!, metadata: nil) { [self] metadata, error in
            var urlpth = ""
            // Check error
            if error == nil && metadata != nil {
                fileRef.downloadURL {
                    url, error in
                    if let error = error {
                        // Handle any errors
                        print(error)
                    } else {
                        // Get the download URL for 'Lessons_Lesson1_Class1.mp3'
                        urlpth = "\(url!)"
                        uid = uid! + 1
                        database.child("Uid").setValue(uid)
                        //                        database.child("Chats").child(mesId).child("status").setValue(["\(num)":true,"\(num)":false])
                        if commentField.text == "" {
                            database.child("Chats").child(mesId).child("chatting").child("\(uid!)").setValue(["\(num)chatPhoto": urlpth], withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    print("Failed to write data")
                                    return
                                }
                                print("data written seccess")
                                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                                    navigationController?.popViewController(animated: true)
                                    hideProgress()
                                }
                            })
                        }else{
                            database.child("Chats").child(mesId).child("chatting").child("\(uid!)").setValue(["\(num)text":commentField.text!,"\(num)chatPhoto": urlpth], withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    print("Failed to write data")
                                    return
                                }
                                print("data written seccess")
                                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                                    navigationController?.popViewController(animated: true)
                                    hideProgress()
                                }
                            })
                        }
                        //                                  DataBaseManager.shared.mychatting(with: Message(messagid: mesId, chats: commentField.text!, sender: "ul", uii: uid, chatPhotos: urlpth))
                    }
                }
                //                    print("Urllll ---sdsdfsdf-->",urlpth)
                //                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowProfileDetail") as? ShowProfileDetail
                //                    vc?.phones = self.number
            }
            print("Error ====== \(String(describing: error))")
        }
    }
    
}
extension ImageAndVideoShowCode {
    func mbProgressHUD(text: String){
        DispatchQueue.main.async {
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHUD.label.text = text
            progressHUD.contentColor = .systemBlue
        }
    }
    func hideProgress(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: false)
        }
    }
}
extension ImageAndVideoShowCode : UITextFieldDelegate {
    
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        if keyBoardStatus == true {
            print("YESSTR")
            view.endEditing(true)
        }
    }
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        // Get required info out of the notification
        if keyBoardStatus == false {
            keyBoardStatus = true
            if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                //let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                view.frame.size = CGSize(width: view.bounds.width, height: view.frame.height - keyboardSize.height+60)
                myVIew.frame.size = CGSize(width: myVIew.bounds.width, height: myVIew.frame.height - keyboardSize.height)
                keyboardheight = Int(keyboardSize.height-60)
                
                backgroundSV.frame.size = CGSize(width: backgroundSV.bounds.width, height: backgroundSV.frame.height - keyboardSize.height)
                //               print("asdasd" , keyboardheight)
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Text hide called")
        if keyBoardStatus == true {
            self.keyBoardStatus = false
            view.frame.size = CGSize(width: view.bounds.width, height: view.bounds.height + CGFloat(self.keyboardheight))
            self.myVIew.frame.size = CGSize(width: myVIew.bounds.width, height: myVIew.frame.height + CGFloat(self.keyboardheight))
            backgroundSV.frame.size = CGSize(width: backgroundSV.bounds.width, height: backgroundSV.frame.height + CGFloat(keyboardheight))
            self.view.endEditing(true)
            return false
        } else {
            return true
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        //        stackComet.frame.origin.y = 0
        if keyBoardStatus == true {
            self.keyBoardStatus = false
            view.frame.size = CGSize(width: view.bounds.width, height: view.bounds.height + CGFloat(self.keyboardheight))
            self.myVIew.frame.size = CGSize(width: myVIew.bounds.width, height: myVIew.frame.height + CGFloat(self.keyboardheight))
            self.view.endEditing(true)
        }
    }
}
