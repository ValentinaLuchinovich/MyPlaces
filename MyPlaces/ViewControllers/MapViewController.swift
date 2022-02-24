//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 04.12.2021.
//

import UIKit
import MapKit
import CoreLocation
import SwiftUI

// Реализуем протокол для передачи данных из MapViewController в EditPlaceTableViewController
protocol MapViewControllerDelegate {
    func getAddress (_ address: String?)
}

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButtone: UIButton!
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    var annotetionIdentifire = "annotetionIdentifire"
    
  
    // Идентификатор определяющий какой метод нужно выбрать
    var incomeSegueIdentifire = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
//        // Убираем из зоны видимости стандартные логотипы карты Apple
//        mapView.layoutMargins.bottom = -100
        // По умолчанию делаем строку с адресом пустой
        addressLabel.text = ""
    }

    // Переход на участок карты где находится пользователь
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    // При нажатии выполняется передача данных из MapViewController в EditPlaceTableViewController
    @IBAction func doneButtonePressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        // Закрываем вьюконтроллер
        dismiss(animated: true)
    }
    
    // Нажатие на кнопку крестика будет закрывать вьюконтроллер
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    // Метод для настройки карты в зависимости от свойства incomeSegueIdentifire
    private func setupMapView() {
        if incomeSegueIdentifire == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            // скрываеь mapPin при переходе по методу showPlace
            mapPinImage.isHidden = true
            // скрываем лейбл с адресом
            addressLabel.isHidden = true
            // скрываем кнопку готово
            doneButtone.isHidden = true
        }
    }
}

// Протокол MKMapViewDelegate позволяет расширять возможности аннотаций на карте
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Исключаем возможность, что данная аннотация является текущем местоположением пользователя
        guard !(annotation is MKUserLocation) else { return nil}
        // Объект представляющий вью с аннотацией на карте, который будет переиспользоваться
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotetionIdentifire) as? MKPinAnnotationView
        //В случае если  у нас нет представления с аннотацией, которое можно переиспользовать - создаем новую
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotetionIdentifire)
            // Присваем значение true, чтобы иметь возможность отобразить аннотацию ввиде баннера
            annotationView?.canShowCallout = true
        }
        // Проверяем наличие изображения
        if let imageData = place.imageData {
            // Отображаем на баннере изображение
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            // Делаем углы изображение полукруглыми, как у баннера
            imageView.layer.cornerRadius = 10
            // Обрезаем изобраджение по границе закругленных углов image view
            imageView.clipsToBounds = true
            // Помещаем в image view само изображение
            imageView.image = UIImage(data: imageData)
            // Пропорционально обрезаем изображение по границам фрейма
            imageView.contentMode = .scaleAspectFill
            // Отображаем image view на баннере
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    // Получаем адрес соответствующий центру экрана
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        // Преображаем координаты в адрес
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            // Проверяем объект error на содержимое
            if let error = error {
                print(error)
                return
            }
            // Если ошибки нет - извлекаем массив меток
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            // Извлекаем улицу и номер дома
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            // Обнавляем интервейс в основном потоке асинхронно
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
}

// Метод отслеживает в реальном времени изменение местоположения
extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAutorization(mapView: mapView, segueIdentifire: incomeSegueIdentifire)
    }
}
