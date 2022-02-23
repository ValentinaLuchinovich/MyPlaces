//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 26.11.2021.
//

import UIKit
import RealmSwift

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Поиск. Свойство nil указывает на то, что отображение результатов поиска будет в томже контроллере, где и проходит сам поиск
    private let searchController = UISearchController(searchResultsController: nil)
    // Массив с отфильтроваными записями из поиска
    private var filtredPlaces: Results<Place>!
    // Используем объект типа Results для отображения в интерфейсе в реальном времени объектов хранящихся в базе данных
    private var places: Results<Place>!
    // Сортировка по возрастанию
    private var ascendingSorting = true
    // Свойство проверяет является ли строка поиска пустой
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    // Возвращает true когда поисковый запрос активирован
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var reversedSortingButtom: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Отрбражаем на экране данные
        places = realm.objects(Place.self)
        
        // Настройка search controller
        // Получателем изменения текста в поисковой строке является сам класс
        searchController.searchResultsUpdater = self
        // Позволяем взаимодействовать с контроллером как с основным
        searchController.obscuresBackgroundDuringPresentation = false
        // Задаем название строки поиска
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        // Добавляем searchcontroller в navigation bar
        navigationItem.searchController = searchController
        // Отпускаем строку поиска при переходе на другой экран
        definesPresentationContext = true
    }
    

// MARK: - TableView data source
    
    // Количесво ячеек в таблице зависит от того идёт сейчас поиск или экран статичен
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredPlaces.count
        } else {
        return places.count
        }
    }
    
    // Содержание ячейки таблицы (зависит от того идет ли поиск)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Создаем ячеку и приводим к классу кастомной ячеки
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = isFiltering ? filtredPlaces[indexPath.row] : places[indexPath.row]

        // Добавляем в ячеку по индексу информацию из массива citysName
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.descriptionLabel.text = place.myDescription

        // Добавляем в ячейку изображение
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        return cell
    }
    
    // MARK: Table view delegate
    
    // Метод отменяет выделение ячейки после перехода на неё
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Метод выхывает пункты меню свайпом по ячейки с права на лево
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
            // Передаем разные данные в зависимости от того активирована ли строка поиска
            let place = isFiltering ? filtredPlaces[indexPath.row] : places[indexPath.row]
            let newPlaceVC = segue.destination as! EditPlaceTableViewController
            newPlaceVC.currentPlace = place
        }
    }

    // Объявляем метод, который при нажатии на кнопку сохранения выводит нас на главный экран при помощи сигвея
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        // Передаем данные из редактируемого вью контроллера на главный и сохраняем внесенные данные
        guard let newPlaceVC = segue.source as? EditPlaceTableViewController else { return }
        newPlaceVC.savePlace()
        // Обнавляем измененный интерфейс
        tableView.reloadData()
    }
    
    // Метод отвечающий за выбор вида сортировки
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    // При нажатии на кнопку меняем сортировку на обратный порядок
    @IBAction func reversedSorting(_ sender: Any) {
        // Метод меняет значение на противоположенное
        ascendingSorting.toggle()
        
        // Меняем значение в случае нажатия кнопки
        if ascendingSorting {
            reversedSortingButtom.image = UIImage(systemName: "arrow.up.arrow.down.circle")
        } else {
            reversedSortingButtom.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
        }
        
        sorting()
    }
    
    // Метод для сортировки
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        // Обновляем таблицу
        tableView.reloadData()
    }
}

// Работа с поиском
extension TableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // Метод занимается фильтрацией контента в соответствии с поисковым запросом
    private func filterContentForSearchText(_ searchText: String) {
        filtredPlaces = places
        // Заполняем поисковый массив объектами из основного массива c использованием инструментов Realm
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}
