//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 26.11.2021.
//

import UIKit

class TableViewController: UITableViewController {
    
    var places = Place.getPlaces()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

// MARK: - TableView data source
    
    // Количесво ячеек в таблице
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    // Содержание ячейки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Создаем ячеку и приводим к классу кастомной ячеки
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        // Добавляем в ячеку по индексу информацию из массива citysName
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.descriptionLabel.text = place.description
        
        // Добавляем в ячейку изображение
        if place.image == nil {
            cell.imageOfPlace.image = UIImage.init(named: place.cityImage!)
        } else {
            cell.imageOfPlace.image = place.image
        }
        
        // Делаем изображение в ячейке круглым
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
    
        
        
        return cell
    }
    
    // Объявляем метод, который при нажатии на кнопку сохранения выводит нас на главный экран при помощи сигвея
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        // Передаем данные из редактируемого вью контроллера на главный и сохраняем внесенные данные
        guard let newPlaceVC = segue.source as? EditPlaceTableViewController else { return }
        newPlaceVC.saveNewPlace()
        // Добавляем новый обьект в массив
        places.append(newPlaceVC.newPlace!)
        // Обнавляем измененный интерфейс
        tableView.reloadData()
    }
    

}
