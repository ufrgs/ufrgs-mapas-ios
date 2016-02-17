//
//  DBManager.swift
//  ufrgsmapas
//
//  Created by Theodoro L. Mota on 1/20/16.
//  Copyright © 2016 UFRGS. All rights reserved.
//

import UIKit
import MapKit

class DBManager: NSObject {
    
    static func getAllPins() -> Array<PinPosition> {
        var arrayOut = [PinPosition]()
        
        let path = NSBundle.mainBundle().pathForResource("buildings", ofType: ".db")
        let db : FMDatabase = FMDatabase(path: path)
        
        if !db.open() {
            print("Unable to open database")
            return arrayOut
        } else {
            print(db.databasePath())
        }
        
        if let rs = db.executeQuery("SELECT _id, name,ufrgsBuildingCode , latitude, longitude FROM buildings", withArgumentsInArray: nil) {
            while rs.next() {
                
                let tempPin = PinPosition(id: rs.intForColumn("_id"),
                    title: rs.stringForColumn("name"),
                    buildingNum: rs.stringForColumn("ufrgsBuildingCode"),
                    coordinate: CLLocationCoordinate2D(latitude: rs.doubleForColumn("latitude"), longitude: rs.doubleForColumn("longitude")),
                    starred: false)
                
                arrayOut.append(tempPin)
            }
            
        } else {
            print("executeQuery failed: \(db.lastErrorMessage())")
        }
        
        db.close()

        return arrayOut
        
    }
    
    static func getBuildingById(id : Int32) -> Building {
        
        var building = Building()
        
        let path = NSBundle.mainBundle().pathForResource("buildings", ofType: ".db")
        let db : FMDatabase = FMDatabase(path: path)
        
        if !db.open() {
            print("Unable to open database")
            return building
        } else {
            print(db.databasePath())
        }
        
        
        if let rs = db.executeQuery("SELECT * FROM buildings WHERE _id = " + String(id), withArgumentsInArray: nil) {
            while rs.next() {
                building.id = id
                building.latitude = rs.doubleForColumn("latitude")
                building.longitude = rs.doubleForColumn("longitude")
                building.title = rs.stringForColumn("name")
                building.ufrgsBuildingCode = rs.stringForColumn("ufrgsBuildingCode")
                building.addressName = rs.stringForColumn("addressName")
                building.addressNumber = rs.stringForColumn("addressNumber")
                building.zipCode = rs.stringForColumn("zipCode")
                //building.neighborhood = rs.stringForColumn("neighborhood")
                building.city = rs.stringForColumn("city")
                building.state = rs.stringForColumn("state")
                
                let camp = rs.intForColumn("campus")
                
                switch camp {
                    
                case 0:
                    building.campus = "Sem Campus"
                    break
                case 1:
                    building.campus = "Campus Centro"
                    break
                case 2:
                    building.campus = "Campus Saúde"
                    break
                case 3:
                    building.campus = "Campus ESEF"
                    break
                case 4:
                    building.campus = "Campus Vale"
                    break
                case 6:
                    building.campus = "Campus Litoral"
                    break
                default:
                    building.campus = "Sem Campus"
                    break
                    
                }
                
                building.isHistorical = rs.boolForColumn("isHistorical")
                
            }
            
        } else {
            print("executeQuery failed: \(db.lastErrorMessage())")
        }
        
        db.close()
        
        return building
        
    }
    
    static func getBuildingsByNameOrNumber(query : String) -> Array<PinPosition> {
        var arrayOut = [PinPosition]()
        
        let path = NSBundle.mainBundle().pathForResource("buildings", ofType: ".db")
        let db : FMDatabase = FMDatabase(path: path)
        
        if !db.open() {
            print("Unable to open database")
            return arrayOut
        } else {
            print(db.databasePath())
        }
        
        let query : String = "SELECT _id, name, ufrgsBuildingCode, latitude, longitude FROM buildings WHERE ufrgsBuildingCode LIKE '" + query + "%' OR name LIKE '%" + query + "%'"
        
        
        if let rs = db.executeQuery(query, withArgumentsInArray: nil) {
            while rs.next() {
                let tempPin = PinPosition(id: rs.intForColumn("_id"),
                    title: rs.stringForColumn("name"),
                    buildingNum: rs.stringForColumn("ufrgsBuildingCode"),
                    coordinate: CLLocationCoordinate2D(latitude: rs.doubleForColumn("latitude"), longitude: rs.doubleForColumn("longitude")),
                    starred: false)
            
                arrayOut.append(tempPin)
            }
            
        } else {
            print("executeQuery failed: \(db.lastErrorMessage())")
        }
        
        db.close()

        return arrayOut
    }
}
