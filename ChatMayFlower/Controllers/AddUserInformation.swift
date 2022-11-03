//
//  AddUserInformation.swift
//  ChatMayFlower
//
//  Created by iMac on 03/11/22.
//

import UIKit
import FirebaseStorage

class AddUserInformation: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var phones = ""
    
    @IBOutlet weak var tname: UITextField!
    @IBOutlet weak var tphoneNumber: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tphoneNumber.text = phones
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgProfile.addGestureRecognizer(tapGesture)
        
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
    var imageData = Data()
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
            imageData = selectedImage.jpegData(compressionQuality: 0.8)!
            // Create a storage reference from our storage service
            
            print("Name of Image --->>> ",filename!)
            picker.dismiss(animated: true, completion: nil)
            
        }
        else{
            print("Image not found...!")
        }
        
    }
   
    // Get a reference to the storage service using the default Firebase App
    

    
    
    @IBAction func submit(_ sender: UIButton) {
        
        guard didselectedImage != nil else{
            return
        }
        
        let storageRef = Storage.storage().reference()
        
       
        let image = didselectedImage!.jpegData(compressionQuality: 0.4)
        
        guard image != nil else {
            return
        }
        // imagesRef still points to "images"
        let fileRef = storageRef.child("images/\(UUID().uuidString).jpg")
        print("\(fileRef)")
        
        // Upload data
        let uploaTask = fileRef.putData(image!, metadata: nil) { metadata, error in
            
            // Check error
            if error == nil && metadata != nil {
                
            }
            print("Meta data",metadata)
            print("Error ",error)
        }
        
        if tname.text != "" && tphoneNumber.text != ""{
            
           
            
            DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.phones,name: tname.text!,profileImage : ""))
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsCode") as? UserDetailsCode
            vc?.phones = self.phones
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
}
