//
//  User.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/31.
//

import Foundation
import Firebase
import FirebaseFirestore

class User {
    
    let name: String
    let email: String
    let uid: String
    let urlString: String
    let createdAt: Timestamp
    
    init(dic: [String: Any]){
        self.name = dic["name"] as? String ?? ""
        self.email = dic["email"] as? String ?? ""
        self.urlString = dic["urlString"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
