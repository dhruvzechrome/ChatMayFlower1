
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

class ChatConversionCode: UIViewController ,UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    var bo = false
    var llb = 0
    @IBOutlet weak var bkview: UIView!
    var keyboardheight : Int = 0
    @IBOutlet weak var backgroundSV: UIScrollView!
    var cu = ""
    private let database = Database.database().reference()
    var phoneid = ""
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var chatField: UITextField!
    var ui = 0
    var chat = [Message]()
    var mid = ""
    var receiverid = ""
    var friends = [Message]()
    var id: Int?
    //    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var titl: UINavigationItem!
    var timer = Timer()
    var dictArray: [[String:String]] = []
    var array = [String]()
    var keyBoardStatus = false
    func getdata() {
        database.child("Uid").getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return;
            }
            let userName = snapshot?.value;
            
            self.ui = userName as! Int
            //            print(self.ui)
        });
        
        
    }
    var srtttt = [[String:[String:String]]]()
    var key = [String]()
    func getchat() {
        print("my array is this ",array)
        print("my dic array is this ",srtttt)
        print("Message id is " ,  mid)
        
        database.child("Chats").child(mid).child("chatting").observe(.childAdded) {[weak self](snapshot) in
            DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                guard let value = snapshot.value as? [String:Any] else {return
                    print("Error")
                }
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    for snap in snapshots {
                        //                        print("snap shot is ",snapshot.value)
                        
                        
                        let cata = snap.key
                        let ques = snap.value!
                        print("Cata ---------- \(cata)")
                        print("Ques >>>>---------- \(ques)")
                        self?.srtttt.append([snapshot.key :[cata : "\(ques)"]])
                        self?.key.append(snapshot.key)
                        self?.array.append("\(cata)")
                        self?.chatTable.reloadData()
                        self?.bo = true
                    }
                    
                }
                
                
                
                if self?.array.count != 0 {
                    //                    DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    //                        let indexPath = IndexPath(item: array.count-1, section: 0)
                    //                        chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    //
                    //                    }
                    
                    //
                    print("my srtttttttt array is this @@@@@###$$$%%^^&& ",self?.srtttt)
                    print("my array is this ",self?.array)
                    print("my array is this ",self?.array.count)
                    print("my dic array is this ",self?.srtttt.count)
                }
                
            }
        }
    }
    
    @IBAction func sendChat(_ sender: UIButton) {
        
        if chatField.text != "" {
            ui = ui + 1
            database.child("Uid").setValue(ui)
            database.child("Chats").child(mid).child("chatting").child("\(ui)").setValue(["\(cu)": chatField.text!], withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Failed to write data")
                    
                    return
                }
                print("data written seccess")
            })
            //            DataBaseManager.shared.mychatting(with: Message(messagid: mid, chats: chatField.text!, sender: "ul", uii: ui, chatPhotos: ""))
            chatField.text = ""
            DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                chatTable.reloadData()
                let indexPath = IndexPath(item: array.count-1, section: 0)
                chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
                
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getdata()
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [self] in
        //            print("my array is this----------------====== ",array)
        //            print("my dic array is this ",srtttt)
        //            print("my array is this ",array.count)
        //            print("my dic array is this ",srtttt.count)
        //        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
            if bo == true {
                let indexPath = IndexPath(item: array.count-1, section: 0)
                chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
                llb = ui
                bo = false
            }
            else {
                hideProgress()
            }
        })
        tabBarController?.tabBar.isHidden = true
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cu = (FirebaseAuth.Auth.auth().currentUser?.phoneNumber)!
        
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTable.delegate = self
        chatTable.dataSource = self
        keyboardheight = 0
        getchat()
        mbProgressHUD(text: "Loading")
        
        cu = (FirebaseAuth.Auth.auth().currentUser?.phoneNumber)!
        titl.title = receiverid
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        //        addImageVideo.addGestureRecognizer(tapGesture)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func addImageVideo(_ sender: UIButton) {
        imageTapped()
        
    }
    @objc
    func imageTapped()
    {
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
    var filename : String?
    var didselectedImage : UIImage?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let  videoURL = info[.mediaURL] as? URL
        {
            let localFile = URL(string: "\(videoURL)")!
            print("Video Url is -=-=-=-=-=-=-=-==-=-= \(videoURL)")
            //            let asset = AVURLAsset(url: videoURL,options: nil)
            //            let imgGenerator = AVAssetImageGenerator(asset: asset)
            //            imgGenerator.appliesPreferredTrackTransform = true
            mbProgressHUD(text: "")
            //            let cgImage = try  imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            //                let thumbnail = UIImage(cgImage: cgImage)
            //                print("asset -----===== \(asset)")
            //                print("cgImage  ======= \(cgImage)")
            //                print("thumbnail ========= \(thumbnail)")
            keyboardheight = 0
            let storageRef = Storage.storage().reference()
            let filename = "chatVideo/\(UUID().uuidString).MOV"
            let fileRef = storageRef.child(filename)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                let uploadTask = fileRef.putFile(from: localFile, metadata: nil){metadata, error in
                    var urlpth = ""
                    if error == nil && metadata != nil {
                        fileRef.downloadURL(completion: {(url,error) in
                            if error == nil {
                                urlpth = "\(url!)"
                                self.ui = self.ui + 1
                                self.database.child("Uid").setValue(self.ui)
                                self.database.child("Chats").child(self.mid).child("chatting").child("\(self.ui)").setValue(["\(self.phoneid)chatVideo": urlpth], withCompletionBlock: { error, _ in
                                    guard error == nil else {
                                        print("Failed to write data")
                                        
                                        return
                                    }
                                    print("data written seccess")
                                    
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
                        print("Metadata is >>>>>>>>>>>>> \(metadata)")
                    }
                }
            }
            
            
            
        } else {
            print("*** Error generating thumbnail: ")
        }
        
        
        if let selectedImage =  info[.originalImage] as? UIImage{
            print("Selected image ",selectedImage)
            //            add.image = selectedImage
            didselectedImage = selectedImage
            let localPath = info[.imageURL] as? NSURL
            _ = info[.imageURL] as? URL
            print("Local Path  > ",localPath!)
            
            picker.dismiss(animated: true, completion: nil)
            keyboardheight = 0
            let imgVc = storyboard?.instantiateViewController(withIdentifier: "ImageAndVideoShowCode") as? ImageAndVideoShowCode
            imgVc?.navselectedImage = didselectedImage
            imgVc?.mesId = mid
            imgVc?.uid = ui
            self.show(imgVc!, sender: self)
            
        }
        else{
            print("Image not found...!")
        }
        
    }
    
}
extension ChatConversionCode {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    @objc func keyboardWillShow(sender: NSNotification) {
        
        if keyBoardStatus == false {
            if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                //let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                view.frame.size = CGSize(width: view.bounds.width, height: view.frame.height - keyboardSize.height)
                bkview.frame.size = CGSize(width: bkview.bounds.width, height: bkview.frame.height - keyboardSize.height)
                keyboardheight = Int(keyboardSize.height)
                chatTable.frame.size = CGSize(width: chatTable.frame.width, height: chatTable.frame.height - keyboardSize.height)
                backgroundSV.frame.size = CGSize(width: backgroundSV.bounds.width, height: backgroundSV.frame.height - keyboardSize.height)
                //               print("asdasd" , keyboardheight)
            }
            let indexPath = IndexPath(item: array.count-1, section: 0)
            chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
            keyBoardStatus = true
        }
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if keyBoardStatus  == true{
            view.frame.size = CGSize(width: view.bounds.width, height: view.frame.height + CGFloat(keyboardheight))
            backgroundSV.frame.size = CGSize(width: backgroundSV.bounds.width, height: backgroundSV.frame.height + CGFloat(keyboardheight))
            keyBoardStatus = false
            view.endEditing(true)
        }
    }
    
    func videoPlayer(videoUrl:String){
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
            present(playerController, animated: true)
        }
    
    func imageShow(url:String){
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageVc") as? ImageVc
        vc?.str = url
        present(vc!, animated: true)
    }
    
}

extension ChatConversionCode : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return srtttt.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = srtttt[indexPath.row]
        let kk = array[indexPath.row]
        let kei = key[indexPath.row]
        let myyo = chat[kei]
        let txtChat = myyo?[kk]
        if kk == "\(phoneid)chatVideo" || kk == "\(receiverid)chatVideo" {
            videoPlayer(videoUrl: txtChat!)
//            print("MY URL IS ++++ \(txtChat)")
            
        }else if kk == "\(phoneid)chatPhoto" || kk == "\(receiverid)chatPhoto" || kk == "chatPhoto" {
            imageShow(url:txtChat!)
//            print("Image Url is \(txtChat)")
        }else {
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < srtttt.count {
            let chat = srtttt[indexPath.row]
            let kk = array[indexPath.row]
            let kei = key[indexPath.row]
            let myyo = chat[kei]
            let txtChat = myyo?[kk]
//            print("Array length is =====------------> \(array.count)")
//            print("dict Array length is =====------------> \(srtttt.count)")
            if kk == "\(phoneid)chatPhoto" || kk == "\(receiverid)chatPhoto" || kk == "chatPhoto" {
                if kk == "\(receiverid)chatPhoto" {
                    if txtChat != "" {
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as? ImageTableViewCell
                        let url = URL(string: txtChat ?? "")
                        cell?.photos.kf.setImage(with: url)
                        return cell!
                    }
                }
                else  if kk == "\(phoneid)chatPhoto"{
                    if txtChat != "" {
                        
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderImageChatCell") as? SenderImageChatCell
                        let url = URL(string: txtChat ?? "")
                        cell?.senderImage.kf.setImage(with: url)
                        return cell!
                    }
                }else {
                    if txtChat != "" {
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as? ImageTableViewCell
                        let url = URL(string: txtChat ?? "")
                        cell?.photos.kf.setImage(with: url)
                        return cell!
                    }
                }
                
            } else if kk == "\(phoneid)chatVideo" || kk == "\(receiverid)chatVideo" {
                if kk == "\(receiverid)chatVideo" {
                    if txtChat != "" {
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "ReceiverVideoCell") as? ReceiverVideoCell
                        cell?.confi(videoUrl: txtChat ?? "")
                        return cell!
                    }
                }
                else  if kk == "\(phoneid)chatVideo"{
                    if txtChat != "" {
//                        print("MY VIDEO URL IS -------\(txtChat)")
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderVideoCell") as? SenderVideoCell
                        cell?.confi(videoUrl: txtChat ?? "")
                        return cell!
                    }
                }else {
                    if txtChat != "" {
                        let cell = chatTable.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as? ImageTableViewCell
                        let url = URL(string: txtChat ?? "")
                        cell?.photos.kf.setImage(with: url)
                        return cell!
                    }
                }
            }
            else {
                
//                print("My chatting is",chat)
//                print("my id is ",kk)
                
                if phoneid == kk || "\(phoneid)text" == kk {
                    let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderViewCell", for: indexPath) as? SenderViewCell
                    cell?.senderMessage.text = "\(txtChat!)"
                    
                    return cell!
                }
                else {
                    let cell = chatTable.dequeueReusableCell(withIdentifier: "ReceiverViewCell", for: indexPath) as? ReceiverViewCell
                    cell?.receiverMessages.text = "\(txtChat!)"
                    return cell!
                }
                //        }
            }
            
        }
        let cell = chatTable.dequeueReusableCell(withIdentifier: "SenderViewCell", for: indexPath) as? SenderViewCell
        return cell!
    }
    
    
    
}

extension ChatConversionCode {
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

class UILabel : UIKit.UILabel {
    var insets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -insets.top,
                                          left: -insets.left,
                                          bottom: -insets.bottom,
                                          right: -insets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}
