
//
//  ChatConversionCode.swift
//  ChatMayFlower
//
//  Created by iMac on 17/10/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher
import MBProgressHUD
import AVFoundation
import AVKit
import MobileCoreServices
import YPImagePicker
import FirebaseStorage
import SwiftUI
import Photos

class ChatConversionCode: UIViewController ,UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var valueString = ""
    var uiimage = UIImageView()
    var usersDetails = [[String:String]]()
    var usersLists = [[String:String]]()   ////  Main list of all contact list
    var allUser = [[String:String]]()
    var allUserOfFirebase = [[String:String]]()
    var phones = ""
    var groupMsgId = ""
    
    var urlPath = ""
    var fileName = ""
    
    var databaseRef: DatabaseReference!
    var usersNumber = ""
    var msgIdList = [String]()
    var msgstatus = false
    var messageId:String?
    var groupK = "no"
    var replyImageView:UIImageView = UIImageView()
    @IBOutlet weak var bkview: UIView!
    var keyboardheight : Int = 0
    @IBOutlet weak var backgroundSV: UIScrollView!
    private let database = Database.database().reference()
    var phoneid = ""                            // current user
    var receiverid = ""                         // receiver user
    @IBOutlet weak var chatTable: UITableView!  // tableview for showing chats
    @IBOutlet weak var chatField: UITextField!  // textfield for chatting
    var ui = 0                                  // uid  for chatting
    var mid = ""                                // message id of sender and receiver
    var didselectedImage : UIImage?
    @IBOutlet weak var titl: UINavigationItem!  // title  of  navigation item
    var textFieldBtnStatus = false              // textFieldBtnStatus for get repeating of call uid
    var timer = Timer()                         // for repeatative
    var chatMapKey = [String]()                 // for store key of data
    var chatMap = [[String:[String:Any]]]()     // map of chatting
    var allUserOfContact = [[String:String]]()
    var replyChat :[String:String]?             // reply chat with key in
    var replyText : String?                     //passing chat for reply
    var key = [String]()
    var seen : [[String:Bool]] = []             // for store data which is in map format
    var keyBoardStatus = false                  // for showing keyboard
    var replyUser :UILabel?                     // when we swipe for reply this shows usernumber
    var replytxt : UILabel?                     // when we swipe for reply this shows text for which we give reply
    var seenVcStatus = false                    // use for view controller data calling seenStatus
    var seenStatusLabel = ""                    // seenStatusLabel
    var oppositeSeenStatus = false              // for not show seen when receiver sent msg
    var counter = 0                             // use for variable like   counter//
    var arrayStatus = [String]()                // s capital
    var toggle = true
    var lcb = false
    var receiverName = ""
    var receiverUserid = ""
    var groupAdmin = ""
    var forwardChatPhoto = ""
    var forwardChatVideo = ""
    var forwardChat = ""
    var forwardChatKey = ""
    var forwardCell = ""
    var currentUserData : [String:String] = [:]
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getdata()
        print("yes")
        navigationItem.backButtonTitle = ""
        tabBarController?.tabBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("true")
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
         print("Hello World - \(receiverid) - \(receiverName)")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ReceiverEditCode") as? ReceiverEditCode
        vc?.urlPath = urlPath
        vc?.fileName = fileName
        print("receiver id is \(receiverUserid) -- \(receiverName) - \(urlPath) -- \(fileName)")
        vc?.phones = receiverUserid
        vc?.uname = receiverName
        vc?.nav = "NavM"
        vc?.uid = ui
        vc?.groupAdmin = groupAdmin
        vc?.allUserOfFirebase = allUserOfFirebase
        vc?.groupMsgId = groupMsgId
        vc?.groupK = groupK
        vc?.currentUserData = currentUserData
        hideProgress()
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        if keyBoardStatus  == true {
            view.frame.size = CGSize(width: view.bounds.width, height: view.frame.height + CGFloat(keyboardheight))
            backgroundSV.frame.size = CGSize(width: backgroundSV.bounds.width, height: backgroundSV.frame.height + CGFloat(keyboardheight))
            keyBoardStatus = false
            view.endEditing(true)
        }
    }
    override func viewDidLoad() {
        print("view didload call")
        super.viewDidLoad()
        chatTable.delegate = self
        chatTable.dataSource = self
        titl.title = receiverName
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        receiverUserid = receiverid
        print("All user of contact is \(allUserOfContact)")
//        titl.titleView?.addGestureRecognizer(tap)
        navigationController?.navigationBar.addGestureRecognizer(tap)
        if usersNumber.prefix(3) != "+91" {
            print("+91\(usersNumber) ----")
            usersNumber = "+91\(usersNumber)"
            receiverid = "+91\(receiverid)"
        }
        
        codeFlex()
        print("\(usersNumber)")
        keyboardheight = 0
        seenVcStatus = true
        print("all user \(allUserOfContact)")
//        print("\(mid)!!! \(receiverid)---- \(usersNumber)====\(phoneid)-----\(msgIdList)")
        chatField.delegate = self
        if mid != "" {
        
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
                
                if seenVcStatus == true {
                    //                    if groupK != "yes" {
                    status()
                    //                    }
                   
                    if textFieldBtnStatus == true {
                        let indexPath = IndexPath(item: chatMapKey.count-1, section: 0)
                        chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        // scrollToBottom()
                        getdata()
                        
                        textFieldBtnStatus = false
                    } else {
                        hideProgress()
                    }
                }
            })
            getchat()
            //            if groupK != "yes" {
            status()
            //            }
        }
        mbProgressHUD(text: "Loading")
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: { [self] in
            if chatMap.count == 0 {
                hideProgress()
            }
        })
        
        
        
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        //        addImageVideo.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
            //tap.cancelsTouchesInView = false
        backgroundImage.addGestureRecognizer(tap1)
