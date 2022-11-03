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
    func getData(){
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.key
//            print("Key",key)
            guard let value = snapshot.value as? [String:Any] else {return}
            
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots {
                    let cata = snap.key
                    let ques = snap.value!
                    if ques as! String != self!.phones {
                        self!.array.append("\(ques)")
                    }
                    self!.dictArray.append([cata : String(describing: ques)])
                }
                
            }
            self?.tabelView.reloadData()
//            print("key of value is ",self!.array)
//            print("dictionary is ",self!.dictArray)
        }
    }
    
    var msgkey = [String]()
    func getMessageId(){
        databaseRef = Database.database().reference().child("Chats")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.key
//            print("Key",key)
            guard let value = snapshot.value as? [String:Any] else {
                print("No data Found")
                return
            }
            
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{

                for snap in snapshots {
                    let cata = key
                    let ques = snap.value!
                    self!.msgkey.append("\(cata)")
                
//                    self!.dictArray.append([cata : String(describing: ques)])
                }

            }
            else{
                print("No data Found")
            }
            self?.tabelView.reloadData()
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
        
        tabelView.delegate = self
        tabelView.dataSource = self
        print(friends)
        getData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
           self.tabelView.refreshControl = refreshControl
       
        // Do any additional setup after loading the view.
    }
    
    @objc func refresh(_ sender : Any)
      {
          array = [String]()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)
          { [self] in
          getData()
        }
      }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesBackButton = true
        validAuth()
        print("current User",phones)
        getMessageId()
    }
    
    func validAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
            navigationController?.pushViewController(vc!, animated: true)
        }
        phones = FirebaseAuth.Auth.auth().currentUser?.phoneNumber ?? ""
    }
}


extension UserDetailsCode: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = array[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        cell?.userLabel.text = frd
//        cell?.SetUp(with: data)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tabelView.deselectRow(at: indexPath, animated: true)
        let frd = array[indexPath.row]
        ab = frd
        if msgkey.count > 0{
        for avl in msgkey.startIndex...msgkey.count - 1 {
            if msgkey[avl] == "\(phones)\(frd)" || msgkey[avl] == "\(frd)\(phones)"{
                messageId = msgkey[avl]
                msgstatus = true
            }
        }
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatConversionCode") as? ChatConversionCode
        vc?.fri = array
        vc?.id = indexPath.row
        mychat()
        vc?.mid = messageId!
        vc?.phoneid = phones
        navigationController?.pushViewController(vc!, animated: true)
//        friends = [ChatAppUser]()
    }
    
    
    func mychat(){
        
        
//        DataBaseManager.shared.chatExist(with: messageId!, completion: { exists in
//            guard !exists else{
//                // user Exists already
//            }
//            // user not exists
//            DataBaseManager.shared.createNewChat(with: Message(messagid: messageId, chats: ""))
//        })
        print("Array is this ", array)
        if msgstatus == false{
            messageId = "\(phones)\(ab)"
            databaseRef.child("Chat").observeSingleEvent(of: .value, with: { [self] (snapshot) in
                if snapshot.exists(){
                    print("true rooms exist")
                }else{
                    print("false room doesn't exist")
                    DataBaseManager.shared.createNewChat(with: Message( messagid: self.messageId!, chats: "", sender: "",uii: 0))
                }
            })
        }
    }
    
}
