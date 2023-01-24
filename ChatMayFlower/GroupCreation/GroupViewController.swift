//
//  GroupViewController.swift
//  ChatMayFlower
//
//  Created by iMac on 21/12/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher
import FirebaseStorage
class GroupViewController: UIViewController,UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    var name = ""
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var GroupImage: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var groupTableView: UITableView!
    var fileName = ""
    var photoUrlPath = ""
    var selecetdUser = [[String:String]]()
    var groupUser = [String]()
    var databaseRef = Database.database().reference()
    var groupName = ""
    var groupMsgId = ""
    var phones = ""
    override func viewDidAppear(_ animated: Bool) {
        if photoUrlPath != "" {
            filename = fileName
            print("group image \(photoUrlPath)-------- file name \(fileName)")
            let url = URL(string: photoUrlPath)
            GroupImage.kf.setImage(with: url)
            didselectedImage = GroupImage.image
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        groupTableView.delegate = self
        groupTableView.dataSource = self
        self.groupTableView.isEditing = true
        if name != "" {
            createButton.title = "Done"
            textField.text = name
            title = "Add User"
        }
        self.groupTableView.allowsMultipleSelectionDuringEditing = true
        // Do any additional setup after loading the view.
        if selecetdUser.count > 0 {
            groupTableView.reloadData()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        GroupImage.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selecetdUser.removeAll()
        groupUser.removeAll()
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
            GroupImage.image = selectedImage
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
    
    @IBAction func createButton(_ sender: UIBarButtonItem) {
        guard GroupImage.image != nil else{
            if name == "" {
                let name = textField.text
                if textField.text  != "" && groupName != "" && groupUser.count > 0 {
                    let str = "group\(UUID().uuidString)"
                    databaseRef.child("Contact List").child("\(name!)").setValue(["uniqueid": "\(str)","admin":"\(phones)" , "group name": "\(name!)" , "group user":"\(phones)\(groupName)" , "photo url":"","location" : ""] , withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("Failed to write data")
                            return
                        }
                        print("data written seccess")
                    })
                    databaseRef.child("Chats").child("\(str)").setValue(["groupMesId":"\(phones)\(groupName)"])
                    databaseRef.child("Chats").child("\(str)").child("chatting").child("0").setValue(["\(phones)": "New Group Ceated by \(phones)"], withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("Failed to write data")
                            
                            return
                        }
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                        print("data written seccess")
                    })
                } else {
                    let alert = UIAlertController(title: "Alert", message: "Enter Group Name", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                print("No")
                let name = textField.text
                if textField.text  != "" && groupName != "" && groupUser.count > 1 {
                    databaseRef.child("Contact List").child("\(name!)").setValue(["uniqueid": "\(groupMsgId)","admin":"\(phones)" , "group name": "\(name!)" , "group user":"\(groupName)" , "photo url":"","location" : ""] , withCompletionBlock: { error, _ in
                        guard error == nil else {
                            print("Failed to write data")
                            return
                        }
                        print("data written seccess")
                    })
                    let ref = databaseRef.child("Chats").child("\(groupMsgId)")
                    ref.updateChildValues(["groupMesId":"\(groupName)"]) { error, _ in
                        guard error == nil else {
                            print("Failedt Update")
                            return
                        }
                        print("Update Successfully")
                        self.dismiss(animated: true)
                    }
                } else {
                    let alert = UIAlertController(title: "Alert", message: "Enter Group Name", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
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
            filename = "groupImages/\(UUID().uuidString).jpg"
        }
        let fileRef = storageRef.child(filename!)
        print("\(fileRef)")
        // This is equivalent to creating the full reference
        // Upload data
        let _ = fileRef.putData(imageData!, metadata: nil) { [self] metadata, error in
            var urlpth = ""
            // Check error
            if error == nil && metadata != nil {
                if name == "" {
                    let name = textField.text
                    print("my group name  \(groupName)")
                    if textField.text  != "" && groupName != "" && groupUser.count > 0 {
                        fileRef.downloadURL {
                            url, error in
                            if let error = error {
                                // Handle any errors
                                print(error)
                            } else {
                                // Get the download URL for 'Lessons_Lesson1_Class1.mp3'
                                urlpth = "\(url!)"
                                let str = "group\(UUID().uuidString)"
                                databaseRef.child("Contact List").child("\(name!)").setValue(["uniqueid": "\(str)","admin":"\(phones)" , "group name": "\(name!)" , "group user":"\(phones)\(groupName)" , "photo url":"\(url!)","location" : "\(filename!)"] , withCompletionBlock: { error, _ in
                                    guard error == nil else {
                                        print("Failed to write data")
                                        return
                                    }
                                    print("data written seccess")
                                })
                                databaseRef.child("Chats").child("\(str)").setValue(["groupMesId":"\(phones)\(groupName)"])
                                databaseRef.child("Chats").child("\(str)").child("chatting").child("0").setValue(["\(phones)": "New Group Ceated by \(phones)"], withCompletionBlock: { error, _ in
                                    guard error == nil else {
                                        print("Failed to write data")
                                        
                                        return
                                    }
                                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                    print("data written seccess")
                                })
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    } else {
                        let alert = UIAlertController(title: "Alert", message: "Enter Group Name", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    print("No")
                    fileRef.downloadURL {
                        url, error in
                        if let error = error {
                            // Handle any errors
                            print(error)
                        } else {
                            // Get the download URL for 'Lessons_Lesson1_Class1.mp3'
                            urlpth = "\(url!)"
                            let name = textField.text
                            if textField.text  != "" && groupName != "" && groupUser.count > 1 {
                                databaseRef.child("Contact List").child("\(name!)").setValue(["uniqueid": "\(groupMsgId)","admin":"\(phones)" , "group name": "\(name!)" , "group user":"\(groupName)" , "photo url":"\(url!)","location" : "\(filename!)"] , withCompletionBlock: { error, _ in
                                    guard error == nil else {
                                        print("Failed to write data")
                                        return
                                    }
                                    print("data written seccess")
                                })
                                let ref = databaseRef.child("Chats").child("\(groupMsgId)")
                                ref.updateChildValues(["groupMesId":"\(groupName)"]) { error, _ in
                                    guard error == nil else {
                                        print("Failedt Update")
                                        return
                                    }
                                    print("Update Successfully")
                                    self.dismiss(animated: true)
                                }
                            } else {
                                let alert = UIAlertController(title: "Alert", message: "Enter Group Name", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            self.navigationController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            print("Error ====== \(String(describing: error))")
        }
    }
}

extension GroupViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selecetdUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = selecetdUser[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupViewCell", for: indexPath) as? GroupViewCell
        //        print("my image is \(frd["profilepic"]!)")
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        if frd["Name"] == nil {
            cell?.name.text = frd["Phone number"]
        } else {
            cell?.name.text = frd["Name"]
            if frd["Name"] == "" {
                cell?.name.text = frd["Phone number"]
            }
        }
        if frd["profilepic"] == nil {
            cell?.profileImage.image = UIImage(systemName:  "person.circle.fill")
        } else {
            let url = URL(string: frd["profilepic"]! )
            cell?.profileImage.kf.setImage(with: url)
            if frd["profilepic"] == "" {
                cell?.profileImage.image = UIImage(systemName: "person.circle.fill")
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let frd = selecetdUser[indexPath.row]
        let num = (frd["Phone number"])!
        if !groupUser.contains(num) {
            groupUser.append(num)
            selecetdUser.append(frd)
            mychat()
        }
        print("\(groupUser)")
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let frd = selecetdUser[indexPath.row]
        let num = (frd["Phone number"])!
        for i in 0...groupUser.count-1 {
            if num == groupUser[i] {
                groupUser.remove(at: i)
                mychat()
                break
            }
        }
        for i in 0...selecetdUser.count-1 {
            let fsd = selecetdUser[i]
            if num == fsd["Phone number"] {
                selecetdUser.remove(at: i)
                mychat()
                groupTableView.reloadData()
                break
            }
        }
        print("\(groupUser) -- selected useer \(selecetdUser)")
    }
    
    func mychat() {
        groupName = ""
        if groupUser.count > 0 {
            for i in 0...groupUser.count-1 {
                groupName = "\(groupName)\(groupUser[i])"
                print(groupName)
            }
        }
        print("\(groupName)")
    }
}
