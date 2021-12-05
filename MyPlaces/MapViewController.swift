//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 04.12.2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    var place = Place()
    var annotetionIdentifire = "annotetionIdentifire"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacemark()
    }

    // Нажатие на кнопку крестика будет закрывать вьюконтроллер
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    // Настройки маркера места
    private func setupPlacemark() {
        // Извлекаем адрес
        guard let location = place.location else { return }
        // Создаем экземпляр класса CLGeocoder, который отвечает за преобразование географических координат и названий
        let geocoder = CLGeocoder()
        // Определяем место по адресу переданному в параметры
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            // Проверяем не содержит ли объект error каких-либо данных
            if let error = error {
                print(error)
                return
            }
            // Если ошибки нет то
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            //Описываем точку на карте
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.location
            
            // Определяем местоположение маркера
            guard let placemarkLocation = placemark?.location else { return }
            // Если вышло получить местоположение маркера, то привязываем аннотацию к этой же точке на картe
            annotation.coordinate = placemarkLocation.coordinate
            
            // Задаем размер карты таким образом, чтобы на ней были видны все собранные аннотации
            self.mapView.showAnnotations([annotation], animated: true)
            //  Выделяем созданную аннотацию
            self.mapView.selectAnnotation(annotation, animated: true)
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
}
