//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 30.11.2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    // Mетод для сохранения объектов в базу данных с типом Place
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    // Метод удаления объектов из базы данных
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