//        chatTable.addGestureRecognizer(tap1)
        if allUser.count > 0 {
            let UserList = usersDetails
            usersDetails.removeAll()
            for use in 0...UserList.count-1 {
                let frd = UserList[use]
                let splt = frd["Phone number"]?.split(separator: "+")
                if splt?.count == 1 {
                    print("did \(frd)")
                    usersDetails.append(frd)
                }
            }
            
            for use in 0...allUserOfFirebase.count-1 {
                //                print("User List  --- \(use)")
                let frd = allUserOfFirebase[use]
                var bbbol = false
                _ = allUser.filter { user in
                    //                    print("user is \(user)")
                    let myNumber =  user["Phone number"]
                    if frd["Phone number"] == myNumber {
                        print("yes ")
                        //                        print("Hib is \(myNumber!)----\(user["Name"])")
                        let str = user["Name"]
                        allUserOfFirebase[use] = ["Name": "\(str!)","Phone number": "\(myNumber!)","profilepic": "\(frd["profilepic"]!)"]
                    } else {
                        
                        _ = msgIdList.filter { user in
                            let str = user.split(separator: "+")
                            if str.count == 2 {
                                if "+\(str[0])" != phones || "+\(str[1])" != phones {
                                    for i in 0...str.count-1 {
                                        if bbbol == false {
                                            //                                            print("user \(frd["Phone number"]!)----\(str), \(use)")
                                            if frd["Phone number"]! == "+\(str[i])" && "+\(str[i])" != phones {
                                                print("user \(frd["Phone number"]!)----\(str), \(use)")
                                                bbbol = true
                                                allUserOfFirebase[use] = ["Name": "","Phone number": "\(frd["Phone number"]!)","profilepic": "\(frd["profilepic"]!)"]
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                            return true
                        }
                    }
                    return true
                }
            }
            
        }
        
    }
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    override func viewWillDisappear(_ animated: Bool) {
        seenVcStatus = false
//        view.endEditing(true)
    }
    var jist = false
    var myBoolStatus = [Bool]()
    func status(){
        seen.removeAll()
        arrayStatus.removeAll()
        myBoolStatus.removeAll()
        counter = 0
        database.child("Chats").child(mid).child("status").observe(.childAdded) {[weak self](snapshot) in
            if let _ = snapshot.value {
                
                if !(self?.arrayStatus.contains(snapshot.key.replacingOccurrences(of: "chatPhoto", with: "")))! {
                    self?.arrayStatus.append(snapshot.key.replacingOccurrences(of: "chatPhoto", with: ""))
                    self?.seen.append(["\(snapshot.key.replacingOccurrences(of: "chatPhoto", with: ""))":snapshot.value as! Bool])
                    self?.myBoolStatus.append(contentsOf: [snapshot.value as! Bool])
                    let mycombine  = self?.myBoolStatus[self!.counter]
                    let combineStatus = self?.seen[self!.counter]
                    let smf = combineStatus?["\(self!.phoneid)"]
                    self?.counter = self!.counter + 1
                    if self?.counter == 2 {
                        self?.counter = 0
                    }
                    
//                    print("Snap shot of the seen status \(snapshot.key.replacingOccurrences(of: "chatPhoto", with: ""))")
                    if  smf != nil && smf == false {
                                                print("all done")
                        self?.database.child("Chats").child(self!.mid).child("status").setValue(["\(self!.phoneid)":true, "\(self!.receiverid)":true])
                    }
                    if self?.groupK == "yes" {
                        if smf == false && snapshot.key.replacingOccurrences(of: "chatPhoto", with: "") == self?.phoneid {
//                            print("groupK")
                            self?.database.child("Chats").child(self!.mid).child("status").setValue(["\(self!.phoneid)":true, "\(self!.receiverid.replacingOccurrences(of: "chatPhoto", with: ""))":true])
                            
                        }
                        if (self?.myBoolStatus.count)! > 1 && (self?.arrayStatus.count)! > 1 {
//                            print("not found \(self!.myBoolStatus) -- \(self!.arrayStatus) -- \(self!.phoneid)")
                            if self?.arrayStatus[0] == "\(self!.phoneid)" {
//                                print("yyyyiu")
                                if self?.myBoolStatus[0] == false  {
//                                    print("one")
                                    self?.database.child("Chats").child(self!.mid).child("status").setValue(["\(self!.phoneid)":true, "\(self!.receiverid.replacingOccurrences(of: "chatPhoto", with: ""))":true])
                                }
                            }
                            else if self?.arrayStatus[1] == "\(self!.phoneid)" {
//                                print("uiiiiiiy")
                                if self?.myBoolStatus[1] == false {
//                                    print("two1")
                                    self?.database.child("Chats").child(self!.mid).child("status").setValue(["\(self!.phoneid)":true, "\(self!.receiverid.replacingOccurrences(of: "chatPhoto", with: ""))":true])
                                }
                            } else {
//                                print("userlo")
                                self?.database.child("Chats").child(self!.mid).child("status").setValue(["\(self!.phoneid)":true, "\(self!.receiverid.replacingOccurrences(of: "chatPhoto", with: ""))":true])
                            }
                        }
                    }
                }
                if self!.seen.count == 2 {
                    //                    print("seen \(self?.seen)")
                    if self?.groupK == "yes" {
                        let aStatus = self?.myBoolStatus[0]
                        let bStatus = self?.myBoolStatus[1]
//                        if (aStatus?["\(self!.receiverid.replacingOccurrences(of: "chatPhoto", with: ""))"] == true || bStatus?["\(self!.receiverid.replacingOccurrences(of: "chatPhoto", with: ""))"] == true) && ( aStatus?["\(self!.phoneid)"] == false || bStatus?["\(self!.phoneid)"] == false) {
//                            self?.chatTable.tableFooterView = self?.msgsseenfhidefooterview()
//                        } else
                        if aStatus == true  &&  bStatus == true {
                            self?.seenStatusLabel = "seen"
                            if self?.oppositeSeenStatus == false {
                                print("Show")
                                self?.lcb = false
                                if self?.toggle == true {
                                    print("oko")
                                    self?.chatTable.tableFooterView = self?.msgsSeenfooterview()
                                    self?.scrollToBottom()
                                    if self?.seenStatusLabel == "seen" {
                                        self?.toggle = false
                                    }
                                }
                            }else {
                                if self?.toggle == true {
                                    //                                self?.chatTable.tableFooterView = self?.msgsseenfhidefooterview()
                                    print("hide ")
                                }
                            }
                        }
                        else {
                            //                        print("message not seen")
                            self?.seenStatusLabel = "delivered"
                            //                        if self?.toggle == false {
                            //                            self?.scrollToBottom()
                            //                        }
                            if self?.lcb == false {
                                if self?.oppositeSeenStatus == false {
                                    if self?.toggle == true {
//                                        print("yes ")
                                        self?.chatTable.tableFooterView = self?.msgsSeenfooterview()
                                        self?.scrollToBottom()
                                        //                                self?.toggle = false
                                        if self?.seenStatusLabel == "delivered" {
                                            //                                    self?.toggle = false
                                            self?.lcb = true
                                        }
                                    }
                                } else {
                                    //                            self?.chatTable.tableFooterView = self?.msgsseenfhidefooterview()
                                    print("Hide 1")
                                }
                            }
                        }
                    }
                    else {
                        let aStatus = self?.seen[0]
                        let bStatus = self?.seen[1]
                        if (aStatus?["\(self!.receiverid)"] == true || bStatus?["\(self!.receiverid)"] == true) && ( aStatus?["\(self!.phoneid)"] == false || bStatus?["\(self!.phoneid)"] == false) {
                            self?.chatTable.tableFooterView = self?.msgsseenfhidefooterview()
                        } else if (aStatus?["\(self!.receiverid)"] == true || aStatus?["\(self!.phoneid)"] == true) && (bStatus?["\(self!.receiverid)"] == true || bStatus?["\(self!.phoneid)"] == true) {
                            self?.seenStatusLabel = "seen"
                            if self?.oppositeSeenStatus == false {
                                print("Show")
                                self?.lcb = false
                                if self?.toggle == true {
                                    print("oko")
                                    self?.chatTable.tableFooterView = self?.msgsSeenfooterview()
                                    self?.scrollToBottom()
                                    if self?.seenStatusLabel == "seen" {
                                        self?.toggle = false
                                    }
                                }
                            }else {
                                if self?.toggle == true {
                                    //                                self?.chatTable.tableFooterView = self?.msgsseenfhidefooterview()
                                    print("hide ")
                                }
                            }
                        }
                        else {
                            //                        print("message not seen")
                            self?.seenStatusLabel = "delivered"
                            //                        if self?.toggle == false {
                            //                            self?.scrollToBottom()
                            //                        }
                            if self?.lcb == false {
                                if self?.oppositeSeenStatus == false {
                                    if self?.toggle == true {
//                                        print("yes ")
                                        self?.chatTable.tableFooterView = self?.msgsSeenfooterview()
                                        self?.scrollToBottom()
                                        //                                self?.toggle = false
                                        if self?.seenStatusLabel == "delivered" {
                                            //                                    self?.toggle = false
                                            self?.lcb = true
                                        }
                                    }
                                } else {
                                    //                            self?.chatTable.tableFooterView = self?.msgsseenfhidefooterview()
                                    print("Hide 1")
                                }
                            }
                        }
                    }
                }
            }
            else {
                print("No data found")
            }
            //            print("\(snapshot)")
        }
    }
    
    func getdata() {
        database.child("Uid").getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return;
            }
            let userName = snapshot?.value;
            self.ui = userName as! Int
            print(self.ui)
        });
    }
    
    // MARK: - Get Chatting from Firebase Database
    func getchat() {
        var mymid = ""
        if groupK == "yes" {
            mymid = groupMsgId
        } else {
            mymid = mid
        }
        database.child("Chats").child(mymid).child("chatting").observe(.childAdded) {[weak self](snapshot) in
            DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                guard let _ = snapshot.value as? [String:Any] else {return
                    print("Error")
                }
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        let cata = snap.key
//                        let ques = snap.value!
//                        let  json = snapshot.value as? [String:Any]
                        if !(self?.key.contains(snapshot.key))! {
                            self?.chatMap.append([snapshot.key :snapshot.value as! [String:Any]])
                            self?.key.append(snapshot.key)
                            self?.chatMapKey.append("\(cata)")
                            self?.chatTable.reloadData()
                            self?.oppositeSeenStatus = false
                            //                            self?.toggle = true
                        }
                        self?.textFieldBtnStatus = true
                    }
                }
                if self?.chatMapKey.count != 0 {
//                    print("key is \(self!.key)")
//                    print("chatMapKey is \(self!.chatMapKey)")
                }
            }
        }
    }
    
    func codeFlex(){
        if msgIdList.count > 0 {
            for avl in 0...msgIdList.count - 1 {
//                print("msgkey at index  \(msgIdList[avl])")
                if msgIdList[avl] == "\(phoneid)\(usersNumber)" || msgIdList[avl] == "\(usersNumber)\(phoneid)" || msgIdList[avl] == "\(usersNumber)" {
                    mid = msgIdList[avl]
                    // print("True -----------")
                    msgstatus = true
                    break
                }else {
                    msgstatus = false
                }
            }
        }
//        mychat()
    }
    func mychat() {
        if msgstatus == false {
            
            mid = "\(phoneid)\(usersNumber)"
                    DataBaseManager.shared.createNewChat(with: Message( messagid: self.mid, chats: "", sender: "",uii: 0, chatPhotos: ""))
        }
    }
    
    // MARK: - Send Chats to Firebase Realtime Database
    @IBAction func sendChat(_ sender: UIButton) {
        chatTable.sectionFooterHeight = 0
        if chatField.text != "" {
            ui = ui + 1
            if mid == "" {
                mychat()
            }
            var mymid = ""
            if groupK == "yes" {
                mymid = groupMsgId
            } else {
                mymid = mid
            }
            seenStatusLabel = "delivered"
            oppositeSeenStatus = false
            lcb = false
            chatTable.tableFooterView = msgsSeenfooterview()
            database.child("Uid").setValue(ui)
            database.child("Chats").child(mymid).child("status").setValue(["\(phoneid)":true,"\(receiverid)":false])
            
            if replyChat == nil {
                database.child("Chats").child(mymid).child("chatting").child("\(ui)").setValue(["\(phoneid)": chatField.text!], withCompletionBlock: { error, _ in
                    guard error == nil else {
                        print("Failed to write data")
                        return
                    }
                    print("data written seccess")
                    self.oppositeSeenStatus = false
                    self.toggle = true
                })
                chatField.text = ""
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    self.chatTable.reloadData()
                    if chatMap.count > 16 {
                        let indexPath = IndexPath(item: chatMapKey.count-1, section: 0)
                        chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                    
                }
            } else {
                database.child("Chats").child(mymid).child("chatting").child("\(ui)").setValue(["\(phoneid)": chatField.text!,replyText:replyChat as Any], withCompletionBlock: { [self] error, _ in
                    guard error == nil else {
                        print("Failed to write data")
                        return
                    }
                    replyChat?.removeAll()
                    chatField.text = ""
                    print("data written seccess")
                })
                
            }
        }
    }
    
    
    
    
    
    
}

