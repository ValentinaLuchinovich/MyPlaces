//
//  MapManager.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 09.12.2021.
//

import UIKit
import MapKit

class MapManager {
    // Менеджер для управления действиями связанными с местоположением пользователя
    var locationManager = CLLocationManager()
    
    // Параметр для масштаба карты
    let regionInMetrs = 500.0
    
    // Настройки маркера места
    func setupPlacemark(place: Place, mapView: MKMapView, annotation: MKPointAnnotation) {
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
            let annotation = annotation
            annotation.title = place.name
            annotation.subtitle = place.location
            
            // Определяем местоположение маркера
            guard let placemarkLocation = placemark?.location else { return }
            // Если вышло получить местоположение маркера, то привязываем аннотацию к этой же точке на картe
            annotation.coordinate = placemarkLocation.coordinate
            
            // Задаем размер карты таким образом, чтобы на ней были видны все собранные аннотации
//            mapView.showAnnotations([annotation], animated: true)
            //  Выделяем созданную аннотацию
            mapView.selectAnnotation(annotation, animated: true)
            
        }
    }
    
    // Проверяем включены ли службы геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifire: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, segueIdentifire: segueIdentifire)
            closure()
        } else {
            // Реализуем задержку появления контроллера иначе он не будет отображаться
            // так как метод viewDidLoad загружается еще до того как экран отображен
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertLocation(title: "Службы геолокации отключены",
                                   message: "Перейдите в настройки, чтобы включить службы геолокации")
            }
        }
    }
    
    
    
    // Метод проверяет статус на разрешение использования геопозиции
    func checkLocationAutorization(mapView: MKMapView, segueIdentifire: String) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifire == "getAddress" { showUserLocation(mapView: mapView, latitudinalMeters: regionInMetrs, longitudinalMeters: regionInMetrs) }
            break
        case .notDetermined:
            // Запрос на использование геолокации
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // Реализуем задержку появления контроллера иначе он не будет отображаться
            // так как метод viewDidLoad загружается еще до того как экран отображен
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertLocation(title: "Службы геолокации отключены",
                                   message: "Перейдите в настройки, чтобы включить службы геолокации")
            }
            break
        case .denied:
            // Реализуем задержку появления контроллера иначе он не будет отображаться
            // так как метод viewDidLoad загружается еще до того как экран отображен
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertLocation(title: "Службы геолокации отключены",
                                   message: "Перейдите в настройки, чтобы включить службы геолокации")
            }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("Новое неизвестное значение")
        }
    }
    
    // Метод отвечает за фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView, latitudinalMeters: Double, longitudinalMeters: Double) {
        // Если у получается определить местоположение пользователя
        if let location = locationManager.location?.coordinate {
        // то определяем регион для позиционирования карты с местоположением пользователя в центре
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: latitudinalMeters,
                                            longitudinalMeters: longitudinalMeters)
            // Устонавливаем регион местоположения на экране
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Метод определяет координаты центра карты на котором установлен маркер
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        // широта
        let latitude = mapView.centerCoordinate.latitude
        // долгота
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    // Алерт контроллер для служб геолокации
    private func alertLocation(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
