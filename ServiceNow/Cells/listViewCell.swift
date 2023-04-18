//
//  listViewCell.swift
//  ServiceNow
//
//  Created by Anmol Narang on 14/04/23.
//

import UIKit

class listViewCell: UITableViewCell {
    @IBOutlet weak var lblStatus: UILabel!{
        didSet{
            self.lblStatus.isHidden = true
        }
    }
    @IBOutlet weak var postedDate: UILabel!
    @IBOutlet weak var serviceTitle: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var storeLocation: UILabel!
    @IBOutlet weak var servicePrice: UILabel!
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var serviceDesc: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
