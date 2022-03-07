//
//  AllPlacesMapViewController.swift
//  MyPlaces
//
//  Created by Валентина Лучинович on 25.02.2022.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

class AllPlacesMapViewController: UIViewController {
    
    private var places = realm.objects(Place.self)
    private let mapManager = MapManager()
    private let annotationIdentifire = "annotetionID"
    private let regionRadius: Double = 8000000
    var centerCoordinate = CLLocationCoordinate2DMake(42,12)
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.mapType = .hybridFlyover
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.removeAnnotations(mapView.annotations)
        for place in places {
            let annotation = MKPointAnnotation()
            mapManager.setupPlacemark(place: place, mapView: mapView, annotation: annotation)
            mapView.showAnnotations([annotation], animated: true)
        }
            
        DispatchQueue.main.async { [self] in
            mapView.setRegion(MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius), animated: true)
        }
    }
    
    @IBAction func myLocationButton(_ sender: Any) {
        mapManager.showUserLocation(mapView: mapView, latitudinalMeters: mapManager.regionInMetrs, longitudinalMeters: mapManager.regionInMetrs)
    }
}

// MARK: Annotations

extension AllPlacesMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifire) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifire)
        }
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
        return annotationView
    }
}
