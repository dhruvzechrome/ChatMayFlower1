
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
    var mid : String?
    var fri = [ChatAppUser]()
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
    func getchat(){
        cu = FirebaseAuth.Auth.auth().currentUser!.phoneNumber!
        print("Cu is",cu)
        database.child("Chats").child(mid!).child("chatting").observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.childSnapshot(forPath: self!.mid!)
            print("Key:::---",key)
            guard let value = snapshot.value as? [String:Any] else {return}
            print(value)
            print("\(FirebaseAuth.Auth.auth().currentUser!.phoneNumber!)")
            if let nam = value["\(self!.fri[self!.id!].phoneNumber)"] as? String {
                let number = value["\(self!.cu)"] as? String
                let friend = Message(messagid: self!.mid!, chats: "\(number)", sender: "\(nam)", uii: self!.ui)
              
                self!.friends.append(friend)
                
            
                if let row = self?.friends.count{
                    let indexPath = IndexPath(row: row-1, section: 0)
                    self?.chatTable.insertRows(at: [indexPath], with: .automatic)
                    print("row",row)
                }
                self?.chatTable.reloadData()
////                self?.friends.remove(at: reg)
                print("all chats ",self!.friends)
//
            }
        }
    }
    
    @IBAction func sendChat(_ sender: UIButton) {
        
        if chatField.text != nil{
            ui = ui + 1
//            chat.append(Message(messagid: mid!, chats: chatField.text!, sender: <#String#>, uii: ui))
            database.child("Uid").setValue(ui)
            DataBaseManager.shared.mychatting(with: Message(messagid: mid!, chats: chatField.text!, sender: "ul", uii: ui))
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
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTable.delegate = self
        chatTable.dataSource = self
        cu = (FirebaseAuth.Auth.auth().currentUser?.phoneNumber)!
        titl.title = fri[id!].phoneNumber
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
                getdata()
            
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
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = friends[indexPath.row]
        let cell = chatTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatTableViewCell
        
        cell?.messages.text = "\(chat.sender) \n"+"\(chat.chats)"
            cell?.messages.textAlignment = .center
            return cell!
       
    }


}

