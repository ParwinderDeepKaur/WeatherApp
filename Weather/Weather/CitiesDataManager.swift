//
//  ContactsDataManager.swift
//  Phone Book
//
//  Created by Appsmartz on 16/12/21.
//

import Foundation

class CitiesDataManager {
    
    func saveCurrentCity(city:City) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(city) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedCurrentCity")
        }
    }
    
    func getCurrentCity() -> City? {
        let defaults = UserDefaults.standard
        if let city = defaults.object(forKey: "SavedCurrentCity") as? Data {
            let decoder = JSONDecoder()
            if let tmp_city = try? decoder.decode(City.self, from: city) {
                return tmp_city
            }
        }
        return nil
    }
    
    func clearCurrentCity() {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "SavedCurrentCity")
    }
    
    func writeData(city:City) {
        var cities = getData()
        cities.append(city)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(cities) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedCities")
        }
    }
    
    func removeData()  {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "SavedCities")
    }
    
    func getData() -> Cities {
        let defaults = UserDefaults.standard
        if let savedCities = defaults.object(forKey: "SavedCities") as? Data {
            let decoder = JSONDecoder()
            if let cities = try? decoder.decode(Cities.self, from: savedCities) {
                return cities
            }
        }
        return []
    }
    
    func delete(city:City) {
        var cities = getData()
        var index = 0
        for tmp_city in cities {
            if city.name == tmp_city.name && city.state == tmp_city.state && city.country == tmp_city.country {
                cities.remove(at: index)
                break
            }
            index = index + 1
        }
    }
    
    func isFound(city:City) -> Bool {
        let cities = getData()
        for tmp_city in cities {
            if city.name == tmp_city.name && city.state == tmp_city.state && city.country == tmp_city.country {
                return true
            }
        }
        return false
    }
}
