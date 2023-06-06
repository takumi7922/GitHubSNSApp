//
//  ChatRoomViewController.swift
//  NPB
//
//  Created by 小松拓海 on 2023/04/28.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ChatRoomViewController: UIViewController {

    
//    func tappedImageButton(targetCell tableViewCell: UITableViewCell, targetButton button: UIButton) {
//        print("tapped view button")
//    }
    
    
    var chatroom: String!
    private let cellId = "cellId"
    private var messages = [Message]()
    private let accessoryHeght: CGFloat = 100
    private var safeAreaBottom: CGFloat{
        self.view.safeAreaInsets.bottom
    }
    let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    private lazy var chatInputView: ChatInputView = {
        let view = ChatInputView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeght)
        view.delegate = self
        return view
    }()
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate.selectuid = nil
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.contentInset = .init(top: 60, left: 0, bottom: 0, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
        chatRoomTableView.keyboardDismissMode = .interactive
        chatRoomTableView.transform = CGAffineTransform(1, 0, 0, -1, 0, 0)
        
        fetchMessages()
        setupNotification()
        // Do any additional setup after loading the view.
    }
    
    private func setupNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= accessoryHeght { return }
            
            let top = keyboardFrame.height - safeAreaBottom
            let moveY = -top
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            chatRoomTableView.contentInset = contentInset
            chatRoomTableView.scrollIndicatorInsets = contentInset
            chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    
    @objc func keyboardWillHide() {
        chatRoomTableView.contentInset = .init(top: 60, left: 0, bottom: 0, right: 0)
        chatRoomTableView.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
        
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchMessages(){
        
        Firestore.firestore().collection("games").document(delegate.gameuid ?? "").collection("messages").addSnapshotListener { snapshots, err in
            if let err = err {
                print("メッセージ情報の取得に失敗しました\(err)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()

                    let message = Message(dic: dic)
//                    print("message　uid ", message.uid)
//                    self.delegate.selectuid = message.uid
                    self.messages.append(message)
                    
                    self.messages.sort { (m1 , m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    
                    self.chatRoomTableView.reloadData()
//                    self.chatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                    
                case .modified, .removed:
                    print("nothing to de")
                }
            })
        }
        
    }
    
}

extension ChatRoomViewController: ChatInputViewDelegate {
    func tappedSendButton(text: String) {

        var user: User?

        let uid = Auth.auth().currentUser?.uid ?? "dd"
        let userRef =  Firestore.firestore().collection("users").document(uid)
        chatInputView.removeText()

        
        
        userRef.getDocument {(snapshot, err)  in
            if let err = err{
                print("ユーザー情報の取得に失敗しました。\(err)")
                
            }
            guard let data = snapshot?.data() else {return}
            user = User.init(dic: data) //うえで作ったモデルの形にdataを変形してる
            print("Roomユーザー情報の取得ができました。\(user?.name)")
            
            let docData = [
                "name":  user?.name,
                "uid":  uid,
                "message": text,
                "createdAt": Timestamp(),
                "urlString": user?.urlString
            ]
            
            Firestore.firestore().collection("games").document(self.delegate.gameuid ?? "").collection("messages").document().setData(docData) { (err) in
                if let err = err {
                    print("メッセージ情報の保存に失敗しました\(err)")
                }
                print("メッセージの保存に成功しました")
                
            }
            
        }
    
        
        
    }
    
}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource, ChatRoomTableViewCellDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        cell.tag = indexPath.row
        cell.delegate = self
        cell.message = messages[indexPath.row]
//        delegate.selectuid = messages[indexPath.row].uid
        cell.transform = CGAffineTransform(1, 0, 0, -1, 0, 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
        //textviewの長さを優先してtableviewの高さを調整してくれる
    }
    func tappedImageButton(targetCell: UITableViewCell, targetButton: UIButton) {
        print("tapped test button")
        delegate.selectuid = messages[targetCell.tag]
        let selectYouserViewController = self.storyboard?.instantiateViewController(identifier: "SelectYouserViewController") as! SelectYouserViewController
        navigationController?.pushViewController(selectYouserViewController, animated: true)
    }
    
    
}


