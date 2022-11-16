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

class ImageAndVideoShowCode: UIViewController {
    var navselectedImage : UIImage?
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    private let database = Database.database().reference()
    var mesId = ""
    var uid :Int?
    var num = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        if navselectedImage != nil {
            selectedImage.image = navselectedImage
        }
        num = FirebaseAuth.Auth.auth().currentUser!.phoneNumber!
    }
    
    @IBAction func sent(_ sender: UIButton) {
        
        guard selectedImage != nil else{
                self.navigationController?.popViewController(animated: true)
            
            return
        }
        
        let storageRef = Storage.storage().reference()
        
        let imageData = navselectedImage?.jpegData(compressionQuality: 0.4)
        
        guard imageData != nil else {
            return
        }
//        var path = ""
        let filename = "chatImages/\(UUID().uuidString).jpg"
     
        let fileRef = storageRef.child(filename)
        print("\(fileRef)")
        
        // This is equivalent to creating the full reference
        // Upload data
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { [self] metadata, error in
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
                                          }
                                      })
                                  }else{
                                      database.child("Chats").child(mesId).child("chatting").child("\(uid!)").setValue(["\(num)chatPhoto": urlpth,"\(num)":commentField.text!], withCompletionBlock: { error, _ in
                                          guard error == nil else {
                                              print("Failed to write data")
                                             
                                              return
                                          }
                                          print("data written seccess")
                                          DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                                              navigationController?.popViewController(animated: true)
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
            print("Error ====== \(error)")
        }
        
        
        
    }
    
}
