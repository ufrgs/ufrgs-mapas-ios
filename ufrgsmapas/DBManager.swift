//
//  DBManager.swift
//  ufrgsmapas
//
//  Created by Augusto Boranga on 19/02/19.
//  Copyright © 2019 UFRGS. All rights reserved.
//

import Foundation
import RealmSwift

class DBManager {
    
    private let realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    func getAllBuildings() -> [Building] {
        return Array(realm.objects(Building.self))
    }
    
    func getBuildingsByNameOrNumber(query : String) -> [Building] {
        
        if query == "" {
            return getAllBuildings()
        }
        
        let q = query.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        
        let filtered = getAllBuildings().filter({
            return $0.name.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(q) || $0.ufrgsCode.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(q)
        })
        
        return filtered
    }
    
    func isEmpty() -> Bool {
        return getAllBuildings().count == 0
    }
    
    func save(buildings: [Building]) {
        // remove all previous data
        deleteAll()
        
        // save each building
        for b in buildings {
            save(b)
        }
    }
    
     func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    private func save(_ b: Building) {
        try! realm.write {
            realm.add(b)
        }
    }
    
}
