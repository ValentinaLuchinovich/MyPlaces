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
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    var annotetionIdentifire = "annotetionIdentifire"
    // Менеджер для управления действиями связанными с местоположением пользователя
    let locationManager = CLLocationManager()
    // Параметр для масштаба карты
    let regionInMetrs = 1000.0
    // Идентификатор определяющий какой метод нужно выбрать
    var incomeSegueIdentifire = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        checkLocationServices()
        // Убираем из зоны видимости стандартные логотипы карты Apple
        mapView.layoutMargins.bottom = -100
        // По умолчанию делаем строку с адресом пустой
        addressLabel.text = ""
    }

    // Переход на участок карты где находится пользователь
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
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
            setupPlacemark()
            // скрываеь mapPin при переходе по методу showPlace
            mapPinImage.isHidden = true
            // скрываем лейбл с адресом
            addressLabel.isHidden = true
            // скрываем кнопку готово
            doneButtone.isHidden = true
        }
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
    // Проверяем включены ли службы геолокации
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
            // Реализуем задержку появления контроллера иначе он не будет отображаться
            // так как метод viewDidLoad загружается еще до того как экран отображен
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertLocation(title: "Службы геолокации отключены",
                                   message: "Перейдите в настройки, чтобы включить службы геолокации")
            }
        }
    }
    
    // Метод задаёт первоночальные установки LocationManager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Метод проверяет статус на разрешение использования геопозиции
    private func checkLocationAutorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifire == "getAddress" { showUserLocation() }
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
    
    // Метод отвечает за переход на экран MapViewController
    private func showUserLocation() {
        // Если у получается определить местоположение пользователя
        if let location = locationManager.location?.coordinate {
        // то определяем регион для позиционирования карты с местоположением пользователя в центре
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMetrs,
                                            longitudinalMeters: regionInMetrs)
            // Устонавливаем регион местоположения на экране
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Метод определяет координаты центра карты на котором установлен маркер
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
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
        present(alert, animated: true)
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
        let center = getCenterLocation(for: mapView)
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
        checkLocationAutorization()
    }
}
