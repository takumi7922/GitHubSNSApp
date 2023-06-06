//
//  SignInViewController.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/06.
//

import UIKit
import Firebase
import FirebaseAuth
import PKHUD

class SignInViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pushLogInButton(){
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        HUD.show(.progress)
            
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            HUD.hide()
            guard let self = self else { return }
            if let user = result?.user {
                let storyBoard = UIStoryboard(name: "Home", bundle: nil)
                
                let homeViewController = storyBoard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
                let chatViewController = storyBoard.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
//                self.present(chatViewController, animated: true, completion: nil)
                navigationController?.pushViewController(chatViewController, animated: true)
            }
                
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
