//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 26.11.2021.
//

import UIKit
import RealmSwift

class TableViewController: UITableViewController {
    // Используем объект типа Results для отображения в интерфейсе в реальном времени объектов хранящихся в базе данных
    var places: Results<Place>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Отрбражаем на экране данные
        places = realm.objects(Place.self)
    }
    

// MARK: - TableView data source
    
    // Количесво ячеек в таблице
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    // Содержание ячейки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Создаем ячеку и приводим к классу кастомной ячеки
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        // Добавляем в ячеку по индексу информацию из массива citysName
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.descriptionLabel.text = place.myDescription

        // Добавляем в ячейку изображение
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        // Делаем изображение в ячейке круглым
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true



        return cell
    }
    
    // Объявляем метод, который при нажатии на кнопку сохранения выводит нас на главный экран при помощи сигвея
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        // Передаем данные из редактируемого вью контроллера на главный и сохраняем внесенные данные
        guard let newPlaceVC = segue.source as? EditPlaceTableViewController else { return }
        newPlaceVC.savePlace()
        // Обнавляем измененный интерфейс
        tableView.reloadData()
    }
    
    // MARK: Table view delegate
    // Метод выхывает пункты меню свайпом по ячейки с права на лево
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Определяем объект для удаления
        let place = places[indexPath.row]
        // Определяем действие при свайпе
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (_, _, _) in
            // Удаляем объект из базы
            StorageManager.deleteObject(place)
            // Удаляем саму строку
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        // Задаем действие свайпу
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeAction
    }
    
    //MARK: Navigation
    
    // При нажатии на ячеку будет выводиться экран редактирования, но уже с переданной туда информацией имеющейся в ячейке
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDeteil" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let newPlaceVC = segue.destination as! EditPlaceTableViewController
            newPlaceVC.currentPlace = places[indexPath.row]
        }
    }

}