// MARK: - ImagePicker Codes
extension ChatConversionCode {
    @IBAction func addImageVideo(_ sender: UIButton) {
        imageTapped()
    }
    @objc
    func imageTapped()
    {
        
        keyBoardStatus = true
        view.endEditing(true)
        print("Image Tapped...!")
        
        let ac = UIAlertController(title: "Select Image From", message: "", preferredStyle: .actionSheet)
        let cameraBtn = UIAlertAction(title: "Camera", style: .default){(_) in
            print("Camera Press")
            self.showImagePicker(selectSource: .camera)
        }
        let libraryBtn = UIAlertAction(title: "Photo and Video Library", style: .default){(_) in
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
        guard UIImagePickerController.isSourceTypeAvailable(selectSource) else {
            print("Selected Source not available")
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectSource
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("inside")
        if let  videoURL = info[.mediaURL] as? URL
        {
            let localFile = URL(string: "\(videoURL)")!
            print("Video Url is -=-=-=-=-=-=-=-==-=-= \(videoURL)")
            //            let asset = AVURLAsset(url: videoURL,options: nil)
            //            let imgGenerator = AVAssetImageGenerator(asset: asset)
            //            imgGenerator.appliesPreferredTrackTransform = true
            
            //            let cgImage = try  imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            //                let thumbnail = UIImage(cgImage: cgImage)
            //                print("asset -----===== \(asset)")
            //                print("cgImage  ======= \(cgImage)")
            //                print("thumbnail ========= \(thumbnail)")
            let storageRef = Storage.storage().reference()
            let filename = "chatVideo/\(UUID().uuidString).MOV"
            let fileRef = storageRef.child(filename)
            if groupK == "yes" {
                mid = groupMsgId
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.mbProgressHUD(text: "")
                let uploadTask = fileRef.putFile(from: localFile, metadata: nil){metadata, error in
                    var urlpth = ""
                    if error == nil && metadata != nil {
                        
                        fileRef.downloadURL(completion: { [self](url,error) in
                            if error == nil {
                                urlpth = "\(url!)"
                                self.ui = self.ui + 1
                                self.database.child("Uid").setValue(self.ui)
                                database.child("Chats").child(mid).child("status").setValue(["\(phoneid)":true,"\(receiverid)":false])
                                self.database.child("Chats").child(self.mid).child("chatting").child("\(self.ui)").setValue(["\(self.phoneid)chatVideo": urlpth], withCompletionBlock: { error, _ in
                                    guard error == nil else {
                                        print("Failed to write data ")
                                        return
                                    }
                                    print("data written seccess ")
                                    DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                                        picker.dismiss(animated: true)
                                        hideProgress()
                                    }
                                })
                            } else {
                                print("Error for download url \(String(describing: error))")
                            }
                        })
                    } else {
                        print("Error for uploading \(String(describing: error))-----------")
//                        print("Metadata is >>>>>>>>>>>>> \(metadata)")
                    }
                }
                _ = uploadTask
            }
            
        } else {
            print("*** Error generating thumbnail: ")
        }
        
        if let selectedImage =  info[.originalImage] as? UIImage{
            print("Selected image ",selectedImage)
            //            add.image = selectedImage
            didselectedImage = selectedImage
//            let localPath = info[.imageURL] as? NSURL
//            _ = info[.imageURL] as? URL
//            print("Local Path  > ",localPath!)
            
            picker.dismiss(animated: true, completion: nil)
            keyboardheight = 0
            let imgVc = storyboard?.instantiateViewController(withIdentifier: "ImageAndVideoShowCode") as? ImageAndVideoShowCode
            imgVc?.navselectedImage = didselectedImage
            if groupK == "yes" {
                imgVc?.mesId = groupMsgId
            } else {
                imgVc?.mesId = mid
            }
            
            imgVc?.uid = ui
            self.show(imgVc!, sender: self)
            
        }
        else{
            print("Image not found...!")
        }
        
    }
    
    func afterForwardPop() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Keyboard handling
extension ChatConversionCode : UITextFieldDelegate{
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        view.endEditing(true)
    //    }
    @objc func keyboardWillShow(sender: NSNotification) {
        
        if keyBoardStatus == false {
            keyBoardStatus = true
            if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                print("Height of UIVIew Before \(view.frame.height)")
                view.frame.size = CGSize(width: view.bounds.width, height: view.frame.height - keyboardSize.height)
                print("Height of UIVIew \(view.frame.height)")
                bkview.frame.size = CGSize(width: bkview.bounds.width, height: bkview.frame.height - keyboardSize.height)
                keyboardheight = Int(keyboardSize.height)
                chatTable.frame.size = CGSize(width: chatTable.frame.width, height: chatTable.frame.height - keyboardSize.height)
                backgroundSV.frame.size = CGSize(width: backgroundSV.bounds.width, height: backgroundSV.frame.height - keyboardSize.height)
                //               print("asdasd" , keyboardheight)
            }
            if chatMapKey.count > 0 {
                let indexPath = IndexPath(item: chatMapKey.count-1, section: 0)
                chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if keyBoardStatus  == true {
            view.frame.size = CGSize(width: view.bounds.width, height: view.frame.height + CGFloat(keyboardheight))
            backgroundSV.frame.size = CGSize(width: backgroundSV.bounds.width, height: backgroundSV.frame.height + CGFloat(keyboardheight))
            keyBoardStatus = false
            view.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Text hide called")
        if keyBoardStatus  == true {
            view.frame.size = CGSize(width: view.bounds.width, height: view.frame.height + CGFloat(keyboardheight))
            backgroundSV.frame.size = CGSize(width: backgroundSV.bounds.width, height: backgroundSV.frame.height + CGFloat(keyboardheight))
            keyBoardStatus = false
            view.endEditing(true)
            return false
        } else {
            return true
        }
        
        
        
    }
    
}


// MARK: - Delegate Methods of TableView
extension ChatConversionCode : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMap.count
    }
    @objc func imgTap()
        {
            print("Hell World")
//            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "testViewController") as? testViewController
//                let navController = UINavigationController(rootViewController: secondViewController!)
//                navController.setViewControllers([secondViewController!], animated:true)
//                self.revealViewController().setFront(navController, animated: true)
//                revealViewController().pushFrontViewController(navController, animated: true)
//            secondViewController?.movmentId = Id1stMove
//            updateCount(itemId: Id1stMove)

        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = chatMap[indexPath.row]
        let userNumberKey = chatMapKey[indexPath.row]
        let uniqueKey = key[indexPath.row]
        let chatText = chat[uniqueKey]
        let txtChat = chatText?[userNumberKey]
//                print("chat length is =====------------> \(chat)")
//                print("userNumberKey INDEX is =====--=-= \(userNumberKey)")
//                print("uniqueKey is =====-------> \(uniqueKey)")
//                print("chatText =================......\(String(describing: chatText))")
//                print("txtchat is ======----> \(txtChat)")
//                print("key chat is =======--- \(key)")
//                print("chatMapKey is ..........  \(chatMapKey)--")
        view.endEditing(true)
        if keyBoardStatus == true {
            keyBoardStatus = false
        }
    }
    
    @objc func videoTappSenderReceiver(_ sender: UITapGestureRecognizer) {
//        print("\(sender.view?.tag) Tapped    \(chatMap.count)")

        guard let indexPathRow = sender.view?.tag else {
            return
        }
        
        let chat = chatMap[indexPathRow]
        let userNumberKey = chatMapKey[indexPathRow]
        let uniqueKey = key[indexPathRow]
        let chatText = chat[uniqueKey]
        let txtChat = chatText?[userNumberKey]
        
        videoPlayer(videoUrl: txtChat! as! String)
        print("MY URL IS ++++ \(txtChat ?? "")")
    }
    @objc func imageTappSenderReceiver(_ sender: UITapGestureRecognizer) {
//        print("\(sender.view?.tag) Tapped    \(chatMap.count)")

        guard let indexPathRow = sender.view?.tag else {
            return
        }
        
        let chat = chatMap[indexPathRow]
        let userNumberKey = chatMapKey[indexPathRow]
        let uniqueKey = key[indexPathRow]
        let chatText = chat[uniqueKey]
        let txtChat = chatText?[userNumberKey]
        
        keyBoardStatus = true
        view.endEditing(true)
        imageShow(url:txtChat! as! String)
    }
    @objc func messageTapp(_ sender: UITapGestureRecognizer) {
//        print("\(sender.view?.tag) Tapped    \(chatMap.count)")

        guard let indexPathRow = sender.view?.tag else {
            return
        }
        
        let chat = chatMap[indexPathRow]
        let userNumberKey = chatMapKey[indexPathRow]
        let uniqueKey = key[indexPathRow]
        let chatText = chat[uniqueKey]
        let txtChat = chatText?[userNumberKey]
        
        for i in 0...key.count-1 {
            if key[i] == userNumberKey {
                //                print("userNumberKey is =====-------> \(userNumberKey)")
                let val = key.count - i - 1
                //                print("i is ",key[key.count-val-1])
                //                print("\(key.count-val-1) ===")
                let indexPath = IndexPath(item: key.count-val-1, section: 0)
                chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
                self.chatTable.cellForRow(at: indexPath)?.selectionStyle = .blue
                self.chatTable.cellForRow(at: indexPath)?.isHighlighted = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.chatTable.cellForRow(at: indexPath)?.isHighlighted = false
                    self.chatTable.cellForRow(at: indexPath)?.selectionStyle = .none
                }
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < chatMap.count {
            let chat = chatMap[indexPath.row]
            let userNumberKey = chatMapKey[indexPath.row]
            let uniqueKey = key[indexPath.row]
            let chatText = chat[uniqueKey]
            let txtChat = chatText?[userNumberKey]
            let abc = chatText?[userNumberKey]  as? [String : Any]  // Use for replying chats
            //            if groupK == "no" {
            
//            print("chat ================-------\(chat)")
//            print("userNumberKey ================-------\(userNumberKey)")
//            print("uniqueKey ================-------\(uniqueKey)")
//            print("chatText ================-------\(String(describing: chatText?[phoneid]))")
//            print("abc?[phoneid] ================-------\(String(describing: abc?["\(phoneid)"]))")
//            print("abc?[receiverid] ================-------\(String(describing: abc?["\(receiverid)"]))")
//            print("abc ================-------\(String(describing: abc))")
            var bollk = false
            var folk = false
            var forfolk = false
            var nameString = ""
            if groupK == "yes" {
                let checkForReply = mid.split(separator: "+")
                for i in 0...checkForReply.count-1 {
                    if "+\(checkForReply[i])" != phoneid && (abc?["+\(checkForReply[i])"] != nil || abc?["+\(checkForReply[i])chatPhoto"] != nil || abc?["+\(checkForReply[i])chatVideo"] != nil) {
                        receiverid = "+\(checkForReply[i])"
                        _ = allUserOfContact.filter {user in
                            let str = user["Phone number"]
                            if receiverid.contains(str!){
                                nameString = user["Name"]!
//                                print("name of messager is \(user["Name"])--")
                            }
                            return true
                            
                        }
                        
//                        print("receiver id --=-=-=-=-=--------*********** \(receiverid)")
                        bollk = true
                        folk = true
                        break
                    }
                }
                if bollk == false {
                    for i in 0...checkForReply.count-1 {
                        if "+\(checkForReply[i])" != phoneid && "+\(checkForReply[i])chatPhoto" == userNumberKey{
                            receiverid = "+\(checkForReply[i])chatPhoto"
//                            print(" photo is \(receiverid)")
                            _ = allUserOfContact.filter {user in
                                let str = user["Phone number"]
                                if receiverid.contains(str!){
                                    nameString = user["Name"]!
//                                    print("--name of messager is \(user["Name"])")
                                }
                                return true
                                
                            }
                            bollk = true
                            break
                        }
                    }
                }
                if folk == false {
                    for i in 0...checkForReply.count-1 {
                        if "+\(checkForReply[i])" != phoneid && "+\(checkForReply[i])chatVideo" == userNumberKey{
                            receiverid = "+\(checkForReply[i])chatVideo"
//                            print(" video is \(receiverid)")
                            _ = allUserOfContact.filter {user in
                                let str = user["Phone number"]
                                if receiverid.contains(str!){
                                    nameString = user["Name"]!
//                                    print("name of messager is \(user["Name"])")
                                }
                                return true
                                
                            }
                            
                            folk = true
                            forfolk = true
                            break
                        }
                    }
                }
            }
            
            if abc?["\(phoneid)"] != nil || abc?["\(receiverid)"] != nil ||  abc?["\(receiverid)chatPhoto"] != nil || abc?["\(phoneid)chatPhoto"] != nil || abc?["\(receiverid)chatVideo"] != nil || abc?["\(phoneid)chatVideo"] != nil {
                
                if abc?["\(receiverid)chatPhoto"] != nil || abc?["\(phoneid)chatPhoto"] != nil {
                    
                    if chatText?["\(phoneid)"] == nil {
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "ReceiverReplyImageCell") as? ReceiverReplyImageCell
                        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.messageTapp))
                        cell?.viewC.addGestureRecognizer(tapGesture)
                        cell?.viewC.tag = indexPath.row
                        if groupK == "yes" {
                            let checking = mid.split(separator: "+")
                            for i in  0...checking.count-1 {
                                if chatText?["+\(checking[i])"] != nil {
//                                    print("_+_+_+ \(phoneid)  \(checking[i]) \(chatText?["+\(checking[i])"])")
                                    cell?.receiverreply.text = chatText?["+\(checking[i])"] as? String
                                    cell?.receiverNumber.text = "+\(checking[i])"
//                                    if nameString != ""{
//                                        cell?.receiverNumber.text = "\(nameString)"
//                                    }
                                    _ = allUserOfContact.filter { user in
                                        let str = user["Phone number"]
                                        
                                        if "+\(checking[i])" == str {
                                            nameString = user["Name"]!
            //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                            if user["Name"] != ""  {
//                                                print("Yes ")
                                                cell?.receiverNumber.text = "\(nameString)"
                                            }
                                        }
                                        return true
                                    }
                                    break
                                }
                            }
                        } else {
                            cell?.receiverreply.text = chatText?["\(receiverid)"] as? String
                        }
                        if abc?["\(receiverid)chatPhoto"] == nil {
                            let bar = abc?["\(phoneid)chatPhoto"] as? String
                            cell?.confi(videoUrl: bar!)
                            cell?.user.text = "You"
                        } else {
                            let bar = abc?["\(receiverid)chatPhoto"] as? String
                            //                            print("-=-=-=-====-=-= \(bar!)")
                            cell?.confi(videoUrl: bar!)
                            cell?.user.text = "\(receiverid)"
//                            if nameString != ""{
//                                cell?.user.text = "\(nameString)"
//                            }
                            _ = allUserOfContact.filter { user in
                                let str = user["Phone number"]
                                
                                if "\(receiverid.replacingOccurrences(of: "chatPhoto", with: ""))" == str {
                                    nameString = user["Name"]!
    //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                    if user["Name"] != ""  {
//                                        print("Yes ")
                                        cell?.user.text = "\(nameString)"
                                    }
                                }
                                return true
                            }
                        }
                        
                        if abc?["\(receiverid)text"] == nil {
                            cell?.receivermsg.text = abc?["\(phoneid)text"] as? String
                            
                            if abc?["\(phoneid)text"] == nil {
                                cell?.receivermsg.text = "📷 Photo"
                            }
                        } else {
                            cell?.receivermsg.text = abc?["\(receiverid)text"] as? String
                            
                            if abc?["\(receiverid)text"] == nil {
                                cell?.receivermsg.text = "📷 Photo"
                            }
                        }
                        cell?.selectionStyle = .none
                        if indexPath.row == chatMapKey.count-1 {
                            if oppositeSeenStatus == false {
                                chatTable.tableFooterView = msgsseenfhidefooterview()
                                oppositeSeenStatus = true
                                toggle = false
                            }
                        }
                        
                        return cell!
                    } else {
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderReplyImageCell") as? SenderReplyImageCell
                        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.messageTapp))
                        cell?.viewC.addGestureRecognizer(tapGesture)
                        cell?.viewC.tag = indexPath.row
                        if groupK == "yes" {
                            let checking = mid.split(separator: "+")
                            for i in  0...checking.count-1 {
                                if chatText?["+\(checking[i])"] != nil {
//                                    print("_+_+_+ \(phoneid)  \(checking[i]) \(chatText?["+\(checking[i])"])")
                                    cell?.senderreply.text = chatText?["+\(checking[i])"] as? String
//                                    cell?.senderNumber.text = "you"
                                    break
                                }
                            }
                        } else {
                            cell?.senderreply.text = chatText?["\(phoneid)"] as? String
                        }
                        if abc?["\(receiverid)chatPhoto"] == nil {
                            let bar = abc?["\(phoneid)chatPhoto"] as? String
                            cell?.confi(videoUrl: bar!)
                            cell?.user.text = "You"
                        } else {
                            let bar = abc?["\(receiverid)chatPhoto"] as? String
                            print("-=-=-=-====-=-= \(bar!)")
                            cell?.confi(videoUrl: bar!)
                            cell?.user.text = "\(receiverid)"
//                            if nameString != ""{
//                                cell?.user.text = "\(nameString)"
//                            }
                            _ = allUserOfContact.filter { user in
                                let str = user["Phone number"]
                                
                                if "\(receiverid.replacingOccurrences(of: "chatPhoto", with: ""))" == str {
                                    nameString = user["Name"]!
    //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                    if user["Name"] != ""  {
//                                        print("Yes ")
                                        cell?.user.text = "\(nameString)"
                                    }
                                }
                                return true
                            }
                        }
                        if abc?["\(receiverid)text"] == nil {
                            cell?.sendermsg.text = abc?["\(phoneid)text"] as? String
                            
                            if abc?["\(phoneid)text"] == nil {
                                cell?.sendermsg.text = "📷 Photo"
                                print("yahh")
                            }
                        } else {
                            cell?.sendermsg.text = abc?["\(receiverid)text"] as? String
                            
                            if abc?["\(receiverid)text"] == nil {
                                cell?.sendermsg.text = "📷 Photo"
                            }
                        }
                        cell?.selectionStyle = .none
                        if indexPath.row == chatMapKey.count-1 {
                            toggle = true
                        }
                        
