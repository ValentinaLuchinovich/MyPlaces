//
//  MapManager.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 09.12.2021.
//

import UIKit
import MapKit

class MapManager {
    var locationManager = CLLocationManager()
    let regionInMetrs = 500.0
    
    // Настройка маркера
    func setupPlacemark(place: Place, mapView: MKMapView, annotation: MKPointAnnotation) {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        // Определение места по адресу переданному в параметры
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
        guard let placemarks = placemarks else { return }
            
        let placemark = placemarks.first
        let annotation = annotation
        annotation.title = place.name
        annotation.subtitle = place.location
            
        // Определение местоположения маркера
        guard let placemarkLocation = placemark?.location else { return }
        annotation.coordinate = placemarkLocation.coordinate
        mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Проверка включения ли служб геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifire: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, segueIdentifire: segueIdentifire)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertLocation(title: "Службы геолокации отключены",
                                   message: "Перейдите в настройки, чтобы включить службы геолокации")
            }
        }
    }
    
    // Проверка статуса на разрешение использования геопозиции
    func checkLocationAutorization(mapView: MKMapView, segueIdentifire: String) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifire == "getAddress" { showUserLocation(mapView: mapView, latitudinalMeters: regionInMetrs, longitudinalMeters: regionInMetrs) }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertLocation(title: "Службы геолокации отключены",
                                   message: "Перейдите в настройки, чтобы включить службы геолокации")
            }
            break
        case .denied:
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
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView, latitudinalMeters: Double, longitudinalMeters: Double) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: latitudinalMeters,
                                            longitudinalMeters: longitudinalMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Определение координат центра карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
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
