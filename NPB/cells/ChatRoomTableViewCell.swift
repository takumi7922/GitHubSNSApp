//
//  ChatRoomTableViewCell.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/06.
//

import UIKit
import Firebase
import FirebaseAuth
import Nuke

protocol ChatRoomTableViewCellDelegate {
    //func customCellDelegateDidTapButton(cell: ChatRoomTableViewCell)
    func tappedImageButton(targetCell: UITableViewCell, targetButton: UIButton)
}

class ChatRoomTableViewCell: UITableViewCell{
    
    var delegate: ChatRoomTableViewCellDelegate?
    var user: User?
    var message: Message? {
        didSet {
//            if let message = message {
//                messageTextView.text = message.message
//                dateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
//
//            }
        }
    }

    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageViewButton: UIButton!
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 30
        messageTextView.layer.cornerRadius = 15
        myMessageTextView.layer.cornerRadius = 15
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhichUserMessage()
    }
    
    
    @IBAction func tappedImageButton(button: UIButton) {
        self.delegate?.tappedImageButton(targetCell: self, targetButton: button)
    }
    
//    @IBAction func tappedTextButton(button: UIButton) {
//        self.delegate?.tappedTextButton(targetCell: self, targetButton: button)
//    }
    
    private func checkWhichUserMessage() {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            if uid == message?.uid {
                messageTextView.isHidden = true
                dateLabel.isHidden = true
                userImageView.isHidden = true
                userImageViewButton.isHidden = true
                userNameLabel.isHidden = true
                
                myMessageTextView.isHidden = false
                myDateLabel.isHidden = false
                
                if let message = message {
                    myMessageTextView.text = message.message
                    let width = estimateFrameForTextView(text: message.message).width + 20
                    myMessageTextViewWidthConstraint.constant = width
                    
                    myDateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                }
            } else {
                messageTextView.isHidden = false
                dateLabel.isHidden = false
                userImageViewButton.isHidden = false
                userImageView.isHidden = false
                userNameLabel.isHidden = false
                
                myMessageTextView.isHidden = true
                myDateLabel.isHidden = true
                
                if let message = message {
                    messageTextView.text = message.message
                    let width = estimateFrameForTextView(text: message.message).width + 20
                    messageTextViewWidthConstraint.constant = width
                    dateLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                }
                print("ユーザurl",message?.urlString)
                userNameLabel.text = message?.name
                guard let url = URL(string: message?.urlString ?? "") else {return}
                do{
                    let data = try URLSession.shared.dataTask(with: url) { (data, response, error) in
                        guard let imageData = data else {return}
                        DispatchQueue.main.async {
                            self.userImageView.image = UIImage(data: imageData)
                        }
                        
                    }.resume()
                }catch{
                    print("nothing to do")
                }
            }
            
        }
    
    private func estimateFrameForTextView(text: String) -> CGRect {
            let size = CGSize(width: 200, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            
            return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
        }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
