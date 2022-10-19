//
//  DataBaseManager.swift
//  ChatMayFlower
//
//  Created by iMac on 14/10/22.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class DataBaseManager {
    
    static let shared = DataBaseManager()
    
    private let database = Database.database().reference()
    
    
}

//MARK: - use Account manage
extension DataBaseManager {

    public func userExists(with number: String){
        database.child("Contact List").child(number).observeSingleEvent(of: .value, with: {snapshot in
            guard let founNumber = snapshot.value as? String else {
                return
            }
            
        })
    }
    
    /// insert new user to database
    public func insertUser(with user : ChatAppUser){
        database.child("Contact List").child(user.phoneNumber).setValue(["Phone number": user.phoneNumber], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write data")
               
                return
            }
            print("data written seccess")

        })
    }
    
    public func createNewChat(with user : Message){
        let num = FirebaseAuth.Auth.auth().currentUser!.phoneNumber
        database.child("Chats").child(user.messagid).child("chatting").child("\(user.uii)").setValue(["\(num!)": user.chats], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write data")
               
                return
            }
            print("data written seccess")
        })
    }
    
    public func chatExist(with messageId: String){
        database.child("Chats").child(messageId).observeSingleEvent(of: .value, with: {snapshot in
            guard let founNumber = snapshot.value as? String else {
                return
            }
            
        })
    }
    
    public func mychatting(with user : Message){
        let num = FirebaseAuth.Auth.auth().currentUser!.phoneNumber
        database.child("Chats").child(user.messagid).child("chatting").child("\(user.uii)").setValue(["\(num!)": user.chats], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write data")
               
                return
            }
            print("data written seccess")
        })
    }
    
}


struct ChatAppUser {
    let phoneNumber: String
}
struct Message{
    var messagid : String
    var chats : String
    var sender : String
    var uii : Int
}

