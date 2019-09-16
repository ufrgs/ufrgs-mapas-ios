//
//  Pin.swift
//  ufrgsmapas
//
//  Created by Augusto Boranga on 19/02/19.
//  Copyright © 2019 UFRGS. All rights reserved.
//

import Foundation
import MapKit

class Pin: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var buildings = [Building]()
    var title: String?
    
    init(title: String, lat: Double, long: Double) {
        self.title = title
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
}