                        return cell!
                    }
                } else if abc?["\(receiverid)chatVideo"] != nil || abc?["\(phoneid)chatVideo"] != nil {
                    if chatText?["\(phoneid)"] == nil {
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "ReceiverReplyImageCell") as? ReceiverReplyImageCell
                        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.messageTapp))
                        cell?.viewC.addGestureRecognizer(tapGesture)
                        cell?.viewC.tag = indexPath.row
//                        print("Of course jii \(chatText?["\(receiverid)"])")
                        if groupK == "yes" {
                            let checking = mid.split(separator: "+")
                            for i in  0...checking.count-1 {
                                if chatText?["+\(checking[i])"] != nil {
//                                    print("_+_+_+ \(phoneid)  \(checking[i]) \(chatText?["+\(checking[i])"])")
                                    cell?.receiverreply.text = chatText?["+\(checking[i])"] as? String
                                    cell?.receiverNumber.text = "+\(checking[i])"
//                                    if nameString != ""{
//                                         cell?.receiverNumber.text = "\(nameString)"
//                                    }
                                    _ = allUserOfContact.filter { user in
                                        let str = user["Phone number"]
                                        
                                        if "+\(checking[i])" == str {
                                            nameString = user["Name"]!
            //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                            if user["Name"] != ""  {
//                                                print("Yes ")
                                                cell?.user.text = "\(nameString)"
                                            }
                                        }
                                        return true
                                    }
                                    break
                                }
                            }
                        } else {
                            cell?.receiverreply.text = chatText?["\(receiverid)"] as? String
                        }
                        if abc?["\(receiverid)chatVideo"] == nil {
                            let bar = abc?["\(phoneid)chatVideo"] as? String
                            cell?.videocon(videoUrl: bar!)
                            cell?.user.text = "You"
                        } else {
                            let bar = abc?["\(receiverid)chatVideo"] as? String
                            cell?.user.text = "\(receiverid)"
//                            if nameString != ""{
//                                cell?.user.text = "\(nameString)"
//                            }
                            _ = allUserOfContact.filter { user in
                                let str = user["Phone number"]
                                
                                if "\(receiverid.replacingOccurrences(of: "chatVideo", with: ""))" == str {
                                    nameString = user["Name"]!
    //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                    if user["Name"] != ""  {
//                                        print("Yes ")
                                        cell?.user.text = "\(nameString)"
                                    }
                                }
                                return true
                            }
                            cell?.videocon(videoUrl: bar!)
                        }
                        
                        if abc?["\(receiverid)text"] == nil {
                            cell?.receivermsg.text = abc?["\(phoneid)text"] as? String
                            if abc?["\(phoneid)text"] == nil {
                                cell?.receivermsg.text = "📷 Video"
                            }
                        } else {
                            cell?.receivermsg.text = abc?["\(receiverid)text"] as? String
                            if abc?["\(receiverid)text"] == nil {
                                cell?.receivermsg.text = "📷 Video"
                                
                            }
                        }
                        cell?.selectionStyle = .none
                        if indexPath.row == chatMapKey.count-1 {
                            if oppositeSeenStatus == false {
                                chatTable.tableFooterView = msgsseenfhidefooterview()
                                oppositeSeenStatus = true
                                toggle = false
                            }
                        }
                        
                        return cell!
                        
                    } else {
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderReplyImageCell") as? SenderReplyImageCell
                        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.messageTapp))
                        cell?.viewC.addGestureRecognizer(tapGesture)
                        cell?.viewC.tag = indexPath.row
                        if groupK == "yes" {
                            let checking = mid.split(separator: "+")
                            for i in  0...checking.count-1 {
                                if chatText?["+\(checking[i])"] != nil {
//                                    print("_+_+_+ \(phoneid)  \(checking[i]) \(chatText?["+\(checking[i])"])")
                                    cell?.senderreply.text = chatText?["+\(checking[i])"] as? String
//                                    cell?.senderNumber.text = "you"
                                    break
                                }
                            }
                        } else {
                            cell?.senderreply.text = chatText?["\(phoneid)"] as? String
                        }
                        if abc?["\(receiverid)chatVideo"] == nil {
                            let bar = abc?["\(phoneid)chatVideo"] as? String
                            cell?.videocon(videoUrl: bar!)
                            cell?.user.text = "You"
                        } else {
                            let bar = abc?["\(receiverid)chatVideo"] as? String
                            //                            print("-=-=-=-====-=-= \(bar!)")
                            cell?.videocon(videoUrl: bar!)
                            cell?.user.text = "\(receiverid)"
                            _ = allUserOfContact.filter { user in
                                let str = user["Phone number"]
                                
                                if "\(receiverid)" == str {
                                    nameString = user["Name"]!
    //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                    if user["Name"] != ""  {
//                                        print("Yes ")
                                        cell?.user.text = "\(nameString)"
                                    }
                                }
                                return true
                            }
                        }
                        if abc?["\(receiverid)text"] == nil {
                            cell?.sendermsg.text = abc?["\(phoneid)text"] as? String
                            if abc?["\(phoneid)text"] == nil {
                                cell?.sendermsg.text = "📷 Video"
                            }
                        } else {
                            cell?.sendermsg.text = abc?["\(receiverid)text"] as? String
                            
                            if abc?["\(receiverid)text"] == nil {
                                cell?.sendermsg.text = "📷 Video"
                            }
                        }
                        cell?.selectionStyle = .none
                        if indexPath.row == chatMapKey.count-1 {
                            toggle = true
                        }
                        
                        return cell!
                    }
                }
                else if chatText?["\(phoneid)"] == nil {
//                    print("Message Reply of receiver is \(abc?["\(receiverid)"])")
                    let cell = chatTable.dequeueReusableCell(withIdentifier: "ReceiverReplyViewCell") as? ReceiverReplyViewCell
                    let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.messageTapp))
                    cell?.viewC.addGestureRecognizer(tapGesture)
                    cell?.viewC.tag = indexPath.row
                    if abc?["\(receiverid)"] == nil{
                        cell?.receiverMessages.text = abc?["\(phoneid)"] as? String
                        cell?.user.text = "You"
                        
                    } else {
                        cell?.receiverMessages.text = abc?["\(receiverid)"] as? String
                        cell?.user.text = "\(receiverid)"
//                        if nameString != "" {
//                            cell?.user.text = "\(nameString)"
//                            print("yup")
//                        }
                        _ = allUserOfContact.filter { user in
                            let str = user["Phone number"]
                            
                            if "\(receiverid)" == str {
                                nameString = user["Name"]!
//                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                if user["Name"] != ""  {
//                                    print("Yes ")
                                    cell?.user.text = "\(nameString)"
                                }
                            }
                            return true
                        }
                    }
                    if chatText?["\(receiverid)"] == nil {
//                        print("nop   \(chatText?["\(phoneid)"])")
                        if groupK == "yes" {
                            let checking = mid.split(separator: "+")
                            for i in  0...checking.count-1 {
                                if chatText?["+\(checking[i])"] != nil {
//                                    print("_+_+_+ \(phoneid)  \(checking[i]) \(chatText?["+\(checking[i])"])")
                                    cell?.receiverReply.text = chatText?["+\(checking[i])"] as? String
                                    cell?.receiverNumber.text = "+\(checking[i])"
//                                    if nameString != "" {
//                                        cell?.receiverNumber.text = "\(nameString)"
//                                        print("yup 2323233 \(nameString)")
//                                    }
                                    _ = allUserOfContact.filter { user in
                                        let str = user["Phone number"]
                                        
                                        if "+\(checking[i])" == str {
                                            nameString = user["Name"]!
        //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                            if user["Name"] != ""  {
//                                                print("Yes ")
                                                cell?.receiverNumber.text = "\(nameString)"
                                            }
                                        }
                                        return true
                                    }
                                    break
                                }
                            }
                        } else {
                            cell?.receiverReply.text = chatText?["\(phoneid)"] as? String
                            if groupK == "yes" {
                                cell?.receiverNumber.text = "\(receiverid)"
//                                if nameString != "" {
//                                    cell?.receiverNumber.text = "\(nameString)"
//                                }
                                _ = allUserOfContact.filter { user in
                                    let str = user["Phone number"]
                                    
                                    if "\(receiverid)" == str {
                                        nameString = user["Name"]!
        //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                        if user["Name"] != ""  {
//                                            print("Yes ")
                                            cell?.receiverNumber.text = "\(nameString)"
                                        }
                                    }
                                    return true
                                }
                            }
                        }
                    } else {
                        print("nop1")
                        if groupK == "yes"{
                            let checking = mid.split(separator: "+")
                            for i in  0...checking.count-1 {
                                if chatText?["+\(checking[i])"] != nil {
//                                    print("_+_+_+ \(phoneid)  \(checking[i]) \(chatText?["+\(checking[i])"])")
                                    cell?.receiverReply.text = chatText?["+\(checking[i])"] as? String
                                    cell?.receiverNumber.text = "+\(checking[i])"
//                                    if nameString != "" {
//                                        cell?.receiverNumber.text = "\(nameString)"
//                                    }
                                    _ = allUserOfContact.filter { user in
                                        let str = user["Phone number"]
                                        
                                        if "+\(checking[i])" == str {
                                            nameString = user["Name"]!
        //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                            if user["Name"] != ""  {
//                                                print("Yes ")
                                                cell?.receiverNumber.text = "\(nameString)"
                                            }
                                        }
                                        return true
                                    }
                                    break
                                }
                            }
                        } else {
                            cell?.receiverReply.text = chatText?["\(receiverid)"] as? String
                            if groupK == "yes" {
                                cell?.receiverNumber.text = "\(receiverid)"
                                if nameString != "" {
                                    cell?.receiverNumber.text = "\(nameString)"
                                }
                                _ = allUserOfContact.filter { user in
                                    let str = user["Phone number"]
                                    
                                    if "\(receiverid.replacingOccurrences(of: "", with: ""))" == str {
                                        nameString = user["Name"]!
    //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                        if user["Name"] != ""  {
//                                            print("Yes ")
                                            cell?.receiverNumber.text = "\(nameString)"
                                        }
                                    }
                                    return true
                                }
                            }
                        }
                    }
                    cell?.selectionStyle = .none
                    if indexPath.row == chatMapKey.count-1 {
                        if oppositeSeenStatus == false {
                            chatTable.tableFooterView = msgsseenfhidefooterview()
                            oppositeSeenStatus = true
                            toggle = false
                        }
                    }
                    
                    return cell!
                }
                else if chatText?["\(receiverid)"] == nil {
//                    print("Message Reply of sender is \(abc?["\(phoneid)"])")
                    let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderReplyViewCell") as? SenderReplyViewCell
                    let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.messageTapp))
                    cell?.viewC.addGestureRecognizer(tapGesture)
                    cell?.viewC.tag = indexPath.row
                    if abc?["\(phoneid)"] == nil {
                        
                        cell?.senderMessages.text = abc?["\(receiverid)"] as? String
                        cell?.user.text = "\(receiverid)"
//                        if nameString != "" {
//                            cell?.user.text = "\(nameString)"
//                        }
                        _ = allUserOfContact.filter { user in
                            let str = user["Phone number"]
                            
                            if "\(receiverid)" == str {
                                nameString = user["Name"]!
//                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                if user["Name"] != ""  {
//                                    print("Yes ")
                                    cell?.user.text = "\(nameString)"
                                }
                            }
                            return true
                        }
                    } else {
                        cell?.senderMessages.text = abc?["\(phoneid)"] as? String
                        cell?.user.text = "You"
//                        print("\(mid) ================-------\(abc?["\(phoneid)"])")
                    }
                    if chatText?["\(phoneid)"] == nil {
                        if groupK == "yes"{
                            let checking = mid.split(separator: "+")
                            for i in  0...checking.count-1 {
                                if chatText?["+\(checking[i])"] != nil {
//                                    print("_+_+_+ \(phoneid)  \(checking[i]) \(chatText?["+\(checking[i])"])")
                                    cell?.senderReply.text = chatText?["+\(checking[i])"] as? String
                                    break
                                }
                            }
                        }else {
                            cell?.senderReply.text = chatText?["\(receiverid)"] as? String
                        }
                    }
                    else {
                        //                            if groupK == "yes" {
                        //                                var kepp = mid.split(separator: "+")
                        //                            }
                        if groupK == "yes"{
                            let checking = mid.split(separator: "+")
                            for i in  0...checking.count-1 {
                                if chatText?["+\(checking[i])"] != nil {
//                                    print("_+_+_+ \(phoneid)  \(checking[i]) \(chatText?["+\(checking[i])"])")
                                    cell?.senderReply.text = chatText?["+\(checking[i])"] as? String
                                    break
                                }
                            }
                        }else {
//                            print("\(mid) ================-------\(chatText?["\(phoneid)"])")
                            cell?.senderReply.text = chatText?["\(phoneid)"] as? String
                        }
                    }
                    if groupK == "yes" {
//                        cell?.senderNumber.text = "You"
                        
                    }
                    cell?.selectionStyle = .none
                    if indexPath.row == chatMapKey.count-1 {
                        toggle = true
                    }
                    return cell!
                }
            }
            else {
                if userNumberKey == "\(phoneid)chatPhoto" || userNumberKey == "\(receiverid)chatPhoto" || userNumberKey == "chatPhoto" || (userNumberKey == receiverid && bollk == true) {
                    print("calleee \(receiverid)")
                    if userNumberKey == "\(receiverid)chatPhoto" || (userNumberKey == receiverid && bollk == true) {
                        print("txtchat == \(receiverid)")
                        if txtChat as! String != "" {
                            let cell = chatTable.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as? ImageTableViewCell
                            let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.imageTappSenderReceiver))
                            cell?.viewC.addGestureRecognizer(tapGesture)
                            cell?.viewC.tag = indexPath.row
                            if receiverid.contains("text") || receiverid.contains("chatPhoto") {
                                if receiverid.contains("text") {
                                    cell?.receiverComentImage.text = chatText?["\(receiverid)"] as? String
                                } else {
                                    cell?.receiverComentImage.text = chatText?["\(receiverid.replacingOccurrences(of: "chatPhoto", with: "text"))"] as? String
                                }
                            } else {
                                cell?.receiverComentImage.text = chatText?["\(receiverid)text"] as? String
                                
                            }
                            if groupK == "yes" {
                                cell?.receiverNumber.text = "\(userNumberKey.replacingOccurrences(of: "chatPhoto", with: ""))"
                                _ = allUserOfContact.filter { user in
                                    let str = user["Phone number"]
                                    
                                    if "\(userNumberKey.replacingOccurrences(of: "chatPhoto", with: ""))" == str {
                                        nameString = user["Name"]!
    //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                        if user["Name"] != ""  {
//                                            print("Yes ")
                                            cell?.receiverNumber.text = "\(nameString)"
                                        }
                                    }
                                    return true
                                }
                            }
                            let url = URL(string: txtChat  as! String)
                            cell?.photos.kf.setImage(with: url)
                            cell?.selectionStyle = .none
                            if indexPath.row == chatMapKey.count-1 {
                                chatTable.tableFooterView = msgsseenfhidefooterview()
                                oppositeSeenStatus = true
                                toggle = false
                            }
                            return cell!
                        }
                    }
                    else  if userNumberKey == "\(phoneid)chatPhoto" {
                        if txtChat as! String != "" {
                            
                            let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderImageChatCell") as? SenderImageChatCell
                            cell?.senderImageComment.text = chatText?["\(phoneid)text"] as? String
                            let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.imageTappSenderReceiver))
                            cell?.viewC.addGestureRecognizer(tapGesture)
                            cell?.viewC.tag = indexPath.row
                            if groupK == "yes" {
//                                cell?.senderNumber.text = "You"
                            }
                            let url = URL(string: txtChat  as! String)
                            cell?.senderImage.kf.setImage(with: url)
                            cell?.selectionStyle = .none
                            if indexPath.row == chatMapKey.count-1 {
                                toggle = true
                            }
                            return cell!
                        }
                    }else {
                        if txtChat as! String != "" {
                            let cell = chatTable.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as? ImageTableViewCell
                            let url = URL(string: txtChat as! String)
                            let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.imageTappSenderReceiver))
                            cell?.viewC.addGestureRecognizer(tapGesture)
                            cell?.viewC.tag = indexPath.row
                            cell?.photos.kf.setImage(with: url)
                            if groupK == "yes" {
                                cell?.receiverNumber.text = "\(userNumberKey.replacingOccurrences(of: "chatPhoto", with: ""))"
//                                if nameString != "" {
//                                    cell?.receiverNumber.text = "\(nameString)"
//                                }
                                _ = allUserOfContact.filter { user in
                                    let str = user["Phone number"]
                                    
                                    if "\(userNumberKey.replacingOccurrences(of: "chatPhoto", with: ""))" == str {
                                        nameString = user["Name"]!
    //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                        if user["Name"] != ""  {
                                            print("Yes ")
                                            cell?.receiverNumber.text = "\(nameString)"
                                        }
                                    }
                                    return true
                                }
                            }
                            cell?.selectionStyle = .none
                            if indexPath.row == chatMapKey.count-1 {
                                if oppositeSeenStatus == false {
                                    chatTable.tableFooterView = msgsseenfhidefooterview()
                                    oppositeSeenStatus = true
                                    toggle = false
                                }
                            }
                            return cell!
                        }
                    }
                    
                } else if userNumberKey == "\(phoneid)chatVideo" || userNumberKey == "\(receiverid)chatVideo" || (userNumberKey == receiverid && forfolk == true) {
                    print("video is colled")
                    if userNumberKey == "\(receiverid)chatVideo" || (userNumberKey == receiverid && forfolk == true){
                        if txtChat as! String != "" {
//                            print("\(txtChat)")
                            let cell = chatTable.dequeueReusableCell(withIdentifier: "ReceiverVideoCell") as? ReceiverVideoCell
                            cell?.confi(videoUrl: txtChat  as! String)
                            let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.videoTappSenderReceiver))
                            cell?.viewC.addGestureRecognizer(tapGesture)
                            cell?.viewC.tag = indexPath.row
                            if groupK == "yes" {
                                cell?.receiverNumber.text = "\(userNumberKey.replacingOccurrences(of: "chatVideo", with: ""))"
//                                if nameString != "" {
//                                    cell?.receiverNumber.text = "\(nameString)"
//                                }
                                _ = allUserOfContact.filter { user in
                                    let str = user["Phone number"]
                                    
                                    if "\(userNumberKey.replacingOccurrences(of: "chatVideo", with: ""))" == str {
                                        nameString = user["Name"]!
    //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                        if user["Name"] != ""  {
//                                            print("Yes ")
                                            cell?.receiverNumber.text = "\(nameString)"
                                        }
                                    }
                                    return true
                                }
                            }
                            cell?.selectionStyle = .none
                            if indexPath.row == chatMapKey.count-1 {
                                if oppositeSeenStatus == false {
                                    chatTable.tableFooterView = msgsseenfhidefooterview()
                                    oppositeSeenStatus = true
                                    toggle = false
                                }
                            }
                            return cell!
                        }
                    }
                    else  if userNumberKey == "\(phoneid)chatVideo" {
                        print("Ok my video")
                        if txtChat as! String != "" {
                            //                        print("MY VIDEO URL IS -------\(txtChat)")
                            let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderVideoCell") as? SenderVideoCell
                            cell?.confi(videoUrl: txtChat  as! String)
                            let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.videoTappSenderReceiver))
                            cell?.viewC.addGestureRecognizer(tapGesture)
                            cell?.viewC.tag = indexPath.row
                            cell?.viewC.isUserInteractionEnabled = true
                            if groupK == "yes" {
//                                cell?.senderNumber.text = "You"
                            }
                            cell?.selectionStyle = .none
                            if indexPath.row == chatMapKey.count-1 {
                                toggle = true
                            }
                            return cell!
                        }
                    }else {
                        if txtChat as! String != "" {
                            let cell = chatTable.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as? ImageTableViewCell
                            let url = URL(string: txtChat  as! String)
                            cell?.photos.kf.setImage(with: url)
                            if groupK == "yes" {
                                cell?.receiverNumber.text = "\(userNumberKey.replacingOccurrences(of: "chatVideo", with: ""))"
//                                if nameString != "" {
//                                    cell?.receiverNumber.text = "\(nameString)"
//                                }
                                _ = allUserOfContact.filter { user in
                                    let str = user["Phone number"]
                                    
                                    if "\(userNumberKey.replacingOccurrences(of: "chatVideo", with: ""))" == str {
                                        nameString = user["Name"]!
    //                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                        if user["Name"] != ""  {
//                                            print("Yes ")
                                            cell?.receiverNumber.text = "\(nameString)"
                                        }
                                    }
                                    return true
                                }
                            }
                            cell?.selectionStyle = .none
                            if indexPath.row == chatMapKey.count-1 {
                                if oppositeSeenStatus == false {
                                    chatTable.tableFooterView = msgsseenfhidefooterview()
                                    oppositeSeenStatus = true
                                    toggle = false
                                }
                            }
                            
                            return cell!
                        }
                    }
                }
                else {
                    if phoneid == userNumberKey || "\(phoneid)text" == userNumberKey {
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderViewCell", for: indexPath) as? SenderViewCell
                        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.messageTapp))
                        cell?.viewC.addGestureRecognizer(tapGesture)
                        cell?.viewC.tag = indexPath.row
                        cell?.senderMessage.text = "\(txtChat!)"
                        cell?.selectionStyle = .none
                        if groupK == "yes" {
//                            cell?.senderNumber.text = "You"
                        }
                        if indexPath.row == chatMapKey.count-1 {
                            toggle = true
                        }
