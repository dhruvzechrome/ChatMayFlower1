//
//  DataBaseManager.swift
//  ChatMayFlower
//
//  Created by iMac on 14/10/22.
//

import Foundation
import FirebaseDatabase

class DataBaseManager {
    
    static let shared = DataBaseManager()
    
    private let database = Database.database().reference()
    public func test(){}
    
    
}

//MARK: - use Account manage
extension DataBaseManager {
    
    public func userExists(with number: String, completion: @escaping ((Bool) -> Void)){
        database.child(number).observeSingleEvent(of: .value, with: {snapshot in
            guard let founNumber = snapshot.value as? String else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// insert new user to database
    public func insertUser(with user : ChatAppUser){
        database.child(user.phoneNumber).setValue(["Phone number": user.phoneNumber])
    }
}

struct ChatAppUser {
    let phoneNumber: String
}
