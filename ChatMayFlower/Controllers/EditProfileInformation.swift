//
//  EditProfileInformation.swift
//  ChatMayFlower
//
//  Created by iMac on 05/11/22.
//

import UIKit
import FirebaseStorage

class EditProfileInformation: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var photoUrlPath = ""
    var iiimg :UIImage?
    var name = ""
    var number = ""
    @IBOutlet weak var tPhoneNumber: UITextField!
    @IBOutlet weak var tName: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.image = iiimg
        tName.text = name
        tPhoneNumber.text = number
        tabBarController?.tabBar.isHidden = true
        print("URL Path ----=====-- \(photoUrlPath)")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImage.addGestureRecognizer(tapGesture)
      
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
            if tName.text != "" && tPhoneNumber.text != ""{
                
               
                
                DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.number,name: tName.text!,profileImage : photoUrlPath))
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowProfileDetail") as? ShowProfileDetail
                vc?.phones = self.number
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
        if photoUrlPath == "" {
            path = "images/\(UUID().uuidString).jpg"
        }else{
            path = photoUrlPath
        }
        let fileRef = storageRef.child(path)
        print("\(fileRef)")
        
        // This is equivalent to creating the full reference
        // Upload data
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { [self] metadata, error in
            
            // Check error
            if error == nil && metadata != nil {
                if tName.text != "" && tPhoneNumber.text != ""{
                    
                   
                    
                    DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.number,name: tName.text!,profileImage : path))
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowProfileDetail") as? ShowProfileDetail
                    vc?.phones = self.number
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
            print("Error ====== \(error)")
        }
        
        
        
    }
}
