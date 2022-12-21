//
//  ReceiverEditCode.swift
//  ChatMayFlower
//
//  Created by iMac on 15/12/22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Kingfisher
class ReceiverEditCode: UIViewController {
    var groupMsgId = ""
    var uid : Int?
    var currentUser = ""
    @IBOutlet weak var receITableView: UITableView!
    var nav = ""
    var groupK = "no"
    var urlPath = ""                    // url of photos
    var filename = ""                   // path of photo in firebase storage
    var uname = ""                      // user name
    var uphoneno = ""
    var databaseRef: DatabaseReference!
    var phones = ""
    var imag : UIImage?
    var imagearray = [UIImage]()
    @IBOutlet weak var edit: UIBarButtonItem!
    var arrayList = [String.SubSequence]()
    var allUserOfFirebase = [[String:String]]()
    var groupUser = [String]()
    var groupAdmin = ""
    override func viewDidLoad() {
        super.viewDidLoad()
     //   navigationController?.navigationBar.gestureRecognizers?.removeAll()
//        navigationItem.hidesBackButton = false
        if phones == "" {
        } else {
            receITableView.delegate = self
            receITableView.dataSource = self
            if groupK == "yes" {
                
                
                edit.title = "Edit Group"
                arrayList = phones.split(separator: "+")
//                print("count \(arrayList.count)")
                receITableView.reloadData()
                for i in 0...arrayList.count-1 {
                    groupUser.append("+\(arrayList[i])")
                }
//                print("Group Users \(groupUser)")
            }
            receITableView.reloadData()
        }
        if phones != "" {
            receITableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = (FirebaseAuth.Auth.auth().currentUser?.phoneNumber)!
        print(currentUser)
        if groupAdmin != currentUser  && groupK == "yes" && currentUser != "" {
            print("Current user \(currentUser) --- Group Admin \(groupAdmin)")
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
        }
    }
    
    @IBAction func rightBar(_ sender: Any) {
    }
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBAction func editButton(_ sender: Any) {
        
        if groupK == "yes" {
            let vc = storyboard?.instantiateViewController(withIdentifier: "GroupCreationCode") as? GroupCreationCode
            vc?.groupUser = groupUser
            vc?.usersList = allUserOfFirebase
            vc?.phones = currentUser
            vc?.uid = uid
            vc?.groupName = phones
            vc?.name = uname
            vc?.groupMsgId = groupMsgId
            self.present(vc!, animated: true)
            
        }
        
    }
    
var int = 0

}

extension ReceiverEditCode : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupK == "yes" {
            return 1+groupUser.count
        } else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("\(indexPath.row)")
        if groupK == "yes" {
            if indexPath.row == 0 {
                let cell = receITableView.dequeueReusableCell(withIdentifier: "ReceiverProfileViewCell", for: indexPath) as? ReceiverProfileViewCell
                cell?.participant.text = "Participants"
                cell?.profileName.text = uname
//                cell?.profileNumber.text = phones
                if urlPath != "" {
                    let url = URL(string: urlPath)
                    cell?.profilePic.kf.setImage(with: url)
                }
                cell?.selectionStyle = .none
                return cell!
            } else {
                let frd = groupUser[int]
//                print("user \(frd)")
               
                let cell = receITableView.dequeueReusableCell(withIdentifier: "GroupUserCell", for: indexPath) as? GroupUserCell
                cell?.groupUserName.text = "\(frd)"
                int += 1
                if int == groupUser.count {
                    int = 0
                }
                return cell!
            }

        }
        else {
            let cell = receITableView.dequeueReusableCell(withIdentifier: "ReceiverProfileViewCell", for: indexPath) as? ReceiverProfileViewCell
            cell?.profileName.text = uname
            if uname == phones {
            } else {
                cell?.profileNumber.text = phones
            }
            cell?.participant.isHidden = true
            cell?.selectionStyle = .none
            if urlPath != "" {
                let url = URL(string: urlPath)
                cell?.profilePic.kf.setImage(with: url)
            }
            return cell!
        }
        
    }
}
