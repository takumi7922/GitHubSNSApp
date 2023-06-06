//
//  Message.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class Message{
    
    let name: String
    let message: String
    let uid: String
    let createdAt: Timestamp
    let urlString: String
    
    init(dic: [String: Any]){
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.urlString = dic["urlString"] as? String ?? ""
    }
}
