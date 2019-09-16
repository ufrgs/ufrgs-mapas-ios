//
//  AlertUtils.swift
//  ufrgsmapas
//
//  Created by Augusto Boranga on 21/02/19.
//  Copyright © 2019 UFRGS. All rights reserved.
//

import Foundation
import UIKit

class AlertUtils {
    
    static func createSimpleAlert(title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        
        return alert
        
    }
    
}
