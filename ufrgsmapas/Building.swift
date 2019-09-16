//
//  Building.swift
//  ufrgsmapas
//
//  Created by Augusto Boranga on 21/02/19.
//  Copyright © 2019 UFRGS. All rights reserved.
//

import Foundation
import RealmSwift

class Building: Object {
    
    // MARK: - Properties
    
    @objc dynamic var code: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var ufrgsCode: String = ""
    @objc dynamic var campusCode: Int = 0
    @objc dynamic var campusName: String = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var addressStreet: String = ""
    @objc dynamic var addressNumber: Int = 0
    @objc dynamic var addressCity: String = ""
    @objc dynamic var zipCode: String = ""
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var email: String = ""
    
}
