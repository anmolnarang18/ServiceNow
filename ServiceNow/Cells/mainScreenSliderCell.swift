//
//  mainScreenSliderCell.swift
//  ServiceNow
//
//  Created by Anmol Narang on 14/04/23.
//

import UIKit

class mainScreenSliderCell: UICollectionViewCell {
    
    @IBOutlet weak var mainImage: UIImageView!{
        didSet{
            self.mainImage.layer.cornerRadius = 5
        }
    }
}
