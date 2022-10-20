
//
//  ChatConversionCode.swift
//  ChatMayFlower
//
//  Created by iMac on 17/10/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class ChatConversionCode: UIViewController {
    var cu = ""
    private let database = Database.database().reference()
    var phoneid = ""
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var chatField: UITextField!
    var ui = 0
    var chat = [Message]()
    var mid = ""
    var fri = [String]()
    var friends = [Message]()
    var id: Int?
//    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var titl: UINavigationItem!
    var timer = Timer()
    
    func getdata(){
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
    var dictArray: [[String:String]] = []
    var array = [String]()
    func getchat(){
        database.child("Chats").child(mid).child("chatting").observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.childSnapshot(forPath: self!.mid)
            print("Key:::---",key)
            guard let value = snapshot.value as? [String:Any] else {return
                print("Error")
            }
            print("total data",value)
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots {
                    let cata = snap.key
                    let ques = snap.value!
                    self!.array.append("\(cata)")
                    
                    self!.dictArray.append([cata : String(describing: ques)])
                }
                
            }
            self?.chatTable.reloadData()
//            print("key of value is ",self!.array)
//            print("dictionary is ",self!.dictArray)
            
//            if let nam = value["\(self!.fri[self!.id!].phoneNumber)"] as? String {
//
//                let friend = Message(messagid: self!.mid!, chats: "d", sender: "\(nam)", uii: self!.ui)
//
//                self!.friends.append(friend)
//                print("Nam is ",nam)
////                print("Number iis ",number)
//
//                if let row = self?.friends.count{
//                    let indexPath = IndexPath(row: row-1, section: 0)
//                    self?.chatTable.insertRows(at: [indexPath], with: .automatic)
//                    print("row",row)
//                }
//                self?.chatTable.reloadData()
////                self?.friends.remove(at: reg)
//                print("all chats ",self!.friends)
//
//            }
        }
    }
    
    @IBAction func sendChat(_ sender: UIButton) {
        
        if chatField.text != nil{
            ui = ui + 1
//            chat.append(Message(messagid: mid!, chats: chatField.text!, sender: <#String#>, uii: ui))
            database.child("Uid").setValue(ui)
            DataBaseManager.shared.mychatting(with: Message(messagid: mid, chats: chatField.text!, sender: "ul", uii: ui))
            chatTable.reloadData()
        }
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        getdata()
        if (self.chatTable.contentSize.height > self.chatTable.frame.size.height) {
            let offset = CGPoint(x: CGFloat(0), y: CGFloat(self.chatTable.contentSize.height - self.chatTable.frame.size.height))
            self.chatTable.setContentOffset(offset, animated: true)
        }
        cu = (FirebaseAuth.Auth.auth().currentUser?.phoneNumber)!
        getchat()
    }
    var llb = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTable.delegate = self
        chatTable.dataSource = self
        cu = (FirebaseAuth.Auth.auth().currentUser?.phoneNumber)!
        titl.title = fri[id!]
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
                getdata()
            llb = ui
            if ui > llb{
                getchat()
            }
            
        })
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getdata()
    }
   
}

extension ChatConversionCode : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = dictArray[indexPath.row]
        let kk = array[indexPath.row]
        let cell = chatTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatTableViewCell
        
        cell?.messages.text = chat[kk]
        if phoneid == kk {
                    cell?.messages.textAlignment = .right
                    
                }
                else {
                    cell?.messages.textAlignment = .left
                }
            return cell!
       
    }


}