//
                        return cell!
                    }
                    else {
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "ReceiverViewCell", for: indexPath) as? ReceiverViewCell
                        cell?.receiverMessages.text = "\(txtChat!)"
                        cell?.selectionStyle = .none
                        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(ChatConversionCode.messageTapp))
                        cell?.viewC.addGestureRecognizer(tapGesture)
                        cell?.viewC.tag = indexPath.row
                        if groupK == "yes" {
                            cell?.receiverNumber.text = "\(userNumberKey)"
                            _ = allUserOfContact.filter {user in
                                let str = user["Phone number"]
                                print("Reciever user \(str)")
                                if userNumberKey == str {
                                    nameString = user["Name"]!
                                    print("yesyesyesyesyesyesyesyesyes \(nameString) --- \(userNumberKey)")
                                    if user["Name"] != ""  {
//                                        print("Yes ")
                                        cell?.receiverNumber.text = "\(nameString)"
                                    }
                                }
                                return true
                            }
                        }
                        if indexPath.row == chatMapKey.count-1 {
                            if oppositeSeenStatus == false {
                                chatTable.tableFooterView = msgsseenfhidefooterview()
                                oppositeSeenStatus = true
                                toggle = false
                            }
                        }
                        return cell!
                    }
                }
            }
        }
        let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderViewCell", for: indexPath) as? SenderViewCell
        cell?.selectionStyle = .none
        return cell!
    }
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        guard let indexPath = configuration.identifier as? IndexPath else {
            return nil
        }
        let chat = chatMap[indexPath.row]
        let userNumberKey = chatMapKey[indexPath.row]
        let uniqueKey = key[indexPath.row]
        let chatText = chat[uniqueKey]
        let txtChat = chatText?[userNumberKey]
        let abc = chatText?[userNumberKey]  as? [String : Any]
        print("txtChat \(txtChat)  UserNumberKay - \(userNumberKey) | UniqueKey - \(uniqueKey)")
        print("Chattext \(chatText)")
        if let cell = chatTable.cellForRow(at: indexPath) as? SenderViewCell {
            forwardChat = ""
            forwardChatPhoto = ""
            forwardChatVideo = ""
            forwardChatKey = ""
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            forwardChat = "\(txtChat ?? "")"
            forwardChatKey = "\(phones)"
            forwardCell = "SenderViewCell"
            print("SenderViewCell ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) |  ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey)")
            
        return UITargetedPreview(view: cell.viewC, parameters: parameters)
        }
        if let cell = chatTable.cellForRow(at: indexPath) as? SenderImageChatCell {
            forwardChat = ""
            forwardChatPhoto = ""
            forwardChatVideo = ""
            forwardChatKey = ""
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            forwardChat = "\(chatText?["\(userNumberKey.replacingOccurrences(of: "chatPhoto", with: "text"))"] ?? "")"
            forwardChatPhoto = "\(chatText?["\(userNumberKey)"] ?? "")"
            let url = URL(string: forwardChatPhoto)
            uiimage.kf.setImage(with: url)
            forwardChatKey = "\(phones)"
            forwardCell = "SenderImageChatCell"
            print("SenderImageChatCell ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) |  ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey)")
            return UITargetedPreview(view: cell.viewC, parameters: parameters)
        }
        if let cell = chatTable.cellForRow(at: indexPath) as? SenderReplyImageCell {
            forwardChat = ""
            forwardChatPhoto = ""
            forwardChatVideo = ""
            forwardChatKey = ""
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            forwardChat = "\(chatText?["\(phones)"] ?? "")"
            forwardChatKey = "\(phones)"
            forwardCell = "SenderReplyImageCell"
            print("SenderReplyImageCell ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) |  ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey)")
        return UITargetedPreview(view: cell.viewC, parameters: parameters)
        }
        if let cell = chatTable.cellForRow(at: indexPath) as? SenderVideoCell {
            forwardChat = ""
            forwardChatPhoto = ""
            forwardChatVideo = ""
            forwardChatKey = ""
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            forwardChatVideo = "\(chatText?["\(userNumberKey)"] ?? "")"
            forwardChatKey = phones
            print("SenderVideoCell  ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) |  ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey)")
        return UITargetedPreview(view: cell.viewC, parameters: parameters)
        }
        if let cell = chatTable.cellForRow(at: indexPath) as? ReceiverViewCell {
            forwardChat = ""
            forwardChatPhoto = ""
            forwardChatVideo = ""
            forwardChatKey = ""
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            if groupK == "yes" {
                let checking = mid.split(separator: "+")
                for i in  0...checking.count-1 {
                    if chatText?["+\(checking[i])"] != nil {
                        print("OKOKKOOOOK")
                        forwardChat = "\(chatText?["+\(checking[i])"] ?? "")"
                        forwardChatKey = "\(phones)"
                        break
                    }
                }
            } else {
                forwardChat = "\(chatText?["\(receiverUserid)"] ?? "")"
                forwardChatKey = "\(phones)"
                
            }
            print("ReceiverViewCell ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) |  ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey)")
        return UITargetedPreview(view: cell.viewC, parameters: parameters)
        }
        if let cell = chatTable.cellForRow(at: indexPath) as? ReceiverReplyViewCell {
            forwardChat = ""
            forwardChatPhoto = ""
            forwardChatVideo = ""
            forwardChatKey = ""
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            if groupK == "yes" {
                let checking = mid.split(separator: "+")
                for i in  0...checking.count-1 {
                    if chatText?["+\(checking[i])"] != nil {
                        print("OKOKKOOOOK")
                        forwardChat = "\(chatText?["+\(checking[i])"] ?? "")"
                        forwardChatKey = "\(phones)"
                        break
                    }
                }
            } else {
                forwardChat = "\(chatText?["\(receiverUserid)"] ?? "")"
                forwardChatKey = "\(phones)"
                
            }
            print("ReceiverReplyViewCell ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) |  ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey)")
        return UITargetedPreview(view: cell.viewC, parameters: parameters)
        }
        if let cell = chatTable.cellForRow(at: indexPath) as? ReceiverVideoCell {
            forwardChat = ""
            forwardChatPhoto = ""
            forwardChatVideo = ""
            forwardChatKey = ""
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            if groupK == "yes" {
                let checking = mid.split(separator: "+")
                for i in  0...checking.count-1 {
                    if chatText?["+\(checking[i])"] != nil {
                        print("OKOKKOOOOK")
                        forwardChatVideo = "\(chatText?["+\(checking[i])chatVideo"] ?? "")"
                        forwardChatKey = "\(phones)"
                        break
                    }
                }
            } else {
                forwardChatVideo = "\(chatText?["\(receiverUserid)"] ?? "")"
                forwardChatKey = "\(phones)"
                
            }
            print("ReceiverVideoCell  ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) |  ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey)")
        return UITargetedPreview(view: cell.viewC, parameters: parameters)
        }
        if let cell = chatTable.cellForRow(at: indexPath) as? ReceiverReplyImageCell {
            forwardChat = ""
            forwardChatPhoto = ""
            forwardChatVideo = ""
            forwardChatKey = ""
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            if groupK == "yes" {
                let checking = mid.split(separator: "+")
                for i in  0...checking.count-1 {
                    if chatText?["+\(checking[i])"] != nil {
                        print("OKOKKOOOOK")
                        forwardChat = "\(chatText?["+\(checking[i])"] ?? "")"
                        forwardChatKey = "\(phones)"
                        break
                    }
                }
            } else {
                forwardChat = "\(chatText?["\(receiverUserid)"] ?? "")"
                forwardChatKey = "\(phones)"
                
            }
            forwardCell = "ReceiverReplyImageCell"
            print("ReceiverReplyImageCell ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) |  ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey)")
        return UITargetedPreview(view: cell.viewC, parameters: parameters)
        }
        if let cell = chatTable.cellForRow(at: indexPath) as? SenderReplyViewCell {
            forwardChat = ""
            forwardChatPhoto = ""
            forwardChatVideo = ""
            forwardChatKey = ""
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            forwardChat = "\(chatText?["\(phones)"] ?? "")"
            forwardChatKey = "\(phones)"
            print("SenderReplyViewCell  ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) | ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey) ")
            return UITargetedPreview(view: cell.viewC, parameters: parameters)
        } else {
            
            let cell = chatTable.cellForRow(at: indexPath) as? ImageTableViewCell
            forwardChat = ""
            forwardChatPhoto = ""
            forwardChatVideo = ""
            forwardChatKey = ""
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            if groupK == "yes" {
                let checking = mid.split(separator: "+")
                for i in  0...checking.count-1 {
                    if chatText?["+\(checking[i])chatPhoto"] != nil || chatText?["+\(checking[i])text"] != nil {
                        print("OKOKKOOOOK")
                        forwardChat = "\(chatText?["+\(checking[i])text"] ?? "")"
                        forwardChatPhoto = "\(chatText?["+\(checking[i])chatPhoto"] ?? "")"
                        let url = URL(string: forwardChatPhoto)
                        uiimage.kf.setImage(with: url)
                        //                        forwardChat = "\(chatText?["+\(checking[i])"] ?? "")"
                        forwardChatKey = "\(phones)"
                        break
                    }
                }
            } else {
                forwardChat = "\(chatText?["\(receiverUserid)text"] ?? "")"
                forwardChatPhoto = "\(chatText?["\(receiverUserid)chatPhoto"] ?? "")"
                let url = URL(string: forwardChatPhoto)
                uiimage.kf.setImage(with: url)
                //                forwardChat = "\(chatText?["\(receiverUserid)"] ?? "")"
                forwardChatKey = "\(phones)"
                
            }
            print("ImageTableViewCell  ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) |  ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey)")
            return UITargetedPreview(view: cell!.viewC, parameters: parameters)
        }
        
    }
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let chat = chatMap[indexPath.row]
        let userNumberKey = chatMapKey[indexPath.row]
        let uniqueKey = key[indexPath.row]
        let chatText = chat[uniqueKey]
        let txtChat = chatText?[userNumberKey]
        let abc = chatText?[userNumberKey]  as? [String : Any]
        // Selected Drug and notes
        var titleString = "\(uniqueKey)"
        print("key", titleString)
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            return UIMenu(title: "", children: [
                UIAction(title: "Save", image: UIImage(systemName: "square.and.arrow.down")) { [self] action in
                    if forwardChatVideo != "" {
                        DispatchQueue.global(qos: .background).async {
                            if let url = URL(string: forwardChatVideo), let urIData = NSData(contentsOf: url) {
                                let documentsPath=NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                                      .userDomainMask, true)[0];
                                let filePath="\(documentsPath)/\(UUID().uuidString).MOV"
                                DispatchQueue.main.async{
                                    urIData.write(toFile: filePath, atomically: true)
                                    PHPhotoLibrary.shared().performChanges({
                                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:URL(
                                            fileURLWithPath: filePath))
                                    }) { completed, error in
                                        if completed {
                                            print("Video is saved!")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if forwardChatPhoto != "" {
                        
                        UIImageWriteToSavedPhotosAlbum(uiimage.image!, self, #selector(image(_:withPotentialError:contextInfo:)), nil)
                    }
                },
                UIAction(title: "Forward",
                         image: UIImage(systemName: "arrowshape.turn.up.right")) { action in
                             // Perform action
                             let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsCodeForward") as? UserDetailsCodeForward
                             print("users ",self.usersDetails)
                             vc?.usersDetails = self.usersLists
                             vc?.allUserOfContact = self.allUserOfContact
                             vc?.phones = self.phones
                             vc?.msgIdList = self.msgIdList
                             vc?.uid = self.ui
                             vc?.forwardChat = self.forwardChat
                             vc?.forwardChatVideo = self.forwardChatVideo
                             vc?.forwardChatPhoto = self.forwardChatPhoto
                             vc?.forwardChatKey = self.forwardChatKey
                             
                             self.navigationController?.present(vc!, animated: true, completion: nil)
                         },
                UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                    print("Delete")
                    let ref = Database.database().reference().child("Chats").child("\(self.mid)").child("chatting").child("\(uniqueKey)")
                    
                    ref.setValue(nil)
                    self.chatMap.remove(at: indexPath.row)
                    self.chatMapKey.remove(at: indexPath.row)
                    self.key.remove(at: indexPath.row)
                    //                        self.data.remove(at: indexPath.row)
                    self.chatTable.deleteRows(at: [indexPath], with: .automatic)
                    self.chatTable.reloadData()
                }
            ])
        }
    }

    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
     func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
         guard let indexPath = configuration.identifier as? IndexPath, let cell = chatTable.cellForRow(at: indexPath) as? SenderViewCell else {
             return nil
         }
         
         let parameters = UIPreviewParameters()
         parameters.backgroundColor = .clear
         
     return UITargetedPreview(view: cell.viewC, parameters: parameters)
    }
  

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let chat = chatMap[indexPath.row]
        let userNumberKey = chatMapKey[indexPath.row]
        let uniqueKey = key[indexPath.row]
        let myyo = chat[uniqueKey]
        let txtChat = myyo?[userNumberKey] as? String
        let abc = myyo?[userNumberKey]  as? [String : Any]
        replyChat = myyo as? [String : String]
        replyText = uniqueKey
          print("receiver message is \(myyo?["\(receiverid)"])")
          print("Sender  message is \(myyo?["\(phoneid)"])")
          print("MYYO  is the ----  \(myyo)")
          print("ABC IS THE ====  \(abc)")
          print("TEXTCHAT IS ///////    \(txtChat)")
          print("userNumberKey IS THE \\\\\\  \(userNumberKey)---\(receiverid)")
        oppositeSeenStatus = true
        lcb = false
        chatTable.tableFooterView = msgsseenfhidefooterview()
        if abc?["\(phoneid)"] != nil || abc?["\(receiverid)"] != nil  {
            print("reply chat photo") // || myyo?["\(phoneid)"] != nil || myyo?["\(receiverid)"] != nil
            if myyo?["\(phoneid)"] == nil {
                //                print("Phone ID chat === \(myyo?["\(phoneid)"])")
                var msg = ""
                if myyo!["\(self.receiverid)"] == nil {
                    replyChat = ["\(self.receiverid)" : "\(myyo!["\(self.phoneid)"]!)"]
                    msg = "\(myyo!["\(self.phoneid)"]!)"
                } else {
                    replyChat = ["\(self.receiverid)" : "\(myyo!["\(self.receiverid)"]!)"]
                    msg = "\(myyo!["\(self.receiverid)"]!)"
                }
                replyText = uniqueKey
                let action = UIContextualAction(style: .normal,
                                                title: "􀉎") { [weak self] (action, view, completionHandler) in
                    self?.handleMarkAsFavourite(chats: msg , user: self!.receiverid)
                    completionHandler(true)
                }
                action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                return UISwipeActionsConfiguration(actions: [action])
            } else {
                //                print("Obviously")
                var msg = ""
                if myyo!["\(self.phoneid)"] == nil {
                    replyChat = ["\(self.phoneid)" : "\(myyo!["\(self.receiverid)"]!)"]
                    msg = myyo!["\(self.receiverid)"] as! String
                } else {
                    replyChat = ["\(self.phoneid)" : "\(myyo!["\(self.phoneid)"]!)"]
                    msg = myyo!["\(self.phoneid)"] as! String
                }
                replyText = uniqueKey
                let action = UIContextualAction(style: .normal,
                                                title: "􀉎") { [weak self] (action, view, completionHandler) in
                    self?.handleMarkAsFavourite(chats: msg , user: self!.phoneid)
                    completionHandler(true)
                }
                action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                return UISwipeActionsConfiguration(actions: [action])
            }
        } else {
            if userNumberKey == "\(phoneid)chatPhoto" || userNumberKey == "\(receiverid)chatPhoto" || userNumberKey.contains("chatPhoto"){
                print("my chat photo, \(userNumberKey)------chat \(replyChat)===")
                if userNumberKey == "\(phoneid)chatPhoto" {
                    
                    if replyChat?["\(phoneid)text"] == nil{
                        print("my photo")
                        let action = UIContextualAction(style: .normal,
                                                        title: "􀉎") { [weak self] (action, view, completionHandler) in
                            self?.replyforPhotos(chats: "Photo" , user:userNumberKey.replacingOccurrences(of: "chatPhoto", with: "") ,photourl: txtChat ?? "")
                            completionHandler(true)
                        }
                        action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                        return UISwipeActionsConfiguration(actions: [action])
                    } else {
                        print("my  IOIOIOIOIOIOIs")
                        let action = UIContextualAction(style: .normal,
                                                        title: "􀉎") { [weak self] (action, view, completionHandler) in
                            self?.replyforPhotos(chats: self?.replyChat?["\(self!.phoneid)text"] ?? "" , user:userNumberKey.replacingOccurrences(of: "chatPhoto", with: "") ,photourl: txtChat ?? "")
                            completionHandler(true)
                        }
                        action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                        return UISwipeActionsConfiguration(actions: [action])
                    }
                } else {
                    if replyChat?["\(receiverid)text"] == nil  {
                        print("rec photo")
                        let action = UIContextualAction(style: .normal,
                                                        title: "􀉎") { [weak self] (action, view, completionHandler) in
                            self?.replyforPhotos(chats: "" , user:userNumberKey.replacingOccurrences(of: "chatPhoto", with: "") ,photourl: txtChat ?? "")
                            completionHandler(true)
                        }
                        action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                        return UISwipeActionsConfiguration(actions: [action])
                    } else {
                        print("rec  IOIOIOIOIOIOIs")
                        let action = UIContextualAction(style: .normal,
                                                        title: "􀉎") { [weak self] (action, view, completionHandler) in
                            self?.replyforPhotos(chats: self?.replyChat?["\(self!.receiverid)text"] ?? "" , user:userNumberKey.replacingOccurrences(of: "chatPhoto", with: "") ,photourl: txtChat ?? "")
                            completionHandler(true)
                        }
                        action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                        return UISwipeActionsConfiguration(actions: [action])
                    }
                }
            }else if userNumberKey == "\(phoneid)chatVideo" || userNumberKey == "\(receiverid)chatVideo" || userNumberKey.contains("chatVideo") {
                print("My video")
                if  userNumberKey == "\(phoneid)chatVideo" {
                    
                    if replyChat?["\(phoneid)text"] == nil{
                        print("my videp")
                        let action = UIContextualAction(style: .normal,
                                                        title: "􀉎") { [weak self] (action, view, completionHandler) in
                            
                            self?.replyforVideo(chats: "Video" , user:userNumberKey.replacingOccurrences(of: "chatVideo", with: "") ,photourl: txtChat ?? "")
                            
                            completionHandler(true)
                        }
                        action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                        return UISwipeActionsConfiguration(actions: [action])
                    } else {
                        print("my IOIOIOIOIOIOIs")
                        let action = UIContextualAction(style: .normal,
                                                        title: "􀉎") { [weak self] (action, view, completionHandler) in
                            
                            self?.replyforVideo(chats: self?.replyChat?["\(self!.phoneid)text"] ?? "" , user:userNumberKey.replacingOccurrences(of: "chatVideo", with: "") ,photourl: txtChat ?? "")
                            
                            completionHandler(true)
                        }
                        action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                        return UISwipeActionsConfiguration(actions: [action])
                    }
                    
                }else {
                    if replyChat?["\(receiverid)text"] == nil || userNumberKey == "\(receiverid)chatVideo" {
                        print("rec video")
                        let action = UIContextualAction(style: .normal,
                                                        title: "􀉎") { [weak self] (action, view, completionHandler) in
                            
                            self?.replyforVideo(chats: "Video" , user:userNumberKey.replacingOccurrences(of: "chatVideo", with: "") ,photourl: txtChat ?? "")
                            
                            completionHandler(true)
                        }
                        action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                        return UISwipeActionsConfiguration(actions: [action])
                    } else {
                        print("recc vid IOIOIOIOIOIOIs")
                        let action = UIContextualAction(style: .normal,
                                                        title: "􀉎") { [weak self] (action, view, completionHandler) in
                            
                            self?.replyforVideo(chats: self?.replyChat?["\(self!.receiverid)text"] ?? "" , user:userNumberKey.replacingOccurrences(of: "chatVideo", with: "") ,photourl: txtChat ?? "")
                            
                            completionHandler(true)
                        }
                        action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                        return UISwipeActionsConfiguration(actions: [action])
                    }
                }
            }
            else {
                print("New ")
                let action = UIContextualAction(style: .normal,
                                                title: "􀉎") { [weak self] (action, view, completionHandler) in
                    
                    self?.handleMarkAsFavourite(chats: txtChat ?? "" , user:userNumberKey)
                    
                    completionHandler(true)
                }
                action.backgroundColor = UIColor(displayP3Red: 10, green: 5, blue: 15, alpha: 0)
                return UISwipeActionsConfiguration(actions: [action])
            }
            
        }
        
        
    }
    
    func replyforPhotos(chats:String, user: String,photourl:String){
        keyBoardStatus = false
        chatField.becomeFirstResponder()
        chatTable.tableFooterView = imgReplyFooterView()
        scrollToBottom()
        replyUser?.text = "\(user)"
        replytxt?.text = "\(chats)"
        if chats == "" {
            replytxt?.text = "Photo"
        }
        let url = URL(string: photourl  )
        replyImageView.kf.setImage(with: url)
    }
    func replyforVideo(chats:String, user: String,photourl:String){
        keyBoardStatus = false
        chatField.becomeFirstResponder()
        chatTable.tableFooterView = imgReplyFooterView()
        scrollToBottom()
        replyUser?.text = "\(user)"
        replytxt?.text = "\(chats)"
        if chats == "" {
            replytxt?.text = "Video"
        }
        let url = URL(string: photourl)
        replyImageView.kf.setImage(with: AVAssetImageDataProvider(assetURL: url!, seconds: 1))
    }
    func handleMarkAsFavourite(chats:String, user: String) {
        keyBoardStatus = false
        chatField.becomeFirstResponder()
        chatTable.tableFooterView = footerview()
        scrollToBottom()
        
        replyUser?.text = "\(user)"
        replytxt?.text = "\(chats)"
        
    }
    func scrollToBottom() {
        let footerBounds = chatTable.tableFooterView?.bounds
        let footerRectInTable = chatTable.convert(footerBounds!, from: chatTable.tableFooterView!)
        chatTable.scrollRectToVisible(footerRectInTable, animated: true)
    }
    
    // MARK: - Video Player Controller
    func videoPlayer(videoUrl:String) {
        print("Tapped....\(videoUrl)")
        let Url = URL(string: videoUrl)
        let player = AVPlayer(url: Url!)
        let playerController = AVPlayerViewController()
        playerController.player = player
        //        let playerLayer =  AVPlayerLayer(player: player)
        //        playerLayer.frame = self.view.frame
        //        playerLayer.videoGravity = .resizeAspect
        //        self.view.layer.addSublayer(playerLayer)
        player.play()
        self.present(playerController, animated: true)
    }
    
    // MARK: - Image  Controller
    func imageShow(url:String) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageVc") as? ImageVc
        vc?.str = url
        present(vc!, animated: true)
    }
    
}

