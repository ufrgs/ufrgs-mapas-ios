//
//  BuildingsFetcher.swift
//  ufrgsmapas
//
//  Created by Augusto Boranga on 21/02/19.
//  Copyright © 2019 UFRGS. All rights reserved.
//

import MapKit
import Foundation
import UIKit

class BuildingsFetcher {
    
    func run (completion: @escaping ([Building]) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            
            var buildings = [Building]()
            let url = URL(string: "https://www1.ufrgs.br/ws/siteufrgs/getpredios")
            
            do {
                if let buildingsList: [[String: Any]] = try JSONSerialization.jsonObject(with: Data(contentsOf: url!), options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String : Any]] {
                    
                    for item in buildingsList {
                        if let b = self.getBuildingFrom(item) {
                            buildings.append(b)
                        }
                    }
                    
                }
                
                DispatchQueue.main.async {
                    completion(buildings)
                }
                
            }
            catch {
                DispatchQueue.main.async {
                    completion(buildings)
                }
            }
        }
    }
    
    func readJson (completion: @escaping ([Building]) -> ()) {
    
        var buildings = [Building]()
        
        if let path = Bundle.main.path(forResource: "predios", ofType: "json") {
            
            do {
                
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                
                if let buildingsList = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String : Any]] {
                    
                    for item in buildingsList {
                        if let b = self.getBuildingFrom(item) {
                            buildings.append(b)
                        }
                    }
                }
                
            } catch {}
        }
        
        completion(buildings)
    
    }
    
    private func getBuildingFrom(_ json: [String : Any]) -> Building? {
        
        let b = Building()
        
        if let lat = Double(String(describing: json["Latitude"]!)),
            let long = Double(String(describing: json["Longitude"]!)) {

            b.latitude = lat
            b.longitude = long
            b.code = Int(String(describing: json["CodPredio"]!))!
            b.name = String(describing: json["NomePredio"]!)
            b.ufrgsCode = String(describing: json["CodPredioUFRGS"]!)
            b.campusCode = Int(String(describing: json["Campus"]!))!
            b.campusName = String(describing: json["DenominacaoCampus"]!)
            b.addressStreet = String(describing: json["Logradouro"]!)
            b.addressNumber = Int(String(describing: json["NrLogradouro"]!))!
            b.addressCity = String(describing: json["Cidade"]!)
            b.zipCode = String(describing: json["CEP"]!)
            b.phoneNumber = String(describing: json["Telefone"]!)
            b.email = String(describing: json["EMail"]!)
            
            return b

        }
        
        return nil
    }
    
}
