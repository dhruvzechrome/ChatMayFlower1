
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
        print("Message id is " ,  mid)
        database.child("Chats").child(mid).child("chatting").observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.childSnapshot(forPath: self!.mid)
            //            print("Key:::---",key)
            guard let value = snapshot.value as? [String:Any] else {return
                print("Error")
            }
            //            print("total data",value)
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots {
                    let cata = snap.key
                    let ques = snap.value!
                    self!.array.append("\(cata)")
                    
                    self!.dictArray.append([cata : String(describing: ques)])
                }
                
            }
            self?.chatTable.reloadData()
            self!.bo = true
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
        
        if chatField.text != ""{
            ui = ui + 1
            bo = true
            //            chat.append(Message(messagid: mid!, chats: chatField.text!, sender: <#String#>, uii: ui))
            database.child("Uid").setValue(ui)
            DataBaseManager.shared.mychatting(with: Message(messagid: mid, chats: chatField.text!, sender: "ul", uii: ui))
            chatTable.reloadData()
            chatField.text = ""
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        getdata()
        
        tabBarController?.tabBar.isHidden = true
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cu = (FirebaseAuth.Auth.auth().currentUser?.phoneNumber)!
        
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        getchat()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTable.delegate = self
        chatTable.dataSource = self
        keyboardheight = 0
        cu = (FirebaseAuth.Auth.auth().currentUser?.phoneNumber)!
        titl.title = receiverid
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
            getdata()
            llb = ui
            chatTable.reloadData()
            if ui > llb{
                getchat()
                
            }
            
            if bo == true{
                bo = false
                let indexPath = IndexPath(item: array.count-1, section: 0)
                chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getdata()
        let indexPath = IndexPath(item: array.count-1, section: 0)
        chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        
    }
    
}

extension ChatConversionCode{
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

