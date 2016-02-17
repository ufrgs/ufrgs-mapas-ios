//
//  PinPosition.swift
//  ufrgsmapas
//
//  Created by Theodoro L. Mota on 1/20/16.
//  Copyright © 2016 UFRGS. All rights reserved.
//

import MapKit

class PinPosition: NSObject, MKAnnotation {
    
    let id : Int32
    let title : String?
    let coordinate: CLLocationCoordinate2D
    var starred : Bool
    var buildingNumber : String
    
    init(id: Int32, title: String, buildingNum: String, coordinate: CLLocationCoordinate2D, starred: Bool ) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
        self.starred = starred
        self.buildingNumber = buildingNum
        
        super.init()
    }

}
