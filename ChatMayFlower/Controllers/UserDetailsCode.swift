//
//  UserDetailsCode.swift
//  ChatMayFlower
//
//  Created by iMac on 13/10/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCoreInternal
import FirebaseStorage
import Kingfisher
import MBProgressHUD

class UserDetailsCode: UIViewController {
    
    var msgstatus = false
    var ab = ""
    @IBOutlet weak var tabelView: UITableView!
    var phones = ""
    var databaseRef: DatabaseReference!
    var reg: Int = 0
    var messageId:String?
    var friends = [ChatAppUser]()
    var dictArray: [[String:String]] = []
    var array = [String]()
    var strArray  = [[String:String]]()
    var arrayDetails = [[String:Any]]()
    let storageRef = Storage.storage().reference()
    func getData(){
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
//            let key = snapshot.key
//            //            print("Key",key)
//            guard let value = snapshot.value as? [String:Any] else {return}
            
            self!.mbProgressHUD(text: "Loading.")
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                for snap in snapshots {
                    //                    let cata = snap.key
                    //                    let ques = snap.value!
                    
                    let gif = snapshot.value! as! [String:String]
                    
                    if snapshot.key != self!.phones {
                        
                        if !self!.array.contains("\(snapshot.key)") {
                            
                            self!.array.append("\(snapshot.key)")
                            print("Aray of number is \(self!.array)")
                         
                            if gif["Name"] != nil {
                                
                                if gif["photo url"] != nil {
                                    self!.arrayDetails.append(["Name" : gif["Name"]! , "Phone number": gif["Phone number"]!, "profilepic": gif["photo url"]!])
                                    print("ArrayPractise----------->>>\(self!.arrayDetails)")
                                } else {
                                    self!.arrayDetails.append(["Name" : gif["Name"]! , "Phone number": gif["Phone number"]!, "profilepic": ""])
                                    print("ArrayPractise----------->>>\(self!.arrayDetails)")
                                }
                                
                            } else {
                                self!.arrayDetails.append(["Name" : "" , "Phone number": gif["Phone number"]!, "profilepic": ""])
                                print("ArrayPractise----------->>>\(self!.arrayDetails)")
                            }
                            
                        }
                    }
                    
                    
                }
                //                sstr.append(snapshot.value)
            }
            print("Dictionary Array is ",self!.dictArray)
            print("Sbapshot is ", snapshot.value!)
            //            self?.tabelView.reloadData()
            //            print("key of value is ",self!.array)
            //            print("dictionary is ",self!.dictArray)
        }
    }
    
    var msgkey = [String]()
    func getMessageId() {
        databaseRef = Database.database().reference().child("Chats")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.key
            //            print("Key",key)
            guard let value = snapshot.value as? [String:Any] else {
                print("No data Found")
                return
            }
            
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                for snap in snapshots {
                    let cata = key
//                    let ques = snap.value!
                    self!.msgkey.append("\(cata)")
                    
                    //                    self!.dictArray.append([cata : String(describing: ques)])
                }
                
            } else {
                print("No data Found")
            }
            self?.tabelView.reloadData()
            self?.hideProgress()
            //            print("key of value is ",self!.msgkey)
            //            print("dictionary is ",self!.dictArray)
        }
    }
    
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneVerificationCode") as? PhoneVerificationCode
            navigationController?.pushViewController(vc!, animated: true)
            print("Sign out success")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mbProgressHUD(text: "Loading..")
        tabelView.delegate = self
        tabelView.dataSource = self
        print(friends)
        getData()
        
        //        let refreshControl = UIRefreshControl()
        //        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        //           self.tabelView.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
    }
    
    @objc func refresh(_ sender : Any)
    {
        array = [String]()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            getData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        validAuth()
        print("current User",phones)
        getMessageId()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationItem.hidesBackButton = true
        tabBarController?.tabBarItem.accessibilityElementIsFocused()
    }
    func validAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
            navigationController?.pushViewController(vc!, animated: true)
            hideProgress()
        }
        phones = FirebaseAuth.Auth.auth().currentUser?.phoneNumber ?? ""
    }
}


extension UserDetailsCode: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = arrayDetails[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        cell?.userLabel.text = frd["Phone number"] as? String
        print("my image is \(frd["profilepic"]!)")
        
        if frd["profilepic"] as! String == "" {
            cell?.profile.image = UIImage(named: "person")
        } else {
            let url = URL(string: frd["profilepic"]! as! String)
            cell?.profile.kf.setImage(with: url)
        }
        //        cell?.SetUp(with: data)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tabelView.deselectRow(at: indexPath, animated: true)
        let frd = arrayDetails[indexPath.row]
        ab = frd["Phone number"]! as! String
        if msgkey.count > 0 {
            for avl in 0...msgkey.count - 1 {
                if msgkey[avl] == "\(phones)\(ab)" || msgkey[avl] == "\(ab)\(phones)" {
                    messageId = msgkey[avl]
                    //                print("True -----------")
                    msgstatus = true
                }
            }
        }
        mbProgressHUD(text: "Loading..")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatConversionCode") as? ChatConversionCode
        vc?.receiverid = ab
        mychat()
        vc?.mid = messageId!
        vc?.phoneid = phones
        
        navigationController?.pushViewController(vc!, animated: true)
        hideProgress()
        //        friends = [ChatAppUser]()
    }
    
    
    func mychat() {
        
        
        //        DataBaseManager.shared.chatExist(with: messageId!, completion: { exists in
        //            guard !exists else{
        //                // user Exists already
        //            }
        //            // user not exists
        //            DataBaseManager.shared.createNewChat(with: Message(messagid: messageId, chats: ""))
        //        })
        if msgstatus == false {
            messageId = "\(phones)\(ab)"
            databaseRef.child("Chat").observeSingleEvent(of: .value, with: { [self] (snapshot) in
                if snapshot.exists() {
                    print("true rooms exist")
                } else {
                    print("false room doesn't exist")
                    DataBaseManager.shared.createNewChat(with: Message( messagid: self.messageId!, chats: "", sender: "",uii: 0, chatPhotos: ""))
                }
            })
        }
    }
    
}

extension UserDetailsCode {
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
