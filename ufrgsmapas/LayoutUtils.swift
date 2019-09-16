//
//  LayoutUtils.swift
//  ufrgsmapas
//
//  Created by Theo on 11/01/16.
//  Copyright © 2016 UFRGS. All rights reserved.
//

import UIKit

class LayoutUtils: NSObject {
    
    static let mainColor = UIColor(red: 53/255.0, green: 132/255.0, blue: 217/255.0, alpha: 1.0)
    static let secondaryColor = UIColor(red: 195/255.0, green: 224/255.0, blue: 254/255.0, alpha: 1.0)
    
    static func setSearchCancelButtonColor(color: UIColor) {
        
        let cancelButtonAttributes: NSDictionary = [NSAttributedString.Key.foregroundColor: color]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [NSAttributedString.Key : Any], for: .normal)
    
    }

}
