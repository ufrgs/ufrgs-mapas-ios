//
//  BuildingTableViewCell.swift
//  ufrgsmapas
//
//  Created by Augusto Boranga on 26/02/19.
//  Copyright © 2019 UFRGS. All rights reserved.
//

import Foundation
import UIKit

class BuildingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buildingNumberLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    func configure(_ building: Building, isLastItem: Bool) {
        nameLabel.text = building.name
        buildingNumberLabel.text = "Prédio \(building.ufrgsCode)"
        addressLabel.text = "\(building.addressStreet), \(building.addressNumber)"
        cityLabel.text = "CEP: \(building.zipCode)"
        
        selectionStyle = .none
        separator.isHidden = isLastItem
        
    }
    
}
