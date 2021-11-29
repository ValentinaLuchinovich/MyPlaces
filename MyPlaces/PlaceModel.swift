//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 28.11.2021.
//

import UIKit

struct Place {
    var name: String
    var location: String?
    var description: String?
    var image: UIImage?
    var cityImage: String?
    
    static let citysNames = ["Санкт-Петербург", "Барселона", "Москва", "Стокгольм"]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        for place in citysNames {
            places.append(Place(name: place, location: "Уфа", description: "Экскурсия", image: nil, cityImage: place))
        }
        return places
    }
}
