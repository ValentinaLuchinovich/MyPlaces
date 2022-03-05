//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 26.11.2021.
//

import UIKit
import RealmSwift

class TableViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filtredPlaces: Results<Place>!
    private var places: Results<Place>!
    private var ascendingSorting = true
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
        places = realm.objects(Place.self)
        
        // Настройка search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? EditPlaceTableViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        // Замена значения на противоположенное
        ascendingSorting.toggle()
        if ascendingSorting {
            reversedSortingButtom.image = UIImage(systemName: "arrow.up.arrow.down.circle")
        } else {
            reversedSortingButtom.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
        }
        sorting()
    }
    
    // Передача информации на DetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDeteil" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            // Разные данные передаются в зависимости от того активирована ли строка поиска
            let place = isFiltering ? filtredPlaces[indexPath.row] : places[indexPath.row]
            let newPlaceVC = segue.destination as! DetailViewController
            newPlaceVC.currentPlace = place
        }
    }

    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}


// MARK: - TableView data source

extension TableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredPlaces.count
        } else {
        return places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let place = isFiltering ? filtredPlaces[indexPath.row] : places[indexPath.row]
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        return cell
    }
}
    

// MARK: Table view delegate

extension TableViewController: UITableViewDelegate {
    // Отмена выделенной ячейки после перехода на неё
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Объект
        let place = places[indexPath.row]
        // Действие редактирования
        let editAction = UIContextualAction(style: .normal, title: "Изменить") { [self] _, _, _ in
            if let editViewController = storyboard?.instantiateViewController(withIdentifier: "EditPlaceTableViewController") as? UINavigationController {
            present(editViewController, animated: true, completion: nil)
            let place = isFiltering ? filtredPlaces[indexPath.row] : places[indexPath.row]
            let editPlace = editViewController.topViewController as! EditPlaceTableViewController
            editPlace.currentPlace = place
            }
        }
        
        // Действие удаления
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (_, _, _) in
            // Удаляем объект из базы
            StorageManager.deleteObject(place)
            // Удаляем саму строку
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return swipeAction
    }
}
    

//MARK: Search
    
// Работа с поиском
extension TableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // Фильтрация контента в соответствии с поисковым запросом
    private func filterContentForSearchText(_ searchText: String) {
        filtredPlaces = places
        // Заполнение массива поиска объектами из основного массива c использованием Realm
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}
