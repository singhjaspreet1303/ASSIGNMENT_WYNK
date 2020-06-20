//
//  SuggestionTableViewCell.swift
//  Assignment
//
//  Created by Jaspreet Singh on 20/06/20.
//  Copyright © 2020 Jaspreet Singh. All rights reserved.
//

import UIKit

class SuggestionTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(withTitle title: String) {
        self.textLabel?.text = title
        self.contentView.backgroundColor = .lightGray
    }

}
