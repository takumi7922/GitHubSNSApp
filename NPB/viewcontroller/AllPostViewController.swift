//
//  AllPostViewController.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/24.
//

import UIKit
import Firebase
import FirebaseFirestore

class AllPostViewController: UIViewController {

    @IBOutlet weak var allPostTableView: UITableView!
    private let cellId = "cellId"
    private var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        allPostTableView.register(UINib(nibName: "AllPostTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        allPostTableView.delegate = self
        allPostTableView.dataSource = self
        getPost()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tappedCrossButton(){
        
        let chatViewController = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    private func getPost(){
        Firestore.firestore().collection("posts").addSnapshotListener { snapshot, err in
            if let err = err {
                print("投稿情報の取得に失敗しました。\(err)")
                return
            }
            
            snapshot?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    print("post dic", dic)
                    let post = Post(dic: dic)
                    self.posts.append(post)
                    
                    self.posts.sort { (m1 , m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    
                    self.allPostTableView.reloadData()
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
    

}

extension AllPostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = allPostTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AllPostTableViewCell
        
        cell.post = posts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
    
    
}

