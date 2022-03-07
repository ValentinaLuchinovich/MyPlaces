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

// Протокол передачи данных из MapViewController в EditPlaceTableViewController
protocol MapViewControllerDelegate {
    func getAddress (_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    let annotation = MKPointAnnotation()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    var incomeSegueIdentifire = ""
    private var annotetionIdentifire = "annotetionIdentifire"
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButtone: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapManager.locationManager.delegate = self
        addressLabel.text = ""
        setupMapView()
    }

    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView, latitudinalMeters: mapManager.regionInMetrs, longitudinalMeters: mapManager.regionInMetrs)
    }
    
    @IBAction func doneButtonePressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        if incomeSegueIdentifire == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView, annotation: annotation)
            mapView.showAnnotations([annotation], animated: true)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButtone.isHidden = true
        }
    }
}

// MARK: Delegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil}
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotetionIdentifire) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotetionIdentifire)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            imageView.contentMode = .scaleAspectFill
            annotationView?.rightCalloutAccessoryView = imageView
        }
        annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
        return annotationView
    }
    
    // Получение адреса соответствующего центру экрана
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let cityName = placemark?.locality
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if cityName != nil && streetName != nil && buildNumber != nil {
                self.addressLabel.text = "\(cityName!), \(streetName!), \(buildNumber!)"
                } else if cityName != nil && streetName != nil  {
                    self.addressLabel.text = "\(cityName!), \(streetName!)"
                } else if cityName != nil{
                    self.addressLabel.text = "\(cityName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
}

//MARK: Location tarcker
// Метод отслеживает в реальном времени изменение местоположения
extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAutorization(mapView: mapView, segueIdentifire: incomeSegueIdentifire)
    }
}
