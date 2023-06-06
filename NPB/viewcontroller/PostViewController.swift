//
//  PostViewController.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/14.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PKHUD

class PostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let placeholderImage = UIImage(named: "photo-placeholder")
    let uid = Auth.auth().currentUser?.uid ?? "dd"

    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        postTextView.delegate = self
        
        // 初期状態では投稿ボタンを押せない
        postButton.isEnabled = false

    }
    
    // 投稿ボタンを有効にするか否かを判定する関数
    func confirmContent() {
        if postTextView.text.count > 0 && postImageView.image != UIImage(systemName: "photo") {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
    }
    
    // 選択された写真に対する処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // 選択された写真のデータをpickerImageに入れる
        if let pickerImage = info[.editedImage] as? UIImage {
            
            postImageView.image = pickerImage
            
            picker.dismiss(animated: true, completion: nil)
            
            // 画像とコメントが入力済みかチェック
            confirmContent()
        }
        
    }
  
    // 画像を選択
    @IBAction func selectImage(_ sender: Any) {
        let alertcontroller = UIAlertController(title: "画像選択", message: "投稿する画像を選択してください", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "カメラで撮影する", style: .default) { (action) in
            
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = .camera
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            // カメラを立ち上げる
            self.present(cameraPicker, animated: true, completion: nil)

        }
        
        let albumAction = UIAlertAction(title: "アルバムから選択する", style: .default) { (action) in
            
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = .photoLibrary
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            // アルバムを立ち上げる
            self.present(cameraPicker, animated: true, completion: nil)
            
        }
        
        alertcontroller.addAction(cameraAction)
        alertcontroller.addAction(albumAction)
        alertcontroller.addAction(cancelAction)
        self.present(alertcontroller, animated: true, completion: nil)

    }
    
    // 投稿機能
    @IBAction func post() {
        
        // インジケーターを開始
        HUD.show(.progress, onView: self.view)
        // 画像をファイルストアにアップロード→後にurlをデータストアに保存
        guard let image = postImageView?.image else {return}
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else {return}
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("post_image").child(fileName)
        
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("firestoregeへの保存に失敗しました\(err)")
                return
            }
            
            print("firestorageへの保存に成功しました。")
            storageRef.downloadURL { (url, er) in
                if let er = er {
                    print("firestorageからのダウンロードに失敗しました\(err)")
                    return
                }
                
                let userRef =  Firestore.firestore().collection("users").document(self.uid)
                userRef.getDocument { snapshot, err in
                    if let err = err {
                        print("ユーザー情報の取得に失敗しました。\(err)")
                    }
                    var user: User!
                    let urlString = url!.absoluteString
                    guard let data = snapshot?.data() else {return}
                    user = User.init(dic: data) //うえで作ったモデルの形にdataを変形してる
                    print("テキストデータ：",self.postTextView.text)
                    let docData = [
                        "name":  user?.name,
                        "uid":  self.uid,
                        "url": urlString,
                        "text": self.postTextView.text ?? "o",
                        "createdAt": Timestamp()
                    ]
                    Firestore.firestore().collection("posts").document().setData(docData){ (err) in
                        if let err = err {
                            print("投稿情報の保存に失敗しました。\(err)")
                        }
                        print("投稿情報の保存に成功しました。")
                    }
                    //
                    self.postTextView.text = nil
                    
                }
                
            }
        }
        // インジケーター停止
        HUD.hide(animated: true)
        
        // 保存成功→元に戻す
        self.postTextView.text = nil
        self.postImageView.image = nil
        self.postImageView.image = UIImage(named: "placeholder-human")
        
        // タブをタイムラインに戻す
        self.tabBarController?.selectedIndex = 0
        
        
    }

    // キャンセルボタン
    @IBAction func cancel(_ sender: Any) {
        
        // キーボードが表示されている状態でキャンセルされた場合、キーボードを戻す
//        if postTextView.isFirstResponder == true {
//            postTextView.resignFirstResponder()
//        } else {
//
//        }
//
//        // キャンセルしていいか確認通知
//        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
//            // 入力情報を初期状態に戻す
//            self.postTextView.text = nil
//            self.postImageView.image = UIImage(named: "placeholder-human")
//            // ボタンの可不可を判定し直す
//            self.confirmContent()
//
//        })
//        // キャンセルのキャンセル
//        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
//            alert.dismiss(animated: true, completion: nil)
//        })
//        alert.addAction(okAction)
//        alert.addAction(cancelAction)
//        self.present(alert, animated: true, completion: nil)
        guard let rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "AllPostViewController") as? AllPostViewController else { return  }
        navigationController?.pushViewController(rootViewController, animated: true)
    }
    
    
    // 撮影orアルバムのキャンセル処理
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // textViewの編集検知
    func textViewDidChange(_ textView: UITextView) {
        
        // コメントと画像が追加されているか判定→追加済みなら投稿許可
        confirmContent()
        
    }
    
    //　キーボード設定
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }

}
