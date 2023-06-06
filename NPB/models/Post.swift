//
//  Post.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class Post{
    
    let name: String
    let post: String
    let uid: String
    let url: String
    let createdAt: Timestamp
    
    init(dic: [String: Any]){
        self.name = dic["name"] as? String ?? ""
        self.url = dic["url"] as? String ?? ""
        self.post = dic["text"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
