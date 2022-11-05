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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                    let cata = snap.key
                    let ques = snap.value!
                    
                    let gif = snapshot.value! as! [String:String]
                    if gif["Phone number"] ==  self?.phones{
//                        print("Ppppphhhhh :",gif["Phone number"]!)
                        
                        self!.tphoneNumber.text = gif["Phone number"]!
                        
//                        self!.uphoneno = gif["Phone number"]!
                        
                        
                        if gif["Name"] != nil{
                            self!.tname.text = gif["Name"]!
//                            self!.uname = gif["Name"]!
                        }
                        
                        if gif["photo bytes"] != nil {
                            self!.urlPath = gif["photo bytes"]!
                        //Get File reference path
                        let fileRef = storageRef.child(self!.urlPath)
                        
                        // Retrive data
                        fileRef.getData(maxSize: 5 * 1024 * 1024 ) {data, error in
                            
                            // Check For error
                            if error == nil && data != nil{
                                let image = UIImage(data: data!)
                                
                                self!.imgProfile.image = image
                                
                            }
                        }
                        
                        }else{
                            self!.imgProfile.image = UIImage(named: "placeholder")
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
         path = "images/\(UUID().uuidString).jpg"
        }else{
            path = urlPath
        }
        let fileRef = storageRef.child(path)
        print("\(fileRef)")
        
        // This is equivalent to creating the full reference
        // Upload data
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            
            // Check error
            if error == nil && metadata != nil {
                
            }
        }
        
        if tname.text != "" && tphoneNumber.text != ""{
            
           
            
            DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.phones,name: tname.text!,profileImage : path))
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsCode") as? UserDetailsCode
            vc?.phones = self.phones
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
}
