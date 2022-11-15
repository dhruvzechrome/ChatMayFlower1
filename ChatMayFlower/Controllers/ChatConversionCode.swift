
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
    
    func getchat() {
        print("my array is this ",array)
        print("my dic array is this ",dictArray)
        print("Message id is " ,  mid)
        array.removeAll()
        dictArray.removeAll()
        
        
        database.child("Chats").child(mid).child("chatting").observe(.childAdded) {[weak self](snapshot) in
            DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                guard let value = snapshot.value as? [String:Any] else {return
                    print("Error")
                }
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    for snap in snapshots {
                        let cata = snap.key
                        let ques = snap.value!
                        print("Cata ---------- \(cata)")
                        print("Ques >>>>---------- \(ques)")
                        
                        self?.array.append("\(cata)")
                        self?.dictArray.append([cata : String(describing: ques)])
                        
                    }
                    
                }
                
                if (self?.array.count)! > 0 {
                    self?.chatTable.reloadData()
                    print("my array is this ",self?.array)
                    print("my dic array is this ",self?.dictArray)
                    print("my array is this ",self?.array.count)
                    print("my dic array is this ",self?.dictArray.count)
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
        //        getdata()
         getchat()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [self] in
            print("my array is this----------------====== ",array)
            print("my dic array is this ",dictArray)
            print("my array is this ",array.count)
            print("my dic array is this ",dictArray.count)
        }
        
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
        cu = (FirebaseAuth.Auth.auth().currentUser?.phoneNumber)!
        titl.title = receiverid
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
//        addImageVideo.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getdata()
       
        
        
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
//            add.image = selectedImage
            didselectedImage = selectedImage
            let localPath = info[.imageURL] as? NSURL
            _ = info[.imageURL] as? URL
            print("Local Path  > ",localPath!)
    
            picker.dismiss(animated: true, completion: nil)
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
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        view.endEditing(true)
    //    }
    
}

extension ChatConversionCode : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < dictArray.count {
            let chat = dictArray[indexPath.row]
            let kk = array[indexPath.row]
            
            if kk == "chatPhoto" {
                if chat[kk] != "" {
                    let cell = chatTable.dequeueReusableCell(withIdentifier: "ImageTableViewCell") as? ImageTableViewCell
                    let url = URL(string: chat["chatPhoto"]!)
                    cell?.photos.kf.setImage(with: url)
                    return cell!
                }
            }
                let cell = chatTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatTableViewCell
                print("My chatting is",chat)
                print("my id is ",kk)

                cell?.messages.text = chat[kk]

                if phoneid == kk {
                    cell?.messages.textAlignment = .right

                }
                else {
                    cell?.messages.textAlignment = .left

                }
                //        }
                cell?.messages.numberOfLines = 0
                return cell!

        }
        let cell = chatTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatTableViewCell
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < dictArray.count {
            let chat = dictArray[indexPath.row]
            let kk = array[indexPath.row]
            
            let cell = chatTable.cellForRow(at: indexPath)
            if kk == "chatPhoto" {
                if chat[kk] != "" {
                    return 200
                }
            }
        }
       
        return UITableView.automaticDimension
    }
}

