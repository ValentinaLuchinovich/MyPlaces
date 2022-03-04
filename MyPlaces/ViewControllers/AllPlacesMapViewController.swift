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

    @IBOutlet weak var mapView: MKMapView!
    
    var places = realm.objects(Place.self)
    let mapManager = MapManager()
    let annotationIdentifire = "annotetionID"
    let regionRadius: Double = 8000000
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.mapType = .hybridFlyover
        mapView.removeAnnotations(mapView.annotations)
        for place in places {
            let annotation = MKPointAnnotation()
            mapManager.setupPlacemark(place: place, mapView: mapView, annotation: annotation)
            mapView.showAnnotations([annotation], animated: true)
        }
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2DMake(40, 3), latitudinalMeters: regionRadius, longitudinalMeters: regionRadius), animated: true)
       
    }
    
    @IBAction func myLocationButton(_ sender: Any) {
        mapManager.showUserLocation(mapView: mapView, latitudinalMeters: mapManager.regionInMetrs, longitudinalMeters: mapManager.regionInMetrs)
    }
    
}

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
