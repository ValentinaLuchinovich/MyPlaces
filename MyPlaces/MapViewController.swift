//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 04.12.2021.
//

import UIKit

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // Нажатие на кнопку крестика будет закрывать вьюконтроллер
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
}
