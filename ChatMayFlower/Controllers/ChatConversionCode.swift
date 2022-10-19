
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
    private let database = Database.database().reference()
    var phoneid = ""
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var chatField: UITextField!
    var ui = 0
    var chat = [Message]()
    var mid : String?
    var fri = [ChatAppUser]()
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
            print(self.ui)
        });
    }
    
    @IBAction func sendChat(_ sender: UIButton) { 
        
        if chatField.text != nil{
            ui = ui + 1
            chat.append(Message(messagid: mid!, chats: chatField.text!, uii: ui))
            database.child("Uid").setValue(ui)
            DataBaseManager.shared.mychatting(with: Message(messagid: mid!, chats: chatField.text!, uii: ui))
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
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTable.delegate = self
        chatTable.dataSource = self
        let cu = FirebaseAuth.Auth.auth().currentUser?.phoneNumber
        titl.title = fri[id!].phoneNumber
        print(cu)
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
        return chat.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chat = chat[indexPath.row]
        let cell = chatTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChatTableViewCell
        cell?.messages.text = chat.chats
        
        if FirebaseAuth.Auth.auth().currentUser?.phoneNumber != fri[id!].phoneNumber {
            cell?.messages.textAlignment = .right
            return cell!
        }
        else{
            cell?.messages.textAlignment = .left
            return cell!
        }
    }


}

