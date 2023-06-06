//
//  SelectYouserPostTableViewCell.swift
//  NPB
//
//  Created by 小松拓海 on 2023/06/03.
//

import UIKit
import Firebase
import FirebaseFirestore

class SelectYouserTableViewCell: UITableViewCell {
    
    var post: Post?
    @IBOutlet weak var selectPostImageView: UIImageView!
    @IBOutlet weak var selectYouserLabel: UILabel!
    @IBOutlet weak var selectTextView: UITextView!
    @IBOutlet weak var selectImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectImageView.layer.cornerRadius = 30
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setPostData()
    }
    
    private func setPostData(){
        selectTextView.text = post?.post
        
        guard let url = URL(string: post?.url ?? "") else { return }
        do{
            let data = try URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let imageData = data else {return}
                DispatchQueue.main.async {
                    self.selectPostImageView.image = UIImage(data: imageData)
                }
                
            }.resume()
        }catch{
            print("nothing to do")
        }
        selectYouserLabel.text = post?.name
    }
    
}
