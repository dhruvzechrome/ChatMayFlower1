//
//  AllUsersList.swift
//  ChatMayFlower
//
//  Created by iMac on 05/12/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher
class AllUsersList: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate{
    var databaseRef: DatabaseReference!
    var usersNumber = ""
    var usersDetails = [[String:String]]()
    var usersLists = [[String:String]]()   ////  Main list of all contact list
    var allUser = [[String:String]]()
    var allUserOfFirebase = [[String:String]]()
    var phones = ""
    var msgIdList = [String]()
    var msgKey = [String]()
    var msgstatus = false
    var messageId:String?
    let searchController = UISearchController()
    @IBOutlet weak var tableViewCell: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewCell.delegate = self
        tableViewCell.dataSource = self
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        title = "New Chat"
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
            
            //MARK: - remove number from contactlist which register in app and saved in our phone
            var allUserList = allUser
            var int = 0
            var ik = 0
            for cnt in 0...allUser.count-1 {
                let frd = allUser[cnt]
                for i in 0...allUserOfFirebase.count-1 {
                    let data = allUserOfFirebase[i]
                    if frd["Phone number"] == data["Phone number"] {
                        if int > ik {
                            print("frd \(frd)---\(cnt)")
                            allUserList.remove(at: cnt-int)
                        } else {
                            print("frd \(frd)---\(cnt)")
                            allUserList.remove(at: cnt)
                        }
                        ik = int
                        int += 1
                        break
                    }
                }
            }
            let list = [["Name" : "Create Group"]]
            usersLists = list + allUserOfFirebase + allUserList
            allUser = allUserOfFirebase + allUserList
            print("user count = \(allUserOfFirebase)   all count \(allUserOfFirebase.count)")
            tableViewCell.reloadData()
        }
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
}

extension AllUsersList : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = usersLists[indexPath.row]
        let cell = tableViewCell.dequeueReusableCell(withIdentifier: "AllUserTableViewCell", for: indexPath) as? AllUserTableViewCell
        if frd["Name"] == "" {
            cell?.name.text = frd["Phone number"]
        } else {
            cell?.name.text = frd["Name"]
            if frd["Name"] == "" {
                cell?.name.text = frd["Phone number"]
            }
        }
        for i in 0...allUserOfFirebase.count-1 {
            let chekFrd = allUserOfFirebase[i]
            if frd["Phone number"] == chekFrd["Phone number"] {
                cell?.otherUser.text = ""
                break
            }
            else {
                cell?.otherUser.text = "invite"
            }
        }
        if frd["Name"] == "Create Group" {
            cell?.otherUser.text = ""
        }
        if frd["profilepic"] == nil {
            cell?.profileImage.image = UIImage(systemName: "person.circle.fill")
            if indexPath.row == 0 {
                cell?.profileImage.image = UIImage(systemName: "person.2.circle.fill")
            }
        } else {
            let url = URL(string: frd["profilepic"]! )
            cell?.profileImage.kf.setImage(with: url)
            if frd["profilepic"] == "" {
                cell?.profileImage.image = UIImage(systemName: "person.circle.fill")
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewCell.deselectRow(at: indexPath, animated: true)
        let frd = usersLists[indexPath.row]
        if frd["Phone number"] == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "GroupCreationCode") as? GroupCreationCode
            vc?.usersList = allUserOfFirebase
            vc?.selecetdUser = []
            vc?.phones = phones
            //            self.dismiss(animated: true, completion: nil)
            self.navigationController?.pushViewController(vc!, animated: true)
//            self.present(vc!, animated: true, completion: nil)
        } else {
            usersNumber = frd["Phone number"]!
            print("userNumber is \(allUserOfFirebase)")
            var counter = 0
            _ = allUserOfFirebase.filter { user in
                let hib =  user["Phone number"]
                print("Phonne number   \(hib)")
                if hib == frd["Phone number"] {
                    if let vc = self.presentingViewController as? UITabBarController {
                        if let pv = vc.viewControllers?.first as? UINavigationController {
                            if let pvc = pv.viewControllers.first as? UserDetailsCode {
                                //                  pvc.receiverid = usersNumber
                                pvc.newMsg = true
                                pvc.usersNumber = usersNumber
                                pvc.msgIdList = msgIdList
                                if frd["Name"] != "" {
                                    pvc.receiverName = frd["Name"]!
                                } else {
                                    pvc.receiverName = frd["Phone number"]!
                                }
                                pvc.phones = phones
                                dismiss(animated: true)
                            }
                        }
                    }
                } else {
                    print("No number register in app")
                    counter += 1
                    if counter == allUserOfFirebase.count {
                        let alert = UIAlertController(title: "Alert", message: "User is not registered", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                return true
            }
        }
    }
    
    
    func mychat() {
        if msgstatus == false {
            messageId = "\(phones)\(usersNumber)"
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


extension AllUsersList {
    func updateSearchResults(for searchController: UISearchController) {
        usersLists = []
        let searchText = searchController.searchBar.text
        if searchText == "" {
            usersLists = [["Name" : "Create Group"]] + allUser
        }
        for cnt in 0...allUser.count-1 {
            let frd = allUser[cnt]
            let name = frd["Name"]
            let number = frd["Phone number"]
            if name != "" {
                if name!.lowercased().contains(searchText!.lowercased()) {
                    usersLists.append(frd)
                }
            }
            if number != nil {
                if number!.contains(searchText!) {
                    usersLists.append(frd)
                }
            }
        }
        self.tableViewCell.reloadData()
    }
}
