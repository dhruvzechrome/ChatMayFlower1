//
//  GroupCreationCode.swift
//  ChatMayFlower
//
//  Created by iMac on 30/11/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher


class GroupCreationCode: UIViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        usersList = []
        let searchText = searchController.searchBar.text
        if searchText == "" {
            usersList = usersListSearch
        }
        for cnt in 0...usersListSearch.count-1 {
            let frd = usersListSearch[cnt]
            let name = frd["Name"]
            let number = frd["Phone number"]
            if name != "" {
                if name!.lowercased().contains(searchText!.lowercased()) {
                    usersList.append(frd)
                }
            }
            if number != nil {
                if number!.contains(searchText!) {
                    usersList.append(frd)
                }
            }
        }
        userTable.reloadData()
    }
    
    var fileName = ""
    var photoUrlPth = ""
    var groupMsgId = ""
    var name = ""
    var groupAdmin = ""
    var usersList = [[String:String]]()
    var usersListSearch = [[String:String]]()
    var selecetdUser = [[String:String]]()
    var phones = ""
    var databaseRef = Database.database().reference()
    var groupUser = [String]()
    var groupUserSelected = [String]()
    var groupName = ""
    var uid :Int?
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var userTable: UITableView!
    let searchController = UISearchController()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add User"
        nextButton.isEnabled = false
        groupUserSelected = groupUser
        if groupUserSelected.count > 0 {
            for i in 0...usersList.count-1 {
                let frd = usersList[i]
                for t in 0...groupUserSelected.count-1 {
                    if frd["Phone number"] == groupUserSelected[t] {
                        selecetdUser.append(frd)
                        break
                    }
                }
            }
            selecetdUser.append(["Phone number": phones])
        }
        print("Selected user \(selecetdUser)")
        userTable.delegate = self
        userTable.dataSource = self
        self.userTable.isEditing = true
        self.userTable.allowsMultipleSelectionDuringEditing = true
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        userTable.tableHeaderView = searchController.searchBar
        usersListSearch = usersList
        if usersList.count > 0 {
            print("Users list \(usersList)")
            userTable.reloadData()
        }
    }
    
    @IBAction func createGrpButton(_ sender: UIBarButtonItem) {
        if name == "" {
            let vc = storyboard?.instantiateViewController(withIdentifier: "GroupViewController" ) as? GroupViewController
            vc?.selecetdUser = selecetdUser
            vc?.groupUser = groupUser
            vc?.phones = phones
            vc?.groupMsgId = groupMsgId
            vc?.groupName = groupName
            vc?.name = name
            vc?.fileName = fileName
            vc?.photoUrlPath = photoUrlPth
            print("Url path of Photo of group \(fileName)")
            navigationController?.pushViewController(vc!, animated: true)
        } else {
            print("No")
            let vc = storyboard?.instantiateViewController(withIdentifier: "GroupViewController" ) as? GroupViewController
            
            for i in 0...selecetdUser.count-1 {
                let frd = selecetdUser[i]
                if phones == frd["Phone number"] {
                    selecetdUser.remove(at: i)
                    break
                }
            }
            vc?.selecetdUser = selecetdUser
            vc?.groupUser = groupUser
            vc?.phones = phones
            vc?.groupMsgId = groupMsgId
            vc?.groupName = groupName
            vc?.name = name
            vc?.fileName = fileName
            vc?.photoUrlPath = photoUrlPth
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}

extension GroupCreationCode : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = usersList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCreationTableViewCell", for: indexPath) as? GroupCreationTableViewCell
//        print("my image is \(frd["profilepic"]!)")
        if groupUserSelected.count > 0 {
            _ = groupUserSelected.filter { list in
                if list == frd["Phone number"] {
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    nextButton.isEnabled = true
                }
            return true
            }
        }
        if frd["Name"] == nil {
            cell?.userTitle.text = frd["Phone number"]
        } else {
            cell?.userTitle.text = frd["Name"]
            if frd["Name"] == "" {
                cell?.userTitle.text = frd["Phone number"]
            }
        }
        if frd["profilepic"] == nil {
            cell?.userProfile.image = UIImage(systemName:  "person.circle.fill")
        } else {
            let url = URL(string: frd["profilepic"]! )
            cell?.userProfile.kf.setImage(with: url)
            if frd["profilepic"] == "" {
                cell?.userProfile.image = UIImage(systemName: "person.circle.fill")
            }
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let frd = usersList[indexPath.row]
        let num = (frd["Phone number"])!
        if !groupUser.contains(num) {
            groupUser.append(num)
            selecetdUser.append(frd)
            mychat()
        }
        nextButton.isEnabled = true
        print("\(groupUser) -- selected user \(selecetdUser)")
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let frd = usersList[indexPath.row]
        let num = (frd["Phone number"])!
        for i in 0...groupUser.count-1 {
            if num == groupUser[i] {
                groupUser.remove(at: i)
                mychat()
                break
            }
        }
        for i in 0...selecetdUser.count-1 {
            let tds = selecetdUser[i]
            if frd["Phone number"] == tds["Phone number"] {
                selecetdUser.remove(at: i)
                break
            }
        }
        if groupUser.count == 0 {
            nextButton.isEnabled = false
        }
        print("\(groupUser) -- selected user \(selecetdUser)")
    }
    
    func mychat() {
        groupName = ""
        if groupUser.count > 0 {
            for i in 0...groupUser.count-1 {
                groupName = "\(groupName)\(groupUser[i])"
                print(groupName)
            }
        }
        print("\(groupName)")
    }
}
