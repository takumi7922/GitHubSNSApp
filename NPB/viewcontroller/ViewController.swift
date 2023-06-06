//
//  h.swift
//  NPB
//
//  Created by 小松拓海 on 2023/04/24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD

//ユーザー情報を受け取った時にそのままの形だと分かりずらいので、モデルを作っとく。

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImageButton: UIButton!
    
    private func handleAuthToFirebase(){
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        // guard letで値がnilだった処理をかけるようにしてる。今回はreturnするだけ
        HUD.show(.progress)
        
        Auth.auth().createUser(withEmail: email, password: password){(res, err) in
            if let err = err{
                print("認証の処理に失敗しました\(err)")
                HUD.hide()
                return
            }
            self.addUserInfoToFirestore(email: email)
            
            
        }
    }

    
    private func addUserInfoToFirestore(email: String){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let name = self.usernameTextField.text else {return}
        
        guard let image = profileImageButton.imageView?.image else {return}
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else {return}
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("firestoregeへの保存に失敗しました\(err)")
                return
            }
            
            print("firestorageへの保存に成功しました。")
            storageRef.downloadURL {(url, err) in
                if let err = err {
                    print("firestorageからのダウンロードに失敗しました\(err)")
                    return
                }
                
                let urlString = url!.absoluteString
                print("urlString", urlString)
                
                var user: User!
                let userRef =  Firestore.firestore().collection("users").document(uid)
                
                let docData = ["email": email, "name": name, "createAt": Timestamp(), "urlString": urlString] as [String: Any]
                
                
                userRef.setData(docData){(err) in
                    if let err = err{
                        print("Firestoreへの保存に失敗しました。\(err)")
                        HUD.hide()

                        return
                    }
                    print("Firestoreへの保存に成功しました。")
                    HUD.hide()

                    
                    userRef.getDocument {(snapshot, err) in
                        if let err = err{
                            print("ユーザー情報の取得に失敗しました。\(err)")
                            return
                        }
                        guard let data = snapshot?.data() else {return}
                        let user = User.init(dic: data) //うえで作ったモデルの形にdataを変形してる
                        
                        
                        
                        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
                        
                        let homeViewController = storyBoard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
                        homeViewController.user = user
                        let chatViewController = storyBoard.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
                        self.present(chatViewController, animated: true, completion: nil)
                        
                    }
                    
                }
            }
        }
        
        
        //データベースのコレクションをusersに指定。次にドキュメントのidを指定。ここをuserのuidを指定する
        
        
        
    }
    
    @IBAction func tappedRegisterButton(_ sender: Any) {
        handleAuthToFirebase()
        
    }
    
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        profileImageButton.layer.cornerRadius = 30
        
        
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageButton.imageView?.contentMode = .scaleToFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
}

class object: NSObject {
    //頭にstatic
    //現クラスのインスタンスを代入
    static let instance = object().getuid()
    private func getuid(){
        let uid = Auth.auth().currentUser?.uid ?? "dd"
        var user: User!
        let userRef =  Firestore.firestore().collection("users").document(uid)
        
        userRef.getDocument {(snapshot, err)  in
            if let err = err{
                print("ユーザー情報の取得に失敗しました。\(err)")
                    
            }
            guard let data = snapshot?.data() else {return}
            user = User.init(dic: data) //うえで作ったモデルの形にdataを変形してる
            print("ユーザー情報の取得ができました。\(user.name)")
        }

        

    }
}

