//
//  TableViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 26.11.2021.
//

import UIKit

class TableViewController: UITableViewController {
 
    let citysNames = ["Санкт-Петербург", "Барселона", "Байкал", "Дубай", "Москва", "Стокгольм"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

// MARK: - TableView data source
    
    // Количесво ячеек в таблице
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citysNames.count
    }
    
    // Содержание ячейки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Добавляем в ячеку по индексу информацию из массива citysName
        cell.textLabel?.text = citysNames[indexPath.row]
        // Добавляем в ячейку изображение по индексу элементов из массива citysNames
        cell.imageView?.image = UIImage.init(named: citysNames[indexPath.row])
        // Делаем изображение в ячейке круглым
        cell.imageView?.layer.cornerRadius = cell.frame.size.height / 2
        cell.imageView?.clipsToBounds = true
    
        
        
        return cell
    }
    

// MARK: - TableView delegate
    
    // Высота ячеек таблицы
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

}
