//
//  MapAndLocationUtils.swift
//  ufrgsmapas
//
//  Created by Theo on 11/01/16.
//  Copyright © 2016 UFRGS. All rights reserved.
//

import UIKit
import MapKit

class MapAndLocationUtils: NSObject {
    
    static func centerMapOnUser (location: CLLocation, map: MKMapView) {
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        map.setRegion(region, animated: true)
    }
    

}
