//
//  HomeViewController.swift
//  NPB
//
//  Created by 小松拓海 on 2023/04/26.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    var user: User?
    var window: UIWindow?
    
    private let cellId = "cellId"
    private var posts = [Post]()
    
//    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabelButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var myPostTableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func tappedLogOutButton(){
//        guard let scene = (scene as? UIWindowScene) else {return}
//        window = UIWindow(windowScene: scene as! UIWindowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        navigationController?.pushViewController(rootViewController, animated: true)
        rootViewController.navigationItem.hidesBackButton = true
        do {
            try Auth.auth().signOut()
        }
        catch let err as NSError {
            print(err)
        }
    }
    
    @IBAction func tappedCrossButton(){
        
        let chatViewController = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    let uid = Auth.auth().currentUser?.uid ?? "dd"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPostTableView.dataSource = self
        myPostTableView.delegate = self
        
        
        myPostTableView.register(UINib(nibName: "MyPostTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        var user: User!
        let userRef =  Firestore.firestore().collection("users").document(self.uid)
        
        userRef.getDocument {(snapshot, err)  in
            if let err = err{
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
                
            }
            guard let data = snapshot?.data() else {return}
            user = User(dic: data)
            print(user.name)
            //うえで作ったモデルの形にdataを変形してる
            print("ユーザー情報の取得ができました。\(user.urlString)")
            
            self.nameLabelButton.setTitle(user?.name, for: .normal)
            //self.emailLabel.text = user?.email
            let dateString = self.dateFormatterForCreatedAt(date: user.createdAt.dateValue())
            //self.dateLabel.text = dateString
            guard let url = URL(string: user?.urlString ?? "") else { return }
            do{
                let data = try URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let imageData = data else {return}
                    DispatchQueue.main.async {
                        self.profileImage.image = UIImage(data: imageData)
                    }
                    
                }.resume()
            }catch{
                print("nothing to do")
            }
            
            
        }
        profileImage.layer.cornerRadius = 40
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        
        getMyPost()
    
        
        
        // Do any additional setup after loading the view.
    }
    
    private func getMyPost(){
        
        Firestore.firestore().collection("posts").whereField("uid", isEqualTo: self.uid).addSnapshotListener { snapshot, err in
            if let err = err {
                print("投稿情報の取得に失敗しました。\(err)")
                return
            }
            snapshot?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()

                    let post = Post(dic: dic)
                    self.posts.append(post)
                    
                    self.posts.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    
                    self.myPostTableView.reloadData()
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
    
    
    
    private func dateFormatterForCreatedAt(date: Date)-> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    
    
    

}



extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myPostTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MyPostTableViewCell

        cell.post = posts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
    
    
}
