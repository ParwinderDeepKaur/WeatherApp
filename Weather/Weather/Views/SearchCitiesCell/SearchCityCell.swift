//
//  SearchCityCell.swift
//  Weather
//
//  Created by Pavitram on 20/04/22.
//

import UIKit

class SearchCityCell: UITableViewCell {
    
    static let identifier = "SearchCityCell"
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_address: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
