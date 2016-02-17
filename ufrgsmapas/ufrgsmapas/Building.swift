//
//  Building.swift
//  ufrgsmapas
//
//  Created by Theo on 13/01/16.
//  Copyright © 2016 UFRGS. All rights reserved.
//

class Building: NSObject {
    
    var id : Int32 = 0
    var title: String = ""
    var subTitle: String = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var ufrgsBuildingCode : String = ""
    var addressName : String = ""
    var addressNumber : String = ""
    var zipCode : String = ""
    var neighborhood : String = ""
    var city : String = ""
    var state : String = ""
    var campus : String = ""
    var isHistorical : Bool = false
    
}
