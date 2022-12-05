//
//  VideoSentCode.swift
//  ChatMayFlower
//
//  Created by iMac on 18/11/22.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import MBProgressHUD
class VideoSentCode: UIViewController {
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var videoImage: UIImageView!
    var navselectedImage : UIImage?
    private let database = Database.database().reference()
    var mesId = ""
    var uid :Int?
    var num = ""
    var videoUrl : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if navselectedImage != nil {
            videoImage.image = navselectedImage
        }
        else {
        }
        num = FirebaseAuth.Auth.auth().currentUser!.phoneNumber!
    }
    
    @IBAction func sent(_ sender: UIButton) {
        guard videoImage != nil else{
            self.navigationController?.popViewController(animated: true)
            return
        }
        mbProgressHUD(text: "Loading..")
        let storageRef = Storage.storage().reference()
        let imageData = navselectedImage?.jpegData(compressionQuality: 0.4)
        guard imageData != nil else {
            return
        }
        let filename = "chatVideos/\(UUID().uuidString).mov"
        
        let fileRef = storageRef.child(filename)
        print("\(fileRef)")
        // This is equivalent to creating the full reference
        // Upload data
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
                        // DataBaseManager.shared.mychatting(with: Message(messagid: mesId, chats: commentField.text!, sender: "ul", uii: uid, chatPhotos: urlpth))
                    }
                    
                }
                //  print("Urllll ----->",urlpth)
                //  let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowProfileDetail") as? ShowProfileDetail
                //  vc?.phones = self.number
            }
            print("Error ====== \(String(describing: error))")
        }
    }
}
extension VideoSentCode {
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