//  MARK: - FooterView
extension ChatConversionCode {
    
    private func imgReplyFooterView() -> UIView{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: chatTable.frame.width, height: 60))
        replyUser = UILabel(frame: CGRect(x: 10, y: 0, width: chatTable.frame.width-150, height: 30))
        replytxt = UILabel(frame: CGRect(x: 20, y: 25, width: chatTable.frame.width-150, height: 20))
        replyImageView = UIImageView(frame: CGRect(x: chatTable.frame.width-80, y: 0, width: 50, height: 60))
        replyImageView.backgroundColor = .brown
        let closebtn = UIButton()
        closebtn.setImage(UIImage(systemName: "clear"), for: .normal)
        closebtn.tintColor = .black
        closebtn.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        closebtn.frame = CGRect(x: chatTable.bounds.width - 40, y: 0, width: 50, height: 50)
        view.backgroundColor = .darkGray
        view.addSubview(replyImageView)
        view.addSubview(replyUser!)
        view.addSubview(replytxt!)
        view.addSubview(closebtn)
        return view
    }
    
    //  MARK: - FooterView For Replying Chats
    private func footerview() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: chatTable.frame.width, height: 50))
        replyUser = UILabel(frame: CGRect(x: 10, y: 0, width: chatTable.frame.width-60, height: 30))
        replytxt = UILabel(frame: CGRect(x: 20, y: 25, width: chatTable.frame.width-60, height: 20))
        
        let closebtn = UIButton()
        closebtn.setImage(UIImage(systemName: "clear"), for: .normal)
        closebtn.tintColor = .black
        closebtn.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        closebtn.frame = CGRect(x: chatTable.bounds.width - 40, y: 0, width: 50, height: 50)
        view.backgroundColor = .darkGray
        view.addSubview(replyUser!)
        view.addSubview(replytxt!)
        view.addSubview(closebtn)
        
        
        return view
    }
    
    @objc func pressed(sender: UIButton!) {
        chatTable.tableFooterView = hidefooterview()
        chatTable.bounces = true
        replyChat?.removeAll()
        oppositeSeenStatus = false
        lcb = false
    }
    private func hidefooterview() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: chatTable.frame.width, height: 0))
        let indexPath = IndexPath(item: chatMapKey.count-1, section: 0)
        chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
        return view
    }
    
    //  MARK: - FooterView For Seen, Delivered Status
    private func msgsSeenfooterview() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: chatTable.frame.width, height: 30))
        let seeninmsg = UILabel(frame: CGRect(x: chatTable.frame.width-82, y: 0, width: 80, height: 20))
        seeninmsg.textAlignment = .right
        seeninmsg.font = UIFont.systemFont(ofSize: 14)
        seeninmsg.text = seenStatusLabel
        seeninmsg.textColor = .black
        view.backgroundColor = .none
        view.addSubview(seeninmsg)
        return view
    }
    private func msgsseenfhidefooterview() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: chatTable.frame.width, height: 0))
        
        return view
    }
}

// MARK: - Loading Progress Indicator
extension ChatConversionCode {
    func mbProgressHUD(text: String){
        DispatchQueue.main.async {
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHUD.label.text = text
            progressHUD.contentColor = .systemBlue
        }
    }
    func hideProgress() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: false)
        }
    }
}


