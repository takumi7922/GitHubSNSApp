//
//  ChatInputView.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/06.
//

import UIKit

protocol ChatInputViewDelegate: class {
    func tappedSendButton(text: String)
}

//viewをxibで作るときはfile's ownerで連携させる
class ChatInputView: UIView{

    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = chatTextView.text else { return }
        delegate?.tappedSendButton(text: text)
        
    }
    
    weak var delegate: ChatInputViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setupViews()
        
    }
    
    private func setupViews(){
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        
        chatTextView.text = ""
        chatTextView.delegate = self
    }
    
    func removeText(){
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
    
    private func nibInit(){
        let nib = UINib(nibName: "ChatInputView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {return}
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
}
