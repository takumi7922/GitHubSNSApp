//
//  SelectYouserViewController.swift
//  NPB
//
//  Created by 小松拓海 on 2023/06/03.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SelectYouserViewController: UIViewController {
    
    let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private let cellId = "cellId"
    private var posts = [Post]()
    var message: Message?
    
    @IBOutlet weak var selectYouserPostTableView: UITableView!
    @IBOutlet weak var selectFolowerButton: UIButton!
    @IBOutlet weak var selectFolowButton: UIButton!
    
    @IBOutlet weak var selectYouserLabel: UILabel!
    @IBOutlet weak var selectYouserImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectYouserPostTableView.register(UINib(nibName: "SelectYouserTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        selectYouserPostTableView.delegate = self
        selectYouserPostTableView.dataSource = self
        getPost()
        selectYouserLabel.text = delegate.selectuid?.name
        
        guard let url = URL(string: delegate.selectuid?.urlString ?? "") else { return }
        do{
            let data = try URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let imageData = data else {return}
                DispatchQueue.main.async {
                    self.selectYouserImageView.image = UIImage(data: imageData)
                }
                
            }.resume()
        }catch{
            print("nothing to do")
        }
        // Do any additional setup after loading the view.
    }
    
    private func getPost(){
        
        Firestore.firestore().collection("posts").whereField("uid", isEqualTo: delegate.selectuid?.uid).addSnapshotListener { snapshot, err in
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
                    
                    self.selectYouserPostTableView.reloadData()
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
    
    @IBAction func tappedFollowButton(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid ?? "dd"
        let checkRef = Firestore.firestore().collection("users").document(uid)
        
        checkRef.collection("follow").getDocuments() { shapshot, err in
            if let err = err{
                print("フォロー情報の取得に失敗しました。\(err)")
                return
            }
            print("フォロー情報の取得に成功しました。")
            for document in shapshot!.documents {
                let data = document.data()
                let follow = Message(dic: data)
                print(follow.uid)
                if follow.uid == self.delegate.selectuid?.uid {
                    print("フォロー済みです")
                    return
                } else {
                    self.follow(selectuid: self.delegate.selectuid?.uid ?? "")
                    return
                }
            }
            
            
        }
    }
    private func follow(selectuid:String){
            var user: User!
            let uid = Auth.auth().currentUser?.uid
            let userRef = Firestore.firestore().collection("users").document(uid ?? "").collection("follow").document()
            let docData = ["uid": selectuid,
                           "name": delegate.selectuid?.name
            ]
    
            userRef.setData(docData){ (err) in
                print("Firebaseへの保存に失敗しました。\(err)")
                return
    
            }
            print("Firebaseへの保存に成功しました")
    
    
            let userR = Firestore.firestore().collection("users").document(uid ?? "")
            userR.getDocument { snapshot, err in
                if let err = err {
                    print("ユーザー情報の取得に失敗しました。\(err)")
                    return
                }
                print("ユーザー情報の取得に成功しました。")
                guard let data = snapshot?.data() else {return}
                let user = User(dic: data)
                let selectUserRef = Firestore.firestore().collection("users").document(selectuid).collection("follower").document()
                let docData2 = ["uid": uid,
                                "name": user.name
                ]
    
                selectUserRef.setData(docData2){(err) in
                    print(docData2)
                    print("Firebaseへの保存に失敗しました。\(err)")
                    return
                }
                print("Firebaseへの保存に成功しました")
    
            }
    
        }
        
                
        
          
    
}

extension SelectYouserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = selectYouserPostTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SelectYouserTableViewCell
        
        cell.post = posts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
    
    
}
