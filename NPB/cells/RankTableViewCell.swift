//
//  RankTableViewCell.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/10.
//

import UIKit

class RankTableViewCell: UITableViewCell {
    @IBOutlet weak var differenceCountLabel: UILabel!
    @IBOutlet weak var evenCountLabel: UILabel!
    @IBOutlet weak var loseCountLabel: UILabel!
    @IBOutlet weak var gameCountLabel: UILabel!
    @IBOutlet weak var winCountLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
