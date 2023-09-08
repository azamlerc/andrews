//
//  place.swift
//  andrewzc
//
//  Created by Andrew Zamler-Carhart on 7/29/23.
//

import Foundation

// var placeIndex = [String:Place]()
var placeFiles = [HTMLFile]()

class Place: Entity {
    var been = false
    var country: Country?
    
    override init(row: Row) {
        super.init(row: row)
    }
    
    override init(icon: String, name: String) {
        super.init(icon: icon, name: name)
    }
    
    override func htmlString() -> String {
        var iconHtml = icons.joined(separator: " ")
        if !been {
            iconHtml = "<span class=\"todo\">\(iconHtml)</span>"
        }
        let classHtml = strike ? " class=\"strike\"" : ""
        let nameHtml = link == nil ? name : "<a href=\"\(link!)\"\(classHtml)>\(name)</a>"
        var line = "\(iconHtml) \(nameHtml)\(info ?? "")<br>\n"
        if prefix != nil {
            line = "\(prefix!) \(line)"
        }
        return line
    }
}

func loadPlaces(key: String) {
    guard !key.hasPrefix("http") else {
        return
    }
    let placesFile = HTMLFile(key: key)
    placeFiles.append(placesFile)
    let placeGroups = placesFile.rowGroups.map { group in
        return group.map { row in
            let place = Place(row: row) // Place.getPlace(row: row)
            
            var icon = row.icon
            if row.comment != nil && row.comment!.count == 1 { // handle vanity emoji with country in comment
                icon = row.comment!
            }
            if let country = Country.getCountry(icon: icon) {
                place.country = country
                country.add(place: place, key: key)
            } else {
                if !["🌎", "🌍", "🌊"].contains(row.icon) && icon != "" {
                    print("Not a country: \(icon) \(row.name)")
                }
            }

            while (place.name.first?.isEmoji() ?? false) {
                let otherIcon = String(place.name.first!)
                place.icons.append(otherIcon)
                place.name = place.name.substring(from: 1).trim()

                if let otherCountry = Country.getCountry(icon: otherIcon) {
                    otherCountry.add(place: place, key: key)
                }
            }
            
            return place
        }
    }
    if placeGroups.count > 0 {
        placeGroups[0].forEach { $0.been = true }
        
        if placeGroups.count > 1 && middleSectionBeen.contains(key) {
            placeGroups[1].forEach { $0.been = true }
        }
    } else {
        print("No row groups: \(key)")
    }
    let places = placeGroups.flatMap { $0 }
    placesFile.entities = places
}

