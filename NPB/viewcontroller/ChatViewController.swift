//
//  ChatViewController.swift
//  NPB
//
//  Created by 小松拓海 on 2023/04/28.
//

import UIKit
import Alamofire
import Kanna
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    var user: User!
    private let cellId = "cellId"
    let games = ["ソフトバンク", "楽天", "ライオンズ", "ロッテ", "オリックス", "日本ハム"]
    var teams = [String]()
    var scores = [String]()
    
    let uid = Auth.auth().currentUser?.uid ?? "dd"
    
    var delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var chatTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.register(UINib(nibName: "ChatViewCell", bundle: nil), forCellReuseIdentifier: "cellId")
        
        var user : User!
        
        delegate.gameuid = nil
        fetchNPBInfo(url: "https://www.nikkansports.com/baseball/professional/score/")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.chatTableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    private func fetchNPBInfo(url: String) -> Void {
        AF.request(url).responseString{ response in
            if let html = response.value {
                if let doc = try? HTML(html: html, encoding: String.Encoding.utf8){
                    self.teams = [String]()
                    self.scores = [String]()
                    for team in doc.xpath("//td[@class='team']") {
                        self.teams.append(team.text ?? "")
                    }
                    for score in doc.xpath("//td[@class='totalScore']"){
                        self.scores.append(score.text ?? "")
                    }
                    print(self.teams)
                    print(self.scores)
                    
                }
            }
        }
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count / 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ChatViewCell
        if indexPath.row < 6 {
            cell.mikataLabel.text = teams[indexPath.row*2]
            cell.mikataScoreLabel.text = scores[indexPath.row*2]
            cell.tekiLabel.text = teams[indexPath.row*2 + 1]
            cell.tekiScoreLabel.text = scores[indexPath.row*2 + 1]
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toChat", sender: nil)

        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let uid = Auth.auth().currentUser?.uid else { return  }
        
        var uidCol: [String] = []
        uidCol.append(uid)
        let gameuid = String(indexPath.row) + "game"
        delegate.gameuid = gameuid
        
        let gameRef = Firestore.firestore().collection("games").document(gameuid)
        gameRef.getDocument { snapshot, err in
            if let err = err {
                print("ゲーム情報の取得に失敗しました。\(err)")
            }
            
            guard let data = snapshot?.data() else {return}
            print(data)
        }
        
       gameRef.updateData([
        "uid": FieldValue.arrayUnion([uid])
       ])
    }
    
    
}
