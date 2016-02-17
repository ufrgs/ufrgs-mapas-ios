//
//  LayoutUtils.swift
//  ufrgsmapas
//
//  Created by Theo on 11/01/16.
//  Copyright © 2016 UFRGS. All rights reserved.
//

import UIKit

class LayoutUtils: NSObject {
    
    static func setSearchCancelButtonColor(color: UIColor) {
        
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: color]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], forState: UIControlState.Normal)
    
    }

}
