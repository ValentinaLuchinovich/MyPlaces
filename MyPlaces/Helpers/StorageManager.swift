//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 30.11.2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    // Сохранение объектов в базу данных
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    // Удаление объектов из базы данных
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
