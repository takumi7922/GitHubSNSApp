//
//  AllPostTableViewCell.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/24.
//

import UIKit
import Firebase
import FirebaseFirestore

class AllPostTableViewCell: UITableViewCell {
    var post: Post?
    
    @IBOutlet var myImageView: UIImageView!
    @IBOutlet var myTextView: UITextView!
    @IBOutlet var myPostImageView: UIImageView!
    @IBOutlet var myNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        myImageView.layer.cornerRadius = 30
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setPostData()
    }
    
    private func setPostData(){
        myTextView.text = post?.post
        
        guard let url = URL(string: post?.url ?? "") else { return }
        do{
            let data = try URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let imageData = data else {return}
                DispatchQueue.main.async {
                    self.myPostImageView.image = UIImage(data: imageData)
                }
                
            }.resume()
        }catch{
            print("nothing to do")
        }
        myNameLabel.text = post?.name
    }
    
}



