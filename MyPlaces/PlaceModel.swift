//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 28.11.2021.
//

import RealmSwift
import UIKit

class Place: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var myDescription: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    
    convenience init(name: String, location: String?, myDescription: String?, imageData: Data?) {
        self.init()
        self.name = name
        self.location = location
        self.myDescription = myDescription
        self.imageData = imageData
    }
}
