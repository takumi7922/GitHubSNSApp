//
//  ChatListTableViewCell.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/20.
//

import UIKit

class ChatViewCell: UITableViewCell{

    
    
    @IBOutlet weak var tekiLabel: UILabel!
    @IBOutlet weak var tekiScoreLabel: UILabel!
    @IBOutlet weak var mikataScoreLabel: UILabel!
    @IBOutlet weak var mikataLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
